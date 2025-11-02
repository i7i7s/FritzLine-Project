import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fritzlinee/app/services/auth_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';

class LoginPageController extends GetxController {
  final authService = Get.find<AuthService>();

  final emailC = TextEditingController();
  final passC = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  void login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan password tidak boleh kosong.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    bool loginSuccess = await authService.login(emailC.text, passC.text);
    isLoading.value = false;

    if (loginSuccess) {
      Get.offAllNamed(Routes.HOME);
    }
  }
}