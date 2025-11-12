import 'package:get/get.dart';
import '../controllers/request_refund_controller.dart';

class RequestRefundBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestRefundController>(() => RequestRefundController());
  }
}
