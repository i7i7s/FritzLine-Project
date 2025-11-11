import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fritzlinee/app/services/booking_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';

class PilihKursiController extends GetxController {
  final bookingService = Get.find<BookingService>();

  final trainData = <String, dynamic>{}.obs;
  final passengerCount = 0.obs;
  final indexGerbong = 0.obs;

  final selectedSeats = <Map<String, dynamic>>[].obs;

  final namaGerbong = <String>[].obs;

  late RxList<List<Map<String, dynamic>>> gerbong;

  @override
  void onInit() {
    super.onInit();
    
    final Map<String, dynamic>? data = Get.arguments as Map<String, dynamic>?;

    if (data != null) {
      trainData.value = data;
      bookingService.selectedTrain.value = data;
    } else {
      trainData.value = bookingService.selectedTrain.value;
    }

    passengerCount.value = bookingService.passengerCount.value;
    if (passengerCount.value == 0) passengerCount.value = 1;

    gerbong = _generateAllGerbong();
  }

  RxList<List<Map<String, dynamic>>> _generateAllGerbong() {
    String kelas = trainData.value['kelas']?.toString().toLowerCase() ?? 'ekonomi';
    int jumlahGerbong = 5;
    String namaKelas = "Gerbong";

    if (kelas.contains("eksekutif")) {
      namaKelas = "Eksekutif";
      jumlahGerbong = 4;
    } else if (kelas.contains("ekonomi")) {
      namaKelas = "Ekonomi";
      jumlahGerbong = 6;
    } else if (kelas.contains("campuran")) {
      namaKelas = "Campuran";
      jumlahGerbong = 5;
    }

    namaGerbong.clear();
    for (int i = 1; i <= jumlahGerbong; i++) {
      namaGerbong.add("$namaKelas $i");
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
              "status": (baris % 4 == 0 && kolom == 'A') ||
                      (baris == 2 && kolom == 'C')
                  ? "filled"
                  : "available"
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
    final String idKursiLengkap = "$namaGerbongTerpilih - ${seat['id']}";

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
      selectedSeats.removeWhere((item) =>
          item["id"] == seat["id"] &&
          item["nama_gerbong"] == namaGerbongTerpilih);
      _showSeatSnackbar(seat["id"], namaGerbongTerpilih, false);
    } else if (status == "filled") {
      Get.snackbar("Gagal", "Kursi ${seat["id"]} sudah terisi.");
    }

    gerbong.refresh();
    update();
  }

  void _showSeatSnackbar(
      String seatId, String gerbongName, bool isSelected) {
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

  void goToNextPage() {
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

    List<String> seatIds = selectedSeats.map((seat) {
      return "${seat['nama_gerbong']} - ${seat['id']}";
    }).toList();

    bookingService.selectedSeats.value = seatIds;

    Get.toNamed(Routes.RINGKASAN_PEMESANAN);
  }
}