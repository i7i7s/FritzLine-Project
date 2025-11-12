import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/loyalty_service.dart';
import '../../../services/auth_service.dart';

class LoyaltyController extends GetxController {
  final loyaltyService = Get.find<LoyaltyService>();
  final authService = Get.find<AuthService>();

  final pointsToRedeem = 0.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Reload loyalty data when page is opened to ensure correct user's data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loyaltyService.reloadLoyaltyData();
      print('💎 [LoyaltyController] Reloaded loyalty on page open');
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> showRedeemDialog() async {
    pointsToRedeem.value = 0;

    Get.dialog(
      AlertDialog(
        title: const Text('Tukar Poin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Poin Anda: ${loyaltyService.currentPoints.value}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Minimum: 100 poin = Rp 100.000',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Poin',
                border: OutlineInputBorder(),
                suffixText: 'poin',
              ),
              onChanged: (value) {
                pointsToRedeem.value = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                'Diskon: Rp ${_formatCurrency(pointsToRedeem.value * 1000)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF656CEE),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (pointsToRedeem.value > 0) {
                final discount = await loyaltyService.redeemPoints(
                  pointsToRedeem.value,
                );
                if (discount != null) {
                  Get.back();
                  Get.snackbar(
                    'Berhasil',
                    'Voucher senilai Rp ${_formatCurrency(discount)} telah dibuat',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF656CEE),
            ),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  Future<void> claimBirthdayVoucher() async {
    final voucher = await loyaltyService.claimBirthdayVoucher();
    if (voucher != null) {
      update();
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
