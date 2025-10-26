import 'package:get/get.dart';

import '../controllers/detail_booking_tiket_controller.dart';

class DetailBookingTiketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailBookingTiketController>(
      () => DetailBookingTiketController(),
    );
  }
}
