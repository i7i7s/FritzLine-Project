import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ada di pubspec.yaml

class HomeController extends GetxController {
  // Indeks untuk Bottom Navigation Bar
  final tabIndex = 0.obs;

  // Data untuk booking card
  final passengerCount = 1.obs;
  final isRoundTrip = false.obs;
  final selectedDate = DateTime.now().obs; // Untuk date picker

  // Data Stasiun
  final List<Map<String, String>> dummyCities = [
    {"code": "PWT", "name": "Purwokerto"},
    {"code": "SLO", "name": "Solo Balapan"},
    {"code": "YK", "name": "Yogyakarta"},
    {"code": "GMR", "name": "Gambir"},
    {"code": "BD", "name": "Bandung"},
    {"code": "SGU", "name": "Surabaya Gubeng"},
  ].obs;

  // Variabel untuk menyimpan stasiun yang dipilih
  final selectedDeparture = {"code": "PWT", "name": "Purwokerto"}.obs;
  final selectedArrival = {"code": "SLO", "name": "Solo Balapan"}.obs;

  // Data Dummy untuk "Tiket saya"
  final myTicketsList = [
    {
      "id": "1",
      "nama_kereta": "Bengawan",
      "rute": "PWT - LPY",
      "status": "Besok",
    },
    {
      "id": "2",
      "nama_kereta": "Argo Dwipangga",
      "rute": "SLO - GMR",
      "status": "7 hari",
    },
    {
      "id": "3",
      "nama_kereta": "Taksaka",
      "rute": "YK - GMR",
      "status": "10 hari",
    },
  ].obs;

  // Data Dummy untuk "Berita"
  final newsList = [
    {
      "id": "1",
      "kategori": "Tips",
      "judul": "Tetap jaga komunikasi selama di kereta",
      "image": "assets/images/news1.png", // Ganti dengan path gambar Anda
    },
    {
      "id": "2",
      "kategori": "Update",
      "judul": "Protokol kesehatan terbaru di kereta",
      "image": "assets/images/news2.png", // Ganti dengan path gambar Anda
    },
    {
      "id": "3A",
      "kategori": "Promo",
      "judul": "Dapatkan diskon 20% untuk perjalanan",
      "image": "assets/images/news3.png", // Ganti dengan path gambar Anda
    },
  ].obs;

  // Fungsi untuk mengubah tab
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  // Fungsi Tukar Kota
  void swapCities() {
    final temp = selectedDeparture;
    selectedDeparture.value = selectedArrival;
    selectedArrival.value = temp;
  }

  // Fungsi untuk kartu booking
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

  // Fungsi untuk menampilkan Pilihan Kota
  void showCitySelection(BuildContext context, bool isDeparture) {
    Get.defaultDialog(
      title: "Pilih Stasiun",
      titleStyle: const TextStyle(color: Color(0xFF333E63), fontWeight: FontWeight.bold),
      content: Container(
        width: Get.width * 0.8,
        height: Get.height * 0.4,
        child: ListView.builder(
          itemCount: dummyCities.length,
          itemBuilder: (context, index) {
            final city = dummyCities[index];
            return ListTile(
              title: Text("${city['name']} (${city['code']})"),
              onTap: () {
                if (isDeparture) {
                  // Cek agar tidak sama dengan tujuan
                  if (city['code'] == selectedArrival['code']) {
                     Get.snackbar(
                      "Error",
                      "Stasiun keberangkatan tidak boleh sama dengan stasiun tujuan.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade700,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  selectedDeparture.value = city;
                } else {
                  // Cek agar tidak sama dengan keberangkatan
                  if (city['code'] == selectedDeparture['code']) {
                    Get.snackbar(
                      "Error",
                      "Stasiun tujuan tidak boleh sama dengan stasiun keberangkatan.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade700,
                      colorText: Colors.white,
                    );
                    return;
                  }
                  selectedArrival.value = city;
                }
                Get.back(); // Tutup dialog
              },
            );
          },
        ),
      ),
      radius: 10,
    );
  }

  // Fungsi untuk Memilih Tanggal
  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(), // Hanya bisa pilih mulai hari ini
      lastDate: DateTime(2026), // Batas 1 tahun ke depan
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF656CEE), // Warna utama
              onPrimary: Colors.white, // Warna teks di atas warna utama
              onSurface: Color(0xFF333E63), // Warna teks kalender
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF656CEE), // Warna tombol OK/Cancel
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

  // Helper untuk format tanggal (Contoh: "Rabu, 12 Agustus 2025")
  String getFormattedDate(DateTime date) {
    // Pastikan `main.dart` sudah menjalankan `initializeDateFormatting('id_ID', null);`
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }
}