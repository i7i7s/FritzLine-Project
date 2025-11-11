import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../services/refund_service.dart';
import '../../../models/refund_request.dart';

class RequestRefundController extends GetxController {
  final refundService = Get.find<RefundService>();

  late String ticketId;
  late String trainId;
  late String trainName;
  late DateTime travelDate;
  late double originalAmount;

  final reason = TextEditingController();
  final bankAccount = TextEditingController();
  final bankName = TextEditingController();

  final refundAmount = 0.0.obs;
  final refundPercentage = 0.0.obs;
  final adminFee = 0.0.obs;
  final daysBeforeDeparture = 0.obs;
  final ruleApplied = ''.obs;
  final canRefund = true.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTicketDetails();
    _calculateRefund();
  }

  void _loadTicketDetails() {
    final args = Get.arguments as Map<String, dynamic>;
    ticketId = args['ticketId'] ?? '';
    trainId = args['trainId'] ?? '';
    trainName = args['trainName'] ?? '';
    travelDate = args['travelDate'] ?? DateTime.now();
    originalAmount = args['originalAmount'] ?? 0.0;
  }

  void _calculateRefund() {
    var calculation = refundService.calculateRefundAmount(
      travelDate: travelDate,
      originalAmount: originalAmount,
    );

    daysBeforeDeparture.value = calculation['daysBeforeDeparture'];
    refundPercentage.value = calculation['refundPercentage'];
    refundAmount.value = calculation['refundAmount'];
    adminFee.value = calculation['adminFee'];
    ruleApplied.value = calculation['ruleApplied'];
    canRefund.value = calculation['canRefund'];
  }

  bool validateForm() {
    if (reason.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Alasan refund tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }

    if (bankAccount.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nomor rekening tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }

    if (bankName.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama bank tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }

    return true;
  }

  Future<void> submitRefundRequest() async {
    if (!canRefund.value) {
      Get.snackbar(
        'Error',
        'Tidak dapat mengajukan refund setelah keberangkatan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (!validateForm()) return;

    try {
      isLoading.value = true;

      RefundRequest request = await refundService.createRefundRequest(
        ticketId: ticketId,
        trainId: trainId,
        trainName: trainName,
        travelDate: travelDate,
        reason: reason.text,
        originalAmount: originalAmount,
        bankAccount: bankAccount.text,
        bankName: bankName.text,
      );

      isLoading.value = false;

      Get.dialog(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Refund Diajukan!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request ID: ${request.requestId}'),
              SizedBox(height: 8),
              Text(
                'Refund: Rp ${request.refundAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Refund akan diproses dalam 3-7 hari kerja ke rekening yang Anda daftarkan.',
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

  String getRefundPolicyText() {
    return refundService.getRefundPolicyText(daysBeforeDeparture.value);
  }

  @override
  void onClose() {
    reason.dispose();
    bankAccount.dispose();
    bankName.dispose();
    super.onClose();
  }
}
