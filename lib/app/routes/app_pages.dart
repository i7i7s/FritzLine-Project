import 'package:get/get.dart';

import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/detail_booking_tiket/bindings/detail_booking_tiket_binding.dart';
import '../modules/detail_booking_tiket/views/detail_booking_tiket_view.dart';
import '../modules/detail_jadwal/bindings/detail_jadwal_binding.dart';
import '../modules/detail_jadwal/views/detail_jadwal_view.dart';
import '../modules/login_page/controllers/login_page_controller.dart';
import '../modules/login_page/views/login_page_view.dart';
import '../modules/pilih_kursi/bindings/pilih_kursi_binding.dart';
import '../modules/pilih_kursi/views/pilih_kursi_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/register/controllers/register_controller.dart';
import '../modules/register/views/register_view.dart';
import '../modules/ringkasan_pemesanan/bindings/ringkasan_pemesanan_binding.dart';
import '../modules/ringkasan_pemesanan/views/ringkasan_pemesanan_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/tiket/bindings/tiket_binding.dart';
import '../modules/tiket/views/tiket_view.dart';
import '../modules/help_center/bindings/help_center_binding.dart';
import '../modules/help_center/views/help_center_view.dart';
import '../modules/freya_chat/bindings/freya_chat_binding.dart';
import '../modules/freya_chat/views/freya_chat_view.dart';
import '../modules/ticket_detail/bindings/ticket_detail_binding.dart';
import '../modules/ticket_detail/views/ticket_detail_view.dart';
import '../modules/loyalty/bindings/loyalty_binding.dart';
import '../modules/loyalty/views/loyalty_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.PILIH_KURSI,
      page: () => const PilihKursiView(),
      binding: PilihKursiBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_BOOKING_TIKET,
      page: () => const DetailBookingTiketView(),
      binding: DetailBookingTiketBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_PAGE,
      page: () => const LoginPageView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginPageController>(
          () => LoginPageController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<RegisterController>(
          () => RegisterController(),
          fenix: true,
        );
      }),
    ),
    GetPage(
      name: _Paths.DETAIL_JADWAL,
      page: () => const DetailJadwalView(),
      binding: DetailJadwalBinding(),
    ),
    GetPage(
      name: _Paths.RINGKASAN_PEMESANAN,
      page: () => const RingkasanPemesananView(),
      binding: RingkasanPemesananBinding(),
    ),
    GetPage(
      name: _Paths.TIKET,
      page: () => const TiketView(),
      binding: TiketBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.HELP_CENTER,
      page: () => const HelpCenterView(),
      binding: HelpCenterBinding(),
    ),
    GetPage(
      name: _Paths.FREYA_CHAT,
      page: () => const FreyaChatView(),
      binding: FreyaChatBinding(),
    ),
    GetPage(
      name: _Paths.TICKET_DETAIL,
      page: () => const TicketDetailView(),
      binding: TicketDetailBinding(),
    ),
    GetPage(
      name: _Paths.LOYALTY,
      page: () => const LoyaltyView(),
      binding: LoyaltyBinding(),
    ),
  ];
}
