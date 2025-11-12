import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/review_service.dart';

class SubmitReviewController extends GetxController {
  final reviewService = Get.find<ReviewService>();

  final rating = 0.obs;
  final selectedTags = <String>[].obs;
  final commentController = TextEditingController();

  late String ticketId;
  late String trainId;
  late String trainName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      ticketId = args['ticketId'] ?? '';
      trainId = args['trainId'] ?? '';
      trainName = args['trainName'] ?? '';
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  void setRating(int value) {
    rating.value = value;
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  Future<void> submitReview() async {
    if (rating.value == 0) {
      Get.snackbar(
        "Oops!",
        "Berikan rating terlebih dahulu",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await reviewService.submitReview(
      ticketId: ticketId,
      trainId: trainId,
      trainName: trainName,
      rating: rating.value,
      comment: commentController.text.trim().isEmpty
          ? null
          : commentController.text.trim(),
      tags: selectedTags.toList(),
    );

    if (success) {
      Get.back(result: true);
    }
  }
}
