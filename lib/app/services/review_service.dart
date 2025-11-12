import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/review.dart';
import 'auth_service.dart';

class ReviewService extends GetxService {
  late Box<Review> _reviewBox;
  final authService = Get.find<AuthService>();

  final allReviews = <Review>[].obs;
  final myReviews = <Review>[].obs;

  static const List<String> AVAILABLE_TAGS = [
    "Bersih",
    "Tepat Waktu",
    "AC Dingin",
    "Nyaman",
    "Pelayanan Bagus",
    "Harga Sesuai",
    "Toilet Bersih",
    "Makanan Enak",
    "WiFi Stabil",
    "Tenang",
  ];

  Future<ReviewService> init() async {
    _reviewBox = await Hive.openBox<Review>('reviews');
    _loadReviews();
    return this;
  }

  void _loadReviews() {
    allReviews.assignAll(_reviewBox.values.toList());

    final currentUserId = authService.currentUser.value?.email ?? '';
    myReviews.assignAll(
      allReviews.where((review) => review.userId == currentUserId).toList(),
    );
  }

  bool hasReviewed(String ticketId) {
    return allReviews.any((review) => review.ticketId == ticketId);
  }

  Future<bool> submitReview({
    required String ticketId,
    required String trainId,
    required String trainName,
    required int rating,
    String? comment,
    required List<String> tags,
  }) async {
    try {
      final user = authService.currentUser.value;
      if (user == null) {
        Get.snackbar(
          "Error",
          "Anda harus login untuk memberikan review",
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (hasReviewed(ticketId)) {
        Get.snackbar(
          "Sudah Direview",
          "Anda sudah memberikan review untuk tiket ini",
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final newReview = Review(
        ticketId: ticketId,
        trainId: trainId,
        trainName: trainName,
        rating: rating,
        comment: comment,
        tags: tags,
        reviewDate: DateTime.now(),
        userId: user.email,
        userName: user.name,
      );

      await _reviewBox.add(newReview);
      _loadReviews();

      Get.snackbar(
        "Terima Kasih! ⭐",
        "Review Anda telah disimpan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF00C853),
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menyimpan review: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  List<Review> getTrainReviews(String trainId) {
    return allReviews.where((review) => review.trainId == trainId).toList()
      ..sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
  }

  double getTrainAverageRating(String trainId) {
    final trainReviews = getTrainReviews(trainId);
    if (trainReviews.isEmpty) return 0.0;

    final totalRating = trainReviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );
    return totalRating / trainReviews.length;
  }

  Map<int, int> getTrainRatingDistribution(String trainId) {
    final trainReviews = getTrainReviews(trainId);
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in trainReviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }

    return distribution;
  }

  List<MapEntry<String, int>> getTrainPopularTags(
    String trainId, {
    int limit = 5,
  }) {
    final trainReviews = getTrainReviews(trainId);
    final tagCounts = <String, int>{};

    for (var review in trainReviews) {
      for (var tag in review.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(limit).toList();
  }

  Future<bool> deleteReview(Review review) async {
    try {
      final user = authService.currentUser.value;
      if (user == null || user.email != review.userId) {
        Get.snackbar(
          "Error",
          "Anda tidak dapat menghapus review ini",
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await review.delete();
      _loadReviews();

      Get.snackbar(
        "Berhasil",
        "Review telah dihapus",
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menghapus review: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Map<String, dynamic> getTrainReviewStats(String trainId) {
    final reviews = getTrainReviews(trainId);
    final avgRating = getTrainAverageRating(trainId);
    final distribution = getTrainRatingDistribution(trainId);
    final popularTags = getTrainPopularTags(trainId);

    return {
      'totalReviews': reviews.length,
      'averageRating': avgRating,
      'distribution': distribution,
      'popularTags': popularTags,
      'recentReviews': reviews.take(5).toList(),
    };
  }
}
