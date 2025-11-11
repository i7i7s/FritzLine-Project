import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/tiket_controller.dart';

class TiketView extends GetView<TiketController> {
  const TiketView({super.key});

  String _formatSavedPrice(double price, String currency) {
    if (currency == "IDR") {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(price);
    }
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: "$currency ",
      decimalDigits: 2,
    ).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Tiket Saya",
          style: TextStyle(
              color: Color(0xFF1B1B1F), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.ticketService.allMyTickets.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Belum Ada Tiket",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1F)),
                  ),
                  Text(
                    "Semua tiket yang Anda beli akan muncul di sini.",
                    style: TextStyle(color: Color(0xFF49454F)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.ticketService.allMyTickets.length,
            itemBuilder: (context, index) {
              final ticket = controller.ticketService.allMyTickets[index];
              final train = ticket['trainData'] as Map<String, dynamic>;
              final passengers = ticket['passengerData'] as List<dynamic>;

              final int totalPriceIDR = (ticket['totalPrice'] is num)
                  ? (ticket['totalPrice'] as num).toInt()
                  : 0;
              final double paymentPrice = (ticket['paymentPrice'] is num)
                  ? (ticket['paymentPrice'] as num).toDouble()
                  : (totalPriceIDR.toDouble());
              final String paymentCurrency = ticket['paymentCurrency'] ?? 'IDR';

              final String jadwalBerangkat =
                  train['jadwalBerangkat'] ?? '??:??';
              final String jadwalTiba = train['jadwalTiba'] ?? '??:??';
              final String selectedDateStr = ticket['selectedDate'] ?? '';
              String displayDate = '';
              if (selectedDateStr.isNotEmpty) {
                try {
                  displayDate = DateFormat(
                    'EEEE, d MMMM yyyy',
                    'id_ID',
                  ).format(DateTime.parse(selectedDateStr));
                } catch (e) {
                  displayDate = 'Tanggal tidak valid';
                }
              }

              return InkWell(
                onTap: () => controller.showTicketDetail(ticket),
                borderRadius: BorderRadius.circular(12),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        color: const Color(0xFF333E63),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              train['namaKereta'] ?? 'Nama Kereta',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              ticket['bookingCode'] ?? '---',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatSavedPrice(paymentPrice, paymentCurrency),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF656CEE),
                              ),
                            ),
                            const Divider(height: 24),
                            Text(
                              displayDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B1B1F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  train['stasiunBerangkat'] ?? '...',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Icon(Icons.arrow_forward, size: 16),
                                ),
                                Text(
                                  train['stasiunTiba'] ?? '...',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              "$jadwalBerangkat - $jadwalTiba (${train['durasi']})",
                              style: const TextStyle(
                                  color: Color(0xFF49454F), fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Penumpang: ${passengers.length} orang",
                              style: const TextStyle(
                                  color: Color(0xFF49454F), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}