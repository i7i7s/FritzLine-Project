import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/tiket_controller.dart';

class TiketView extends GetView<TiketController> {
  const TiketView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return SafeArea(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Semua tiket yang Anda beli akan muncul di sini.",
                  style: TextStyle(color: Colors.grey),
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

            return InkWell(
              onTap: () => controller.showTicketDetail(ticket),
              borderRadius: BorderRadius.circular(10),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        train['namaKereta'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(ticket['totalPrice']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF656CEE),
                        ),
                      ),
                      const Divider(height: 20),
                      Text(
                        "${train['stasiunBerangkat']} -> ${train['stasiunTiba']}",
                      ),
                      Text(
                        "${train['jadwalBerangkat']} - ${train['jadwalTiba']} (${train['durasi']})",
                      ),
                      const SizedBox(height: 8),
                      Text("Penumpang: ${passengers.length} orang"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
