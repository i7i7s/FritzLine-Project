import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/reschedule_service.dart';
import '../../../services/loyalty_service.dart';
import '../../../models/reschedule_request.dart';

class RequestRescheduleController extends GetxController {
  final rescheduleService = Get.find<RescheduleService>();
  final loyaltyService = Get.find<LoyaltyService>();

  late String originalTicketId;
  late String originalTrainId;
  late String originalTrainName;
  late DateTime originalTravelDate;
  late String originalDeparture;
  late String originalArrival;
  late double originalAmount;
  late String memberTier;

  final reason = TextEditingController();

  final rescheduleFee = 0.0.obs;
  final feePercentage = 0.0.obs;
  final daysBeforeDeparture = 0.obs;
  final ruleApplied = ''.obs;
  final canReschedule = true.obs;
  final hasFreeReschedule = false.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTicketDetails();
    _calculateRescheduleFee();
    _checkFreeReschedule();
  }

  void _loadTicketDetails() {
    final args = Get.arguments as Map<String, dynamic>;
    originalTicketId = args['ticketId'] ?? '';
    originalTrainId = args['trainId'] ?? '';
    originalTrainName = args['trainName'] ?? '';
    originalTravelDate = args['travelDate'] ?? DateTime.now();
    originalDeparture = args['departure'] ?? '';
    originalArrival = args['arrival'] ?? '';
    originalAmount = args['originalAmount'] ?? 0.0;
    memberTier = args['memberTier'] ?? 'Bronze';
  }

  void _calculateRescheduleFee() {
    var calculation = rescheduleService.calculateRescheduleFee(
      originalTravelDate: originalTravelDate,
      originalAmount: originalAmount,
    );

    if (calculation['canReschedule']) {
      daysBeforeDeparture.value = calculation['daysBeforeDeparture'];
      feePercentage.value = calculation['feePercentage'];
      rescheduleFee.value = calculation['rescheduleFee'];
      ruleApplied.value = calculation['ruleApplied'];
      canReschedule.value = true;
    } else {
      canReschedule.value = false;
    }
  }

  void _checkFreeReschedule() {
    hasFreeReschedule.value = rescheduleService.hasFreeReschedule(memberTier);
  }

  bool validateForm() {
    if (reason.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Alasan reschedule tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }
    return true;
  }

  Future<void> submitRescheduleRequest() async {
    if (!canReschedule.value) {
      Get.snackbar(
        'Error',
        'Tidak dapat reschedule setelah keberangkatan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (!validateForm()) return;

    try {
      isLoading.value = true;

      RescheduleRequest request = await rescheduleService
          .createRescheduleRequest(
            originalTicketId: originalTicketId,
            originalTrainId: originalTrainId,
            originalTrainName: originalTrainName,
            originalTravelDate: originalTravelDate,
            originalDeparture: originalDeparture,
            originalArrival: originalArrival,
            reason: reason.text,
            originalAmount: originalAmount,
          );

      isLoading.value = false;

      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Reschedule Diajukan!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request ID: ${request.requestId}'),
              SizedBox(height: 8),
              if (hasFreeReschedule.value) ...[
                Text(
                  'GRATIS (Benefit Loyalty)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ] else ...[
                Text(
                  'Biaya: Rp ${request.rescheduleFee.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
              SizedBox(height: 16),
              Text(
                'Pilih jadwal baru di halaman berikutnya.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    reason.dispose();
    super.onClose();
  }
}
