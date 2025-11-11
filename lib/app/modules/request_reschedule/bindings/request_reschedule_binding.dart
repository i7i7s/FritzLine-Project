import 'package:get/get.dart';
import '../controllers/request_reschedule_controller.dart';

class RequestRescheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestRescheduleController>(
      () => RequestRescheduleController(),
    );
  }
}
