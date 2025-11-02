import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fritzlinee/app/services/auth_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final authService = Get.find<AuthService>();

  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();

  final isLoading = false.obs;

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    confirmPassC.dispose();
    super.onClose();
  }

  void goToLogin() {
    Get.back();
  }

  void register() async {
    if (emailC.text.isEmpty ||
        passC.text.isEmpty ||
        confirmPassC.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Semua field tidak boleh kosong.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passC.text != confirmPassC.text) {
      Get.snackbar(
        "Error",
        "Password dan Konfirmasi Password tidak cocok.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    bool registerSuccess = await authService.register(emailC.text, passC.text);
    isLoading.value = false;

    if (registerSuccess) {
      Get.snackbar(
        "Sukses",
        "Registrasi berhasil, silakan login.",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamed(Routes.LOGIN_PAGE);
    }
  }
}