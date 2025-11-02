import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fritzlinee/app/services/booking_service.dart';
import 'package:fritzlinee/app/services/ticket_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import 'package:fritzlinee/app/services/notification_service.dart';

class DetailBookingTiketController extends GetxController {
  final bookingService = Get.find<BookingService>();
  final ticketService = Get.find<TicketService>();

  final trainData = <String, dynamic>{}.obs;
  final passengerData = <Map<String, String>>[].obs;
  final selectedSeats = <String>[].obs;

  final totalHarga = 0.obs;
  final exchangeRates = {}.obs;
  final isCurrencyLoading = false.obs;

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  void onInit() {
    super.onInit();
    _loadDataFromServices();
  }

  void _loadDataFromServices() {
    trainData.value = bookingService.selectedTrain;
    passengerData.value = bookingService.passengerData;
    selectedSeats.value = bookingService.selectedSeats;

    int hargaPerTiket = trainData['harga'] ?? 0;
    int jumlahPenumpang = passengerData.length;
    totalHarga.value = hargaPerTiket * jumlahPenumpang;
  }

  String getFormattedTotalPrice() {
    return currencyFormatter.format(totalHarga.value);
  }

  Future<void> _fetchExchangeRates() async {
    isCurrencyLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          "https://v6.exchangerate-api.com/v6/574116bcb3be786574b56e56/latest/IDR"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        exchangeRates.value = data['conversion_rates'];
      } else {
        Get.snackbar("Error", "Gagal mengambil data kurs mata uang.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal terhubung ke server kurs mata uang.");
    } finally {
      isCurrencyLoading.value = false;
    }
  }

  void showCurrencyBottomSheet() {
    _fetchExchangeRates();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Konversi Mata Uang",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCurrencyRow("IDR (Rupiah)", totalHarga.value.toDouble(),
                isBase: true),
            const Divider(height: 20),
            Obx(() {
              if (isCurrencyLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (exchangeRates.isEmpty) {
                return const Center(
                    child: Text("Gagal memuat data kurs."));
              }

              final double usdRate =
                  (exchangeRates['USD'] as num? ?? 0.0).toDouble();
              final double eurRate =
                  (exchangeRates['EUR'] as num? ?? 0.0).toDouble();
              final double jpyRate =
                  (exchangeRates['JPY'] as num? ?? 0.0).toDouble();

              return Column(
                children: [
                  _buildCurrencyRow(
                      "USD (Dolar AS)", totalHarga.value * usdRate),
                  _buildCurrencyRow("EUR (Euro)", totalHarga.value * eurRate),
                  _buildCurrencyRow(
                      "JPY (Yen Jepang)", totalHarga.value * jpyRate),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(String currency, double amount,
      {bool isBase = false}) {
    final format = NumberFormat.currency(
      locale: isBase ? 'id_ID' : 'en_US',
      symbol: isBase ? 'Rp' : '',
      decimalDigits: isBase ? 0 : 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(currency, style: const TextStyle(fontSize: 16)),
          Text(
            "${isBase ? '' : currency.split(' ')[0]} ${format.format(amount)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  tz.TZDateTime _parseWIB(String hhmm) {
    final parts = hhmm.split(':');
    final now = DateTime.now();
    return tz.TZDateTime(
      tz.getLocation('Asia/Jakarta'),
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _formatTime(tz.TZDateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  void showTimezoneBottomSheet() {
    final wibBerangkat = _parseWIB(trainData['jadwalBerangkat']);
    final wibTiba = _parseWIB(trainData['jadwalTiba']);

    final witaBerangkat =
        tz.TZDateTime.from(wibBerangkat, tz.getLocation('Asia/Makassar'));
    final witaTiba =
        tz.TZDateTime.from(wibTiba, tz.getLocation('Asia/Makassar'));

    final witBerangkat =
        tz.TZDateTime.from(wibBerangkat, tz.getLocation('Asia/Jayapura'));
    final witTiba =
        tz.TZDateTime.from(wibTiba, tz.getLocation('Asia/Jayapura'));

    final lonBerangkat =
        tz.TZDateTime.from(wibBerangkat, tz.getLocation('Europe/London'));
    final lonTiba =
        tz.TZDateTime.from(wibTiba, tz.getLocation('Europe/London'));

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Konversi Zona Waktu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimezoneRow("WIB (Asia/Jakarta)", wibBerangkat, wibTiba),
            _buildTimezoneRow("WITA (Asia/Makassar)", witaBerangkat, witaTiba),
            _buildTimezoneRow("WIT (Asia/Jayapura)", witBerangkat, witTiba),
            _buildTimezoneRow("LON (Europe/London)", lonBerangkat, lonTiba),
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneRow(
      String zone, tz.TZDateTime berangkat, tz.TZDateTime tiba) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(zone, style: const TextStyle(fontSize: 16)),
          Text(
            "${_formatTime(berangkat)} - ${_formatTime(tiba)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void konfirmasiPembayaran() {
    String generateBookingCode() {
      var random = Random();
      return List.generate(6, (index) => random.nextInt(10).toString()).join();
    }

    final ticketData = {
      "bookingCode": "FRTZ-${generateBookingCode()}",
      "trainData": {...trainData},
      "passengerData": passengerData.toList(),
      "selectedSeats": selectedSeats.toList(),
      "totalPrice": totalHarga.value,
      "paymentDate": DateTime.now().toIso8601String(),
    };

    ticketService.saveNewTicket(ticketData);
    bookingService.resetBooking();

    Get.find<NotificationService>().showPaymentSuccess();

    Get.snackbar(
      "Pembayaran Berhasil",
      "Tiket Anda telah berhasil diterbitkan.",
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.offAllNamed(Routes.HOME);
  }
}