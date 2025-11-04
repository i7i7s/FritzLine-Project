import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/ticket_service.dart';

class TiketController extends GetxController {
  final ticketService = Get.find<TicketService>();

  String _formatSavedPrice(double price, String currency) {
    if (currency == "IDR") {
      return NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
          .format(price);
    }
    return NumberFormat.currency(
            locale: 'en_US', symbol: "$currency ", decimalDigits: 2)
        .format(price);
  }

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

    final int totalPriceIDR = (ticket['totalPrice'] is num)
        ? (ticket['totalPrice'] as num).toInt()
        : 0;
    final double paymentPrice = (ticket['paymentPrice'] is num)
        ? (ticket['paymentPrice'] as num).toDouble()
        : (totalPriceIDR.toDouble());
    final String paymentCurrency = ticket['paymentCurrency'] ?? 'IDR';

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
              _buildDetailRow(Icons.access_time, "Waktu",
                  "$jadwalBerangkat - $jadwalTiba"),
              _buildDetailRow(Icons.event_seat_outlined, "Kursi Anda",
                  seatNumbers.isEmpty ? "Tidak ada" : seatNumbers),
              _buildDetailRow(
                  Icons.people_alt_outlined, "Penumpang", passengerNames),
              _buildDetailRow(
                  Icons.payments_outlined,
                  "Total Bayar ($paymentCurrency)",
                  _formatSavedPrice(paymentPrice, paymentCurrency)),
              const SizedBox(height: 20),
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
}