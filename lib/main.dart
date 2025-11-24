import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/services/booking_service.dart';
import 'app/services/ticket_service.dart';
import 'app/services/hive_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/location_service.dart';
import 'app/services/settings_service.dart';
import 'app/services/loyalty_service.dart';
import 'app/services/encryption_service.dart';
import 'app/models/passenger.dart';
import 'app/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await initializeDateFormatting('id_ID', null);

  tz_data.initializeTimeZones();

  await Hive.initFlutter();

  Hive.registerAdapter(PassengerAdapter());
  Hive.registerAdapter(UserAdapter());

  await Get.putAsync(() => HiveService().init());
  await Get.putAsync(() => NotificationService().init());
  await Get.putAsync(() => AuthService().init());

  final ticketService = await Get.putAsync(() => TicketService().init());
  await ticketService.cleanupOldTicketsWithoutUserId();

  await Get.putAsync(() => SettingsService().init());
  await Get.putAsync(() => LoyaltyService().init());

  Get.put(EncryptionService());
  Get.put(BookingService());
  Get.put(LocationService());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FritzLine",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      locale: Locale('id', 'ID'),
    ),
  );
}
