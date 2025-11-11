import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/booking_service.dart';
import '../../../services/hive_service.dart';
import '../../../routes/app_pages.dart';

class DetailJadwalController extends GetxController {
  final bookingService = Get.find<BookingService>();
  final hiveService = Get.find<HiveService>();

  final departure = <String, String>{}.obs;
  final arrival = <String, String>{}.obs;
  final selectedDate = DateTime.now().obs;

  final isLoading = true.obs;
  final trainList = <Map<String, dynamic>>[].obs;
  final originalTrainList = <Map<String, dynamic>>[].obs;

  final selectedClasses = <String>["Ekonomi", "Eksekutif"].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    try {
      isLoading.value = true;

      departure.value = bookingService.selectedDeparture;
      arrival.value = bookingService.selectedArrival;
      selectedDate.value = bookingService.selectedDate.value;

      String? stasiunAsal = departure['code'];
      String? stasiunTiba = arrival['code'];

      if (stasiunAsal == null ||
          stasiunTiba == null ||
          stasiunAsal.isEmpty ||
          stasiunTiba.isEmpty) {
        throw Exception("Stasiun asal atau tujuan tidak valid.");
      }

      var results = await hiveService.cariKereta(stasiunAsal, stasiunTiba);

      originalTrainList.value = results;
      applyFilter();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat jadwal kereta: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String getFormattedDate() {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate.value);
  }

  List<DateTime> getDateRange() {
    List<DateTime> dates = [];
    for (int i = -2; i <= 2; i++) {
      dates.add(selectedDate.value.add(Duration(days: i)));
    }
    return dates;
  }

  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
    bookingService.selectedDate.value = newDate;
    _fetchInitialData();
  }

  void selectTrain(Map<String, dynamic> train) {
    bookingService.selectedTrain.value = train;
    Get.toNamed(Routes.RINGKASAN_PEMESANAN, arguments: train);
  }

  void toggleClassFilter(String className) {
    if (selectedClasses.contains(className)) {
      selectedClasses.remove(className);
    } else {
      selectedClasses.add(className);
    }
  }

  void applyFilter() {
    if (selectedClasses.isEmpty) {
      trainList.value = [];
    } else {
      trainList.value = originalTrainList.where((train) {
        String kelas = train['kelas'].toString().toLowerCase();

        bool match = false;
        if (selectedClasses.contains("Ekonomi") &&
            (kelas.contains("ekonomi") || kelas.contains("campuran"))) {
          match = true;
        }
        if (selectedClasses.contains("Eksekutif") &&
            (kelas.contains("eksekutif") || kelas.contains("campuran"))) {
          match = true;
        }
        return match;
      }).toList();
    }

    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  void showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Kelas Kereta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(
              () => CheckboxListTile(
                title: const Text("Ekonomi"),
                value: selectedClasses.contains("Ekonomi"),
                onChanged: (val) => toggleClassFilter("Ekonomi"),
                activeColor: const Color(0xFF656CEE),
              ),
            ),
            Obx(
              () => CheckboxListTile(
                title: const Text("Eksekutif"),
                value: selectedClasses.contains("Eksekutif"),
                onChanged: (val) => toggleClassFilter("Eksekutif"),
                activeColor: const Color(0xFF656CEE),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => applyFilter(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF656CEE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "TERAPKAN FILTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
