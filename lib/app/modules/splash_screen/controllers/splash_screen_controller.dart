import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class SplashScreenController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 2));

    if (_authService.isLoggedIn.value) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN_PAGE);
    }
  }
}
