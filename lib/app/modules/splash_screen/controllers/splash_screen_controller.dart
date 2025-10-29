import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; 
import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {
  final box = GetStorage();

  @override
  void onReady() {
    super.onReady();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); 
    bool isLoggedIn = box.read('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Get.offAllNamed(Routes.HOME); 
    } else {
      Get.offAllNamed(Routes.LOGIN_PAGE); 
    }
  }
}
