import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fritzlinee/app/services/booking_service.dart';
import 'package:fritzlinee/app/services/ticket_service.dart';
import 'package:fritzlinee/app/services/hive_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';
import 'package:fritzlinee/app/services/notification_service.dart';
import 'package:fritzlinee/app/services/settings_service.dart';

class DetailBookingTiketController extends GetxController {
  final bookingService = Get.find<BookingService>();
  final ticketService = Get.find<TicketService>();
  final settingsService = Get.find<SettingsService>();
  final hiveService = Get.find<HiveService>();

  final trainData = <String, dynamic>{}.obs;
  final passengerData = <Map<String, String>>[].obs;
  final selectedSeats = <String>[].obs;

  final totalHarga = 0.obs;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  final availableCurrencies = {
    "IDR": "Rupiah (IDR)",
    "USD": "Dolar AS (USD)",
    "EUR": "Euro (EUR)",
    "JPY": "Yen Jepang (JPY)",
  };

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

  String _formatPriceByCode(double price, String code) {
    if (code == "IDR") {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(price);
    }
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: "$code ",
      decimalDigits: 2,
    ).format(price);
  }

  void showCurrencyBottomSheet() {
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
              "Pilih Mata Uang",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (settingsService.isRatesLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: availableCurrencies.entries.map((entry) {
                  bool isSelected =
                      settingsService.preferredCurrency.value == entry.key;

                  String currencyCode = entry.key;
                  double rate =
                      (settingsService.exchangeRates[currencyCode] as num? ??
                              1.0)
                          .toDouble();
                  double convertedPrice = totalHarga.value * rate;
                  String formattedPrice = _formatPriceByCode(
                    convertedPrice,
                    currencyCode,
                  );

                  return ListTile(
                    title: Text(entry.value),
                    subtitle: Text(formattedPrice),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Color(0xFF656CEE))
                        : null,
                    onTap: () {
                      settingsService.updateCurrency(entry.key);
                      Get.back();
                    },
                  );
                }).toList(),
              );
            }),
          ],
        ),
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

    final witaBerangkat = tz.TZDateTime.from(
      wibBerangkat,
      tz.getLocation('Asia/Makassar'),
    );
    final witaTiba = tz.TZDateTime.from(
      wibTiba,
      tz.getLocation('Asia/Makassar'),
    );

    final witBerangkat = tz.TZDateTime.from(
      wibBerangkat,
      tz.getLocation('Asia/Jayapura'),
    );
    final witTiba = tz.TZDateTime.from(
      wibTiba,
      tz.getLocation('Asia/Jayapura'),
    );

    final lonBerangkat = tz.TZDateTime.from(
      wibBerangkat,
      tz.getLocation('Europe/London'),
    );
    final lonTiba = tz.TZDateTime.from(
      wibTiba,
      tz.getLocation('Europe/London'),
    );

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
    String zone,
    tz.TZDateTime berangkat,
    tz.TZDateTime tiba,
  ) {
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

  Future<void> konfirmasiPembayaran() async {
    String generateBookingCode() {
      var random = Random();
      return List.generate(6, (index) => random.nextInt(10).toString()).join();
    }

    String currencyCode = settingsService.preferredCurrency.value;
    double rate = (settingsService.exchangeRates[currencyCode] as num? ?? 1.0)
        .toDouble();
    double finalConvertedPrice = totalHarga.value * rate;

    final ticketData = {
      "bookingCode": "FRTZ-${generateBookingCode()}",
      "trainData": {...trainData},
      "passengerData": passengerData.toList(),
      "selectedSeats": selectedSeats.toList(),
      "totalPrice": totalHarga.value,
      "paymentPrice": finalConvertedPrice,
      "paymentCurrency": currencyCode,
      "paymentDate": DateTime.now().toIso8601String(),
      "selectedDate": bookingService.selectedDate.value.toIso8601String(),
    };

    await hiveService.kurangiStokTiket(trainData['id'], passengerData.length);

    await ticketService.saveNewTicket(ticketData);
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
