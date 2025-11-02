import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';
import '../../home/controllers/home_controller.dart';

class ProfilController extends GetxController {
  final authService = Get.find<AuthService>();
  final locationService = Get.find<LocationService>();

  var isLoadingStasiun = true.obs;
  var stasiunTerdekat = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNearestStations();
  }

  void fetchNearestStations() async {
    try {
      isLoadingStasiun.value = true;
      
      final homeController = Get.find<HomeController>();
      if (homeController.allStations.isEmpty) {
        await homeController.fetchStations();
      }

      final result = await locationService.findNearestStations(
        homeController.allStations,
        3,
      );
      
      stasiunTerdekat.assignAll(result);

    } catch (e) {
      print("Error LBS: $e");
    } finally {
      isLoadingStasiun.value = false;
    }
  }

  void logout() {
    authService.logout();
    Get.offAllNamed(Routes.LOGIN_PAGE);
  }
}