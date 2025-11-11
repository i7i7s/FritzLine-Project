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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    if (selectedDay.isAtSameMomentAs(today)) {
      try {
        String? jadwalBerangkat = train['jadwalBerangkat'];
        if (jadwalBerangkat != null && jadwalBerangkat.isNotEmpty) {
          final timeParts = jadwalBerangkat.split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final departureTime = DateTime(
              now.year,
              now.month,
              now.day,
              hour,
              minute,
            );

            final cutoffTime = now.add(const Duration(minutes: 30));
            
            if (departureTime.isBefore(cutoffTime) || departureTime.isAtSameMomentAs(cutoffTime)) {
              Get.snackbar(
                "Tidak Dapat Memesan",
                "Kereta ${train['namaKereta']} berangkat pada $jadwalBerangkat. Pemesanan harus dilakukan minimal 30 menit sebelum keberangkatan.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
              );
              return;
            }
          }
        }
      } catch (e) {
        print('Error validating departure time: $e');
      }
    }

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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
      );

      if (selectedDay.isBefore(today)) {
        trainList.value = [];
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        return;
      }

      var filteredTrains = originalTrainList.where((train) {
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

        if (!match) return false;

        if (selectedDay.isAtSameMomentAs(today)) {
          try {
            String? jadwalBerangkat = train['jadwalBerangkat'];
            if (jadwalBerangkat != null && jadwalBerangkat.isNotEmpty) {
              final timeParts = jadwalBerangkat.split(':');
              if (timeParts.length >= 2) {
                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                final departureTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  hour,
                  minute,
                );

                final cutoffTime = now.add(const Duration(minutes: 30));
                
                print('🚂 [FILTER] ${train['namaKereta']}: Jam=${jadwalBerangkat}, Cutoff=${cutoffTime.hour}:${cutoffTime.minute.toString().padLeft(2, '0')}, Pass=${departureTime.isAfter(cutoffTime)}');
                
                return departureTime.isAfter(cutoffTime);
              }
            }
          } catch (e) {
            print('❌ Error parsing time for train: $e');
            return false;
          }
        }
        return true;
      }).toList();

      filteredTrains.sort((a, b) {
        try {
          String timeA = a['jadwalBerangkat'] ?? '00:00';
          String timeB = b['jadwalBerangkat'] ?? '00:00';
                    var partsA = timeA.split(':');
          var partsB = timeB.split(':');
          
          if (partsA.length >= 2 && partsB.length >= 2) {
            int hourA = int.parse(partsA[0]);
            int minuteA = int.parse(partsA[1]);
            int hourB = int.parse(partsB[0]);
            int minuteB = int.parse(partsB[1]);
                        if (hourA != hourB) {
              return hourA.compareTo(hourB);
            }
            return minuteA.compareTo(minuteB);
          }
          
          return timeA.compareTo(timeB);
        } catch (e) {
          print('Error sorting trains: $e');
          return 0;
        }
      });
      
      trainList.value = filteredTrains;
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
