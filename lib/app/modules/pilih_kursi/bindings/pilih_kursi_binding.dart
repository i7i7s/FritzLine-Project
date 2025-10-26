import 'package:get/get.dart';

import '../controllers/pilih_kursi_controller.dart';

class PilihKursiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilihKursiController>(
      () => PilihKursiController(),
    );
  }
}
