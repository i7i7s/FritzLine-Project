import 'package:get/get.dart';
import 'package:fritzlinee/app/services/auth_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';
import 'dart:async';

class LoginPageController extends GetxController {
  final authService = Get.find<AuthService>();
  final isLoading = false.obs;
  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  void login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan password tidak boleh kosong.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      await Future.delayed(Duration(milliseconds: 100));
      bool loginSuccess = await authService.login(email, password);

      if (loginSuccess) {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      Get.snackbar("Error Login", "Terjadi kesalahan: ${e.toString()}");
    } finally {
      if (isLoading.value) {
        isLoading.value = false;
      }
    }
  }
}
