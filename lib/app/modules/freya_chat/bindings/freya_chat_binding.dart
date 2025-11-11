import 'package:get/get.dart';
import '../controllers/freya_chat_controller.dart';

class FreyaChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FreyaChatController>(
      () => FreyaChatController(),
    );
  }
}
