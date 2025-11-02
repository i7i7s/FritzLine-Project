import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/ticket_service.dart';
import '../../../services/settings_service.dart';

class TiketController extends GetxController {
  final ticketService = Get.find<TicketService>();
  final settingsService = Get.find<SettingsService>();

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final availableCurrencies = {
    "IDR": "Rupiah (IDR)",
    "USD": "Dolar AS (USD)",
    "EUR": "Euro (EUR)",
    "JPY": "Yen Jepang (JPY)",
  };

  final availableTimezones = {
    "Asia/Jakarta": "WIB (Jakarta)",
    "Asia/Makassar": "WITA (Makassar)",
    "Asia/Jayapura": "WIT (Jayapura)",
    "Europe/London": "BST (London)",
  };

  void showTicketDetail(Map<String, dynamic> ticket) {
    final train = ticket['trainData'] as Map<String, dynamic>;
    final passengersRaw = ticket['passengerData'] as List<dynamic>;
    final seatsRaw = ticket['selectedSeats'] as List<dynamic>;

    final passengerNames = passengersRaw.map((p) {
      final passengerMap = p as Map<String, dynamic>;
      return passengerMap['nama'] ?? '??';
    }).join(", ");

    final seatNumbers = seatsRaw.map((s) => s.toString()).join(", ");

    final String jadwalBerangkat = train['jadwalBerangkat'] ?? '??:??';
    final String jadwalTiba = train['jadwalTiba'] ?? '??:??';

    final int totalPrice = (ticket['totalPrice'] is num)
        ? (ticket['totalPrice'] as num).toInt()
        : 0;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detail Tiket",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333E63)),
              ),
              Text(
                ticket['bookingCode'] ?? '---',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const Divider(height: 24),
              _buildDetailRow(
                  Icons.train_outlined, "Kereta", train['namaKereta'] ?? '---'),
              _buildDetailRow(Icons.route_outlined, "Rute",
                  "${train['stasiunBerangkat']} ➔ ${train['stasiunTiba']}"),
              Obx(() => _buildDetailRow(
                  Icons.access_time,
                  "Waktu (${settingsService.preferredTimezone.value.split('/').last})",
                  "${settingsService.formatTime(jadwalBerangkat)} - ${settingsService.formatTime(jadwalTiba)}")),
              _buildDetailRow(Icons.event_seat_outlined, "Kursi Anda",
                  seatNumbers.isEmpty ? "Tidak ada" : seatNumbers),
              _buildDetailRow(
                  Icons.people_alt_outlined, "Penumpang", passengerNames),
              Obx(() => _buildDetailRow(
                  Icons.payments_outlined,
                  "Total Bayar (${settingsService.preferredCurrency.value})",
                  settingsService.formatPrice(totalPrice))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showCurrencyBottomSheet(),
                      child: Text("Ubah Mata Uang"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF656CEE),
                        side: BorderSide(color: Color(0xFF656CEE)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showTimezoneBottomSheet(),
                      child: Text("Ubah Zona Waktu"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF656CEE),
                        side: BorderSide(color: Color(0xFF656CEE)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF656CEE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "TUTUP",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF656CEE), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333E63)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            Obx(() => Column(
                  children: availableCurrencies.entries.map((entry) {
                    bool isSelected =
                        settingsService.preferredCurrency.value == entry.key;
                    return ListTile(
                      title: Text(entry.value),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: Color(0xFF656CEE))
                          : null,
                      onTap: () {
                        settingsService.updateCurrency(entry.key);
                        Get.back();
                      },
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );
  }

  void showTimezoneBottomSheet() {
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
              "Pilih Zona Waktu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: availableTimezones.entries.map((entry) {
                    bool isSelected =
                        settingsService.preferredTimezone.value == entry.key;
                    return ListTile(
                      title: Text(entry.value),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: Color(0xFF656CEE))
                          : null,
                      onTap: () {
                        settingsService.updateTimezone(entry.key);
                        Get.back();
                      },
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
    );
  }
}