import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/hive_service.dart';

class SplashScreenController extends GetxController {
  final _authService = Get.find<AuthService>();
  final _hiveService = Get.find<HiveService>();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  void _initializeApp() async {
    try {
      await Future.wait([
        _seedDatabase(),
        Future.delayed(const Duration(milliseconds: 2000)),
      ]);
    } catch (e) {
      print("Error saat startup: $e");
    } finally {
      bool isLoggedIn = _authService.checkSession();
      if (isLoggedIn) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN_PAGE);
      }
    }
  }

  Future<void> _seedDatabase() async {
    try {
      await _hiveService.seedTrainDatabase();
    } catch (e) {
      print("Gagal seeding database: $e");
    }
  }
}