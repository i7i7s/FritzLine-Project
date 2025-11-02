import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsService extends GetxService {
  late Box _settingsBox;

  final preferredCurrency = "IDR".obs;
  final preferredTimezone = "Asia/Jakarta".obs;

  final exchangeRates = {}.obs;
  final isRatesLoading = false.obs;

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  Future<SettingsService> init() async {
    _settingsBox = await Hive.openBox('app_settings');
    preferredCurrency.value =
        _settingsBox.get('currency', defaultValue: 'IDR');
    preferredTimezone.value =
        _settingsBox.get('timezone', defaultValue: 'Asia/Jakarta');

    await fetchExchangeRates();
    return this;
  }

  Future<void> updateCurrency(String currencyCode) async {
    await _settingsBox.put('currency', currencyCode);
    preferredCurrency.value = currencyCode;
  }

  Future<void> updateTimezone(String timezoneId) async {
    await _settingsBox.put('timezone', timezoneId);
    preferredTimezone.value = timezoneId;
  }

  Future<void> fetchExchangeRates() async {
    isRatesLoading.value = true;
    try {
      final response = await http.get(Uri.parse(
          "https://v6.exchangerate-api.com/v6/574116bcb3be786574b56e56/latest/IDR"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        exchangeRates.value = data['conversion_rates'];
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data kurs mata uang.");
    } finally {
      isRatesLoading.value = false;
    }
  }

  String formatPrice(int idrPrice) {
    if (isRatesLoading.value || exchangeRates.isEmpty) {
      return currencyFormatter.format(idrPrice);
    }

    String code = preferredCurrency.value;
    double rate = (exchangeRates[code] as num? ?? 1.0).toDouble();
    double convertedPrice = idrPrice * rate;

    if (code == "IDR") {
      return NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
          .format(convertedPrice);
    }

    return NumberFormat.currency(
            locale: 'en_US', symbol: "$code ", decimalDigits: 2)
        .format(convertedPrice);
  }

  String formatTime(String? wibTimeString) {
    String zoneId = preferredTimezone.value;

    final wibTime = _parseWIB(wibTimeString);
    if (wibTime == null) return "??:??";

    final zonedTime = tz.TZDateTime.from(wibTime, tz.getLocation(zoneId));

    return DateFormat('HH:mm').format(zonedTime);
  }

  tz.TZDateTime? _parseWIB(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) return null;

    try {
      final parts = hhmm.split(':');
      final now = DateTime.now();
      return tz.TZDateTime(
        tz.getLocation('Asia/Jakarta'),
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }
}