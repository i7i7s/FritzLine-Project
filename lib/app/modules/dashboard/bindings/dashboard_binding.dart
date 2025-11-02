import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../tiket/controllers/tiket_controller.dart';
import '../../profil/controllers/profil_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<TiketController>(
      () => TiketController(),
    );
    Get.lazyPut<ProfilController>(
      () => ProfilController(),
    );
  }
}