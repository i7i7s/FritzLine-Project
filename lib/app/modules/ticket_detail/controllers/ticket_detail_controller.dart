import 'package:get/get.dart';

class TicketDetailController extends GetxController {
  final ticket = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      ticket.value = Get.arguments as Map<String, dynamic>;
    } else {
      print('Error: Invalid ticket data received');
    }
  }

  String getQrData() {
    return ticket.value['bookingCode'] ?? '';
  }
}
