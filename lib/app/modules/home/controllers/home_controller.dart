import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../services/booking_service.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';
import '../views/home_view.dart';

class HomeController extends GetxController {
  final bookingService = Get.find<BookingService>();
  final authService = Get.find<AuthService>();
  final locationService = Get.find<LocationService>();

  final isLoadingStations = true.obs;
  final allStations = <Map<String, dynamic>>[].obs;

  final selectedDeparture = {"code": "", "name": "Pilih Stasiun"}.obs;
  final selectedArrival = {"code": "", "name": "Pilih Stasiun"}.obs;
  final selectedDate = DateTime.now().obs;
  final passengerCount = 1.obs;
  final isRoundTrip = false.obs;

  final CarouselSliderController newsCarouselC = CarouselSliderController();
  final currentNewsIndex = 0.obs;

  var isLoadingStasiunLBS = true.obs;
  var stasiunTerdekat = <Map<String, dynamic>>[].obs;

  final newsList = [
    {
      "id": "1",
      "kategori": "Tips",
      "judul": "Tetap jaga komunikasi selama di kereta",
      "image": "assets/images/news1.png",
    },
    {
      "id": "2",
      "kategori": "Update",
      "judul": "Protokol kesehatan terbaru di kereta",
      "image": "assets/images/news2.png",
    },
    {
      "id": "3",
      "kategori": "Promo",
      "judul": "Dapatkan diskon 20% untuk perjalanan",
      "image": "assets/images/news3.png",
    },
    {
      "id": "4",
      "kategori": "Info",
      "judul": "Jadwal KRL terbaru Jabodetabek",
      "image": "assets/images/news4.png",
    },
    {
      "id": "5",
      "kategori": "Tips",
      "judul": "Barang bawaan yang dilarang di Kereta",
      "image": "assets/images/news5.png",
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      isLoadingStations.value = true;
      final response = await http.get(
        Uri.parse("https://stasiun-api.vercel.app/stasiun_api.json"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        List<Map<String, dynamic>> tempStationList = [];

        for (var stationList in data.values) {
          tempStationList.addAll(List<Map<String, dynamic>>.from(stationList));
        }
        allStations.value = tempStationList;
        await fetchNearestStationsLBS();
      } else {
        Get.snackbar("Error", "Gagal memuat data stasiun.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal parsing data stasiun: ${e.toString()}");
    } finally {
      isLoadingStations.value = false;
    }
  }

  Future<void> fetchNearestStationsLBS() async {
    try {
      isLoadingStasiunLBS.value = true;
      if (allStations.isEmpty) {
        return;
      }
      final result = await locationService.findNearestStations(allStations, 3);
      stasiunTerdekat.assignAll(result);
    } catch (e) {
      stasiunTerdekat.clear();
      debugPrint("Error LBS: $e");
    } finally {
      isLoadingStasiunLBS.value = false;
    }
  }

  void swapCities() {
    final tempDeparture = Map<String, String>.from(selectedDeparture);
    final tempArrival = Map<String, String>.from(selectedArrival);

    selectedDeparture.value = tempArrival;
    selectedArrival.value = tempDeparture;
  }

  void incrementPassenger() {
    passengerCount.value++;
  }

  void decrementPassenger() {
    if (passengerCount.value > 1) {
      passengerCount.value--;
    }
  }

  void toggleRoundTrip(bool value) {
    isRoundTrip.value = value;
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF656CEE),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1B1B1F),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF656CEE),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  void selectStation(Map<String, dynamic> station, bool isDeparture) {
    final Map<String, String> stationMap = {
      "code": station['id'] as String,
      "name": station['nama'] as String,
    };

    if (isDeparture) {
      if (stationMap['code'] == selectedArrival['code']) {
        Get.snackbar(
          "Error",
          "Stasiun keberangkatan tidak boleh sama.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      selectedDeparture.assignAll(stationMap);
    } else {
      if (stationMap['code'] == selectedDeparture['code']) {
        Get.snackbar(
          "Error",
          "Stasiun tujuan tidak boleh sama.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      selectedArrival.assignAll(stationMap);
    }
    Get.back();
  }

  void showCitySelection(BuildContext context, bool isDeparture) {
    if (isLoadingStations.value) {
      Get.snackbar("Loading", "Sedang memuat data stasiun...");
      return;
    }

    Get.defaultDialog(
      title: "Pilih Stasiun",
      titleStyle: const TextStyle(
        color: Color(0xFF333E63),
        fontWeight: FontWeight.bold,
      ),
      content: StationSearchDialog(controller: this, isDeparture: isDeparture),
      radius: 10,
    );
  }

  void cariTiket() {
    if (selectedDeparture['code'] == "" || selectedArrival['code'] == "") {
      Get.snackbar("Error", "Harap pilih stasiun keberangkatan dan tujuan.");
      return;
    }

    bookingService.selectedDeparture.assignAll(selectedDeparture);
    bookingService.selectedArrival.assignAll(selectedArrival);
    bookingService.selectedDate.value = selectedDate.value;
    bookingService.passengerCount.value = passengerCount.value;

    Get.toNamed(Routes.DETAIL_JADWAL);
  }
}
