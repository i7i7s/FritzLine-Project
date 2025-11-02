import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import 'dart:async';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final isLoading = false.obs;

  void processRegister(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Semua field wajib diisi.");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Format email tidak valid.");
      return;
    }

    bool registerSuccess = false;
    isLoading.value = true;

    try {
      await Future.delayed(Duration(milliseconds: 100));

      registerSuccess = await _authService.register(
        name,
        email,
        password,
      );
    } catch (e) {
      Get.snackbar("Error Registrasi", "Terjadi kesalahan: ${e.toString()}");
      registerSuccess = false;
    } finally {
      isLoading.value = false;
    }

    if (registerSuccess) {
      Get.snackbar("Sukses", "Registrasi berhasil. Silakan login.");
      await Future.delayed(Duration(milliseconds: 200));
      Get.back();
    }
  }

  void goToLogin() {
    Get.back();
  }
}