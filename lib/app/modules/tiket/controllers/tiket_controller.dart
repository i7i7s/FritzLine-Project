import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/ticket_service.dart';

class TiketController extends GetxController {
  final ticketService = Get.find<TicketService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ticketService.reloadTickets();
    });
  }

  void showTicketDetail(Map<String, dynamic>? ticket) {
    if (ticket == null) {
      Get.snackbar(
        'Error',
        'Data tiket tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF5252),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    Get.toNamed('/ticket-detail', arguments: ticket);
  }
}
