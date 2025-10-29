import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting(); // Inisialisasi format tanggal
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FritzLine",
      initialRoute: Routes.HOME,
      getPages: AppPages.routes,
      locale: Locale('id', 'ID'),
    ),
  );
}
