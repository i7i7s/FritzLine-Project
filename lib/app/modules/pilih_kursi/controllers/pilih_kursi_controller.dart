import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fritzlinee/app/services/booking_service.dart';
import 'package:fritzlinee/app/services/hive_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';

class PilihKursiController extends GetxController {
  final bookingService = Get.find<BookingService>();
  final hiveService = Get.find<HiveService>();

  final trainData = <String, dynamic>{}.obs;
  final passengerCount = 0.obs;
  final indexGerbong = 0.obs;

  final selectedSeats = <Map<String, dynamic>>[].obs;

  final namaGerbong = <String>[].obs;

  late RxList<List<Map<String, dynamic>>> gerbong;

  var isLoadingSeats = true.obs;
  var serverSeatData = <String, dynamic>{}.obs;
  var bookedSeatNumbers = <String>[].obs;
  var myBookedSeatIds = <int>[].obs;

  Timer? _bookingTimer;
  var remainingSeconds = 900.obs;
  var isTimerActive = false.obs;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic>? data = Get.arguments as Map<String, dynamic>?;

    if (data != null) {
      trainData.value = data;
      bookingService.selectedTrain.value = data;
    } else {
      trainData.value = Map<String, dynamic>.from(bookingService.selectedTrain);
    }

    passengerCount.value = bookingService.passengerCount.value;
    if (passengerCount.value == 0) passengerCount.value = 1;

    selectedSeats.clear();
    myBookedSeatIds.clear();
    bookedSeatNumbers.clear();
    isTimerActive.value = false;
    remainingSeconds.value = 900;

    gerbong = _generateAllGerbong();

    loadSeatsFromServer();
  }

  @override
  void onReady() {
    super.onReady();
    loadSeatsFromServer();
  }

  void refreshSeats() {
    selectedSeats.clear();
    myBookedSeatIds.clear();
    bookedSeatNumbers.clear();
    isTimerActive.value = false;
    _bookingTimer?.cancel();
    loadSeatsFromServer();
  }

  @override
  void onClose() {
    _bookingTimer?.cancel();
    if (myBookedSeatIds.isNotEmpty && isTimerActive.value) {
      hiveService.releaseSeats(myBookedSeatIds);
    }
    super.onClose();
  }

  RxList<List<Map<String, dynamic>>> _generateAllGerbong() {
    String kelas = trainData['kelas']?.toString().toLowerCase() ?? 'ekonomi';
    int jumlahGerbong = 5;

    if (kelas.contains("eksekutif")) {
      jumlahGerbong = 4;
    } else if (kelas.contains("ekonomi")) {
      jumlahGerbong = 6;
    } else if (kelas.contains("campuran")) {
      jumlahGerbong = 5;
    }

    namaGerbong.clear();

    if (kelas.contains("campuran")) {
      for (int i = 1; i <= 2; i++) {
        namaGerbong.add("Eksekutif $i");
      }
      for (int i = 1; i <= 3; i++) {
        namaGerbong.add("Ekonomi $i");
      }
    } else {
      String namaKelas = kelas.contains("eksekutif") ? "Eksekutif" : "Ekonomi";
      for (int i = 1; i <= jumlahGerbong; i++) {
        namaGerbong.add("$namaKelas $i");
      }
    }

    return List.generate(namaGerbong.length, (indexGerbong) {
      return _generateSingleGerbongLayout();
    }).obs;
  }

  List<Map<String, dynamic>> _generateSingleGerbongLayout() {
    List<Map<String, dynamic>> layout = [];
    List<String> columns = ['A', 'B', 'LORONG', 'C', 'D'];

    for (int baris = 1; baris <= 13; baris++) {
      for (String kolom in columns) {
        if (kolom == 'LORONG') {
          layout.add({"id": "LORONG", "status": "aisle"});
        } else {
          String seatId = "$kolom$baris";
          if (baris == 13 && (kolom == 'C' || kolom == 'D')) {
            layout.add({"id": "KOSONG", "status": "empty"});
          } else {
            layout.add({
              "id": seatId,
              "status":
                  (baris % 4 == 0 && kolom == 'A') ||
                      (baris == 2 && kolom == 'C')
                  ? "filled"
                  : "available",
            });
          }
        }
      }
    }
    return layout;
  }

  void gantiGerbong(int index) {
    indexGerbong.value = index;
    update();
  }

  void selectKursi(int indexKursi) {
    final seat = gerbong[indexGerbong.value][indexKursi];
    final String status = seat["status"];
    final String namaGerbongTerpilih = namaGerbong[indexGerbong.value];

    if (status == "available") {
      if (selectedSeats.length >= passengerCount.value) {
        Get.snackbar(
          "Gagal",
          "Jumlah kursi yang dipilih tidak boleh melebihi jumlah penumpang (${passengerCount.value}).",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      seat.update("status", (value) => "selected");
      seat["nama_gerbong"] = namaGerbongTerpilih;
      selectedSeats.add(seat);
      _showSeatSnackbar(seat["id"], namaGerbongTerpilih, true);
    } else if (status == "selected") {
      seat.update("status", (value) => "available");
      selectedSeats.removeWhere(
        (item) =>
            item["id"] == seat["id"] &&
            item["nama_gerbong"] == namaGerbongTerpilih,
      );
      _showSeatSnackbar(seat["id"], namaGerbongTerpilih, false);
    } else if (status == "filled") {
      Get.snackbar("Gagal", "Kursi ${seat["id"]} sudah terisi.");
    }

    gerbong.refresh();
    update();
  }

  void _showSeatSnackbar(String seatId, String gerbongName, bool isSelected) {
    Get.snackbar(
      isSelected ? "Berhasil Memilih Kursi" : "Pilihan Dibatalkan",
      isSelected
          ? "Memilih kursi $seatId di gerbong $gerbongName"
          : "Membatalkan pilihan kursi $seatId di gerbong $gerbongName",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.deepPurpleAccent.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> goToNextPage() async {
    if (selectedSeats.length != passengerCount.value) {
      Get.snackbar(
        "Gagal",
        "Jumlah kursi (${selectedSeats.length}) tidak sesuai dengan jumlah penumpang (${passengerCount.value}).",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedSeats.isEmpty) {
      Get.snackbar(
        "Gagal",
        "Anda belum memilih kursi.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await bookSelectedSeatsToServer();
    if (!success) {
      await loadSeatsFromServer();
      return;
    }

    List<String> seatIds = selectedSeats.map((seat) {
      return "${seat['nama_gerbong']} - ${seat['id']}";
    }).toList();

    bookingService.selectedSeats.value = seatIds;

    Get.offNamed(Routes.RINGKASAN_PEMESANAN);
  }

  Future<void> loadSeatsFromServer() async {
    isLoadingSeats.value = true;

    try {
      final idKereta = trainData['id']?.toString() ?? '';
      if (idKereta.isEmpty) {
        isLoadingSeats.value = false;
        return;
      }

      final result = await hiveService.getAvailableSeats(idKereta);

      if (result != null) {
        serverSeatData.value = result;
        final gerbongData = result['gerbong'] as Map<String, dynamic>?;
        if (gerbongData != null) {
          List<String> bookedNumbers = [];

          gerbongData.forEach((gerbongName, seats) {
            if (seats is List) {
              for (var seat in seats) {
                if (seat['is_booked'] == true) {
                  bookedNumbers.add(seat['nomor_kursi']);
                }
              }
            }
          });

          bookedSeatNumbers.value = bookedNumbers;
          _updateLocalSeatsWithServerData();
        }
      }
    } catch (e) {
      print("Error loading seats: $e");
    } finally {
      isLoadingSeats.value = false;
    }
  }

  void _updateLocalSeatsWithServerData() {
    selectedSeats.clear();

    final gerbongData = serverSeatData['gerbong'] as Map<String, dynamic>?;
    if (gerbongData == null) {
      gerbong.refresh();
      return;
    }

    for (int gIdx = 0; gIdx < gerbong.length; gIdx++) {
      for (int sIdx = 0; sIdx < gerbong[gIdx].length; sIdx++) {
        final seat = gerbong[gIdx][sIdx];
        final seatId = seat['id'];

        if (seatId == 'LORONG' || seatId == 'KOSONG') continue;
        if (seat['status'] != 'aisle' && seat['status'] != 'empty') {
          seat['status'] = 'available';
        }
      }
    }

    for (int gIdx = 0; gIdx < gerbong.length; gIdx++) {
      final gerbongName = namaGerbong[gIdx];

      if (gerbongData.containsKey(gerbongName)) {
        final seats = gerbongData[gerbongName] as List?;

        if (seats != null) {
          for (var serverSeat in seats) {
            if (serverSeat['is_booked'] == true) {
              final nomorKursi = serverSeat['nomor_kursi'];

              for (int sIdx = 0; sIdx < gerbong[gIdx].length; sIdx++) {
                final localSeat = gerbong[gIdx][sIdx];
                if (localSeat['id'] == nomorKursi) {
                  localSeat['status'] = 'filled';
                  break;
                }
              }
            }
          }
        }
      }
    }

    gerbong.refresh();
  }

  Future<bool> bookSelectedSeatsToServer() async {
    if (selectedSeats.isEmpty) return false;

    for (var selectedSeat in selectedSeats) {
      final seatNumber = selectedSeat['id'];
      if (bookedSeatNumbers.contains(seatNumber)) {
        Get.snackbar(
          "Error",
          "Kursi $seatNumber sudah dibooking. Silakan refresh halaman.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await loadSeatsFromServer();
        return false;
      }
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF656CEE)),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      List<int> seatIds = [];
      final gerbongData = serverSeatData['gerbong'] as Map<String, dynamic>?;

      if (gerbongData != null) {
        for (var selectedSeat in selectedSeats) {
          final seatNumber = selectedSeat['id'];
          final gerbongName = selectedSeat['nama_gerbong'];

          if (gerbongData.containsKey(gerbongName)) {
            final seats = gerbongData[gerbongName] as List;
            for (var seat in seats) {
              if (seat['nomor_kursi'] == seatNumber) {
                seatIds.add(seat['id_kursi']);
                break;
              }
            }
          }
        }
      }

      if (seatIds.isEmpty) {
        Get.back();
        Get.snackbar(
          "Error",
          "Gagal mendapatkan ID kursi. Silakan coba lagi.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final success = await hiveService.bookSeats(
        trainData['id'].toString(),
        seatIds,
      );

      Get.back();

      if (success) {
        myBookedSeatIds.value = seatIds;
        startBookingTimer();
        return true;
      }

      return false;
    } catch (e) {
      Get.back();
      print("Error booking seats: $e");
      return false;
    }
  }

  void startBookingTimer() {
    remainingSeconds.value = 900;
    isTimerActive.value = true;

    _bookingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        isTimerActive.value = false;
        releaseMySeats();
        Get.back();
        Get.snackbar(
          "Waktu Habis",
          "Booking Anda telah dibatalkan karena melebihi batas waktu 15 menit",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    });
  }

  Future<void> releaseMySeats() async {
    if (myBookedSeatIds.isNotEmpty) {
      await hiveService.releaseSeats(myBookedSeatIds);
      myBookedSeatIds.clear();
      isTimerActive.value = false;
      _bookingTimer?.cancel();
    }
  }

  String getFormattedTime() {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool isSeatAvailableInServer(String seatNumber) {
    return !bookedSeatNumbers.contains(seatNumber);
  }
}
