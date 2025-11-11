import 'package:get/get.dart';
import '../controllers/submit_review_controller.dart';

class SubmitReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubmitReviewController>(() => SubmitReviewController());
  }
}
