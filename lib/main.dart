import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'app/services/booking_service.dart';
import 'app/services/ticket_service.dart';
import 'app/services/hive_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  tz_data.initializeTimeZones();

  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('trains');

  await Get.putAsync(() => HiveService().init());
  await Get.putAsync(() => NotificationService().init());
  await Get.putAsync(() => AuthService().init());
  
  Get.put(BookingService());
  Get.put(TicketService());
  Get.put(LocationService());

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FritzLine",
      initialRoute: Routes.LOGIN_PAGE,
      getPages: AppPages.routes,
      locale: Locale('id', 'ID'),
    ),
  );
}