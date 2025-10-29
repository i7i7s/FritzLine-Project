import 'package:get/get.dart';

import '../controllers/ringkasan_pemesanan_controller.dart';

class RingkasanPemesananBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RingkasanPemesananController>(
      () => RingkasanPemesananController(),
    );
  }
}
