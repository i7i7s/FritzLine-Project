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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Tiket Saya",
          style: TextStyle(
            color: Color(0xFF1B1B1F),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.ticketService.allMyTickets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF656CEE).withOpacity(0.1),
                            const Color(0xFFFF6B35).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        size: 80,
                        color: const Color(0xFF656CEE).withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Belum Ada Tiket",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B1B1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Semua tiket yang Anda beli\nakan muncul di sini.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF49454F).withOpacity(0.8),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.showTicketDetail(ticket),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header dengan gradient
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        train['namaKereta'] ?? 'Nama Kereta',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ticket['bookingCode'] ?? '---',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      displayDate,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Body content
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Harga
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF656CEE,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.payment_rounded,
                                        size: 20,
                                        color: Color(0xFF656CEE),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _formatSavedPrice(
                                        paymentPrice,
                                        paymentCurrency,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF656CEE),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.shade200,
                                ),
                                const SizedBox(height: 20),

                                // Route info
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "KEBERANGKATAN",
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF49454F,
                                              ).withOpacity(0.7),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            train['stasiunBerangkat'] ?? '...',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Color(0xFF1B1B1F),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            jadwalBerangkat,
                                            style: const TextStyle(
                                              color: Color(0xFF49454F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF656CEE,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Color(0xFF656CEE),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "TIBA",
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF49454F,
                                              ).withOpacity(0.7),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            train['stasiunTiba'] ?? '...',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Color(0xFF1B1B1F),
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            jadwalTiba,
                                            style: const TextStyle(
                                              color: Color(0xFF49454F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Duration & Passengers
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F7FA),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 18,
                                              color: Color(0xFF656CEE),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              train['durasi'] ?? '-',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Color(0xFF1B1B1F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F7FA),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.people_rounded,
                                              size: 18,
                                              color: Color(0xFF656CEE),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "${passengers.length} Penumpang",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Color(0xFF1B1B1F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
