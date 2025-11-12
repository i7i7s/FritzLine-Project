import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_service.dart';

class LoyaltyService extends GetxService {
  late Box _loyaltyBox;
  final authService = Get.find<AuthService>();

  final currentPoints = 0.obs;
  final currentTier = 'Bronze'.obs;
  final pointsToNextTier = 0.obs;

  static const int SILVER_THRESHOLD = 5000;
  static const int GOLD_THRESHOLD = 15000;
  static const int PLATINUM_THRESHOLD = 50000;

  static const double POINTS_PER_1000_IDR = 1.0;

  static const Map<String, double> TIER_MULTIPLIERS = {
    'Bronze': 1.0,
    'Silver': 1.2,
    'Gold': 1.5,
    'Platinum': 2.0,
  };

  static const Map<String, List<String>> TIER_BENEFITS = {
    'Bronze': [
      'Dapatkan 1 poin per Rp 1.000',
      'Akses ke promo eksklusif',
      'Notifikasi penawaran spesial',
    ],
    'Silver': [
      'Dapatkan 1.2 poin per Rp 1.000',
      'Diskon 5% untuk pembelian tiket',
      'Priority customer support',
      'Gratis reschedule 1x per tahun',
    ],
    'Gold': [
      'Dapatkan 1.5 poin per Rp 1.000',
      'Diskon 10% untuk pembelian tiket',
      'Lounge access di stasiun utama',
      'Gratis reschedule 3x per tahun',
      'Birthday voucher Rp 100.000',
    ],
    'Platinum': [
      'Dapatkan 2 poin per Rp 1.000',
      'Diskon 15% untuk pembelian tiket',
      'VIP lounge access',
      'Unlimited reschedule',
      'Birthday voucher Rp 250.000',
      'Dedicated account manager',
    ],
  };

  Future<LoyaltyService> init() async {
    _loyaltyBox = await Hive.openBox('loyalty_data');
    _loadUserLoyaltyData();
    return this;
  }

  void _loadUserLoyaltyData() {
    final user = authService.currentUser.value;

    print(
      '💎 [LoyaltyService] Loading loyalty for user: ${user?.email ?? "none"}',
    );

    if (user != null) {
      currentPoints.value = user.loyaltyPoints ?? 0;
      currentTier.value = _calculateTier(currentPoints.value);
      pointsToNextTier.value = _calculatePointsToNextTier(currentPoints.value);

      print(
        '✅ [LoyaltyService] Loaded ${currentPoints.value} points, tier: ${currentTier.value}',
      );
    } else {
      currentPoints.value = 0;
      currentTier.value = 'Bronze';
      pointsToNextTier.value = SILVER_THRESHOLD;

      print('⚠️ [LoyaltyService] No user, reset to default (0 points, Bronze)');
    }
  }

  void reloadLoyaltyData() {
    print('🔄 [LoyaltyService] Reloading loyalty data...');
    _loadUserLoyaltyData();
  }

  void clearLoyaltyData() {
    print('🧹 [LoyaltyService] Clearing loyalty data...');
    currentPoints.value = 0;
    currentTier.value = 'Bronze';
    pointsToNextTier.value = SILVER_THRESHOLD;
    print('✅ [LoyaltyService] Loyalty data cleared');
  }

  String _calculateTier(int points) {
    if (points >= PLATINUM_THRESHOLD) return 'Platinum';
    if (points >= GOLD_THRESHOLD) return 'Gold';
    if (points >= SILVER_THRESHOLD) return 'Silver';
    return 'Bronze';
  }

  int _calculatePointsToNextTier(int points) {
    if (points >= PLATINUM_THRESHOLD) return 0;
    if (points >= GOLD_THRESHOLD) return PLATINUM_THRESHOLD - points;
    if (points >= SILVER_THRESHOLD) return GOLD_THRESHOLD - points;
    return SILVER_THRESHOLD - points;
  }

  Future<void> earnPoints(int transactionAmountIDR) async {
    final user = authService.currentUser.value;
    if (user == null) return;

    double basePoints = transactionAmountIDR / 1000.0;

    String tier = _calculateTier(user.loyaltyPoints ?? 0);
    double multiplier = TIER_MULTIPLIERS[tier] ?? 1.0;
    int earnedPoints = (basePoints * multiplier).round();

    int newTotal = (user.loyaltyPoints ?? 0) + earnedPoints;
    user.loyaltyPoints = newTotal;
    await user.save();

    currentPoints.value = newTotal;
    currentTier.value = _calculateTier(newTotal);
    pointsToNextTier.value = _calculatePointsToNextTier(newTotal);

    await _logPointsTransaction(
      type: 'earned',
      points: earnedPoints,
      description:
          'Pembelian tiket senilai Rp ${_formatCurrency(transactionAmountIDR)}',
      transactionAmount: transactionAmountIDR,
    );

    String newTier = _calculateTier(newTotal);
    if (newTier != tier) {
      await _notifyTierUpgrade(newTier);
    }

    Get.snackbar(
      "Poin Didapat! 🎉",
      "Anda mendapat $earnedPoints poin dari pembelian ini",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<int?> redeemPoints(int pointsToRedeem) async {
    final user = authService.currentUser.value;
    if (user == null) return null;

    int currentUserPoints = user.loyaltyPoints ?? 0;

    if (pointsToRedeem > currentUserPoints) {
      Get.snackbar(
        "Poin Tidak Cukup",
        "Poin Anda hanya $currentUserPoints",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    if (pointsToRedeem < 100) {
      Get.snackbar(
        "Minimum Redeem",
        "Minimal redeem adalah 100 poin",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    int discountAmount = pointsToRedeem * 1000;

    user.loyaltyPoints = currentUserPoints - pointsToRedeem;
    await user.save();

    currentPoints.value = user.loyaltyPoints!;

    await _logPointsTransaction(
      type: 'redeemed',
      points: -pointsToRedeem,
      description:
          'Redeem poin untuk diskon Rp ${_formatCurrency(discountAmount)}',
      transactionAmount: discountAmount,
    );

    return discountAmount;
  }

  double getTierDiscount() {
    switch (currentTier.value) {
      case 'Silver':
        return 0.05;
      case 'Gold':
        return 0.10;
      case 'Platinum':
        return 0.15;
      default:
        return 0.0;
    }
  }

  int getTierColor() {
    switch (currentTier.value) {
      case 'Silver':
        return 0xFFC0C0C0;
      case 'Gold':
        return 0xFFFFD700;
      case 'Platinum':
        return 0xFFE5E4E2;
      default:
        return 0xFFCD7F32;
    }
  }

  String getTierIcon() {
    switch (currentTier.value) {
      case 'Silver':
        return '🥈';
      case 'Gold':
        return '🥇';
      case 'Platinum':
        return '💎';
      default:
        return '🥉';
    }
  }

  List<Map<String, dynamic>> getPointsHistory() {
    return _loyaltyBox.values
        .cast<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
        .reversed
        .toList();
  }

  Future<void> _logPointsTransaction({
    required String type,
    required int points,
    required String description,
    int? transactionAmount,
  }) async {
    final transaction = {
      'type': type,
      'points': points,
      'description': description,
      'transactionAmount': transactionAmount,
      'timestamp': DateTime.now().toIso8601String(),
      'tier': currentTier.value,
    };

    await _loyaltyBox.add(transaction);
  }

  Future<void> _notifyTierUpgrade(String newTier) async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(getTierColor()).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  getTierIcon(),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Selamat! 🎉",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Anda naik ke tier $newTier!",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Nikmati benefit eksklusif tier $newTier",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF656CEE),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text("Lihat Benefits"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  bool canClaimBirthdayVoucher() {
    final lastClaim = _loyaltyBox.get('last_birthday_claim');
    if (lastClaim == null) return true;

    final lastClaimDate = DateTime.parse(lastClaim);
    final now = DateTime.now();
    return now.year > lastClaimDate.year;
  }

  Future<int?> claimBirthdayVoucher() async {
    if (currentTier.value == 'Bronze' || currentTier.value == 'Silver') {
      Get.snackbar(
        "Tidak Tersedia",
        "Birthday voucher hanya untuk tier Gold & Platinum",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    if (!canClaimBirthdayVoucher()) {
      Get.snackbar(
        "Sudah Diklaim",
        "Birthday voucher hanya bisa diklaim 1x per tahun",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    int voucherAmount = currentTier.value == 'Gold' ? 100000 : 250000;

    await _loyaltyBox.put(
      'last_birthday_claim',
      DateTime.now().toIso8601String(),
    );

    Get.snackbar(
      "Selamat Ulang Tahun! 🎂",
      "Voucher Rp ${_formatCurrency(voucherAmount)} telah diberikan",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );

    return voucherAmount;
  }
}
