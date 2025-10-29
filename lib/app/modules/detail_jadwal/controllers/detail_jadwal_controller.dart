import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailJadwalController extends GetxController {
  // Variabel untuk menyimpan data dari halaman Home
  final departure = {}.obs;
  final arrival = {}.obs;
  final selectedDate = DateTime.now().obs;

  // Variabel untuk list tanggal horizontal
  final dateList = <DateTime>[].obs;
  // Variabel untuk tanggal yang aktif (yang diklik di list horizontal)
  final activeDate = DateTime.now().obs;

  // 7 Data Kereta Dummy (DENGAN TIPE DATA YANG SUDAH DISERAGAMKAN)
  final trainList = [
    {
      "nama": "Joglosemarkerto",
      "berangkat_kode": "PWT",
      "berangkat_jam": "14.00",
      "tiba_kode": "SLO",
      "tiba_jam": "18.35",
      "harga": "149000",
      "kelas": "Ekonomi - A",
      "durasi": "6 jam 35 menit",
      "sisa_tiket": "2", // <-- DIUBAH (sebelumnya: 2)
    },
    {
      "nama": "Joglosemarkerto",
      "berangkat_kode": "PWT",
      "berangkat_jam": "06.30",
      "tiba_kode": "SLO",
      "tiba_jam": "11.35",
      "harga": "74000",
      "kelas": "Ekonomi - C",
      "durasi": "5 jam 5 menit",
      "sisa_tiket": "24", // <-- DIUBAH (sebelumnya: 24)
    },
    {
      "nama": "Bima",
      "berangkat_kode": "PWT",
      "berangkat_jam": "03.00",
      "tiba_kode": "SLO",
      "tiba_jam": "06.35",
      "harga": "335000",
      "kelas": "Eksekutif - A",
      "durasi": "3 jam 35 menit",
      "sisa_tiket": null, // Biarkan null
    },
    {
      "nama": "Bengawan",
      "berangkat_kode": "PWT",
      "berangkat_jam": "15.10",
      "tiba_kode": "SLO",
      "tiba_jam": "19.45",
      "harga": "129000",
      "kelas": "Ekonomi - B",
      "durasi": "4 jam 35 menit",
      "sisa_tiket": null, // Biarkan null
    },
    {
      "nama": "Argo Dwipangga",
      "berangkat_kode": "PWT",
      "berangkat_jam": "09.00",
      "tiba_kode": "SLO",
      "tiba_jam": "12.15",
      "harga": "380000",
      "kelas": "Eksekutif - A",
      "durasi": "3 jam 15 menit",
      "sisa_tiket": "5", // <-- DIUBAH (sebelumnya: 5)
    },
    {
      "nama": "Taksaka",
      "berangkat_kode": "PWT",
      "berangkat_jam": "11.30",
      "tiba_kode": "SLO",
      "tiba_jam": "14.40",
      "harga": "350000",
      "kelas": "Eksekutif - AA",
      "durasi": "3 jam 10 menit",
      "sisa_tiket": null, // Biarkan null
    },
    {
      "nama": "Ranggajati",
      "berangkat_kode": "PWT",
      "berangkat_jam": "18.00",
      "tiba_kode": "SLO",
      "tiba_jam": "22.30",
      "harga": "220000",
      "kelas": "Bisnis - O",
      "durasi": "4 jam 30 menit",
      "sisa_tiket": "10", // <-- DIUBAH (sebelumnya: 10)
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil arguments yang dikirim dari Home
    var args = Get.arguments;
    departure.value = args['departure'];
    arrival.value = args['arrival'];
    selectedDate.value = args['date'];
    activeDate.value = args['date']; // Set tanggal aktif = tanggal yg dipilih

    // Generate list tanggal (5 hari, 2 sebelum, 1 hari H, 2 sesudah)
    dateList.value = generateDateList(selectedDate.value);
  }

  // Fungsi untuk generate list tanggal
  List<DateTime> generateDateList(DateTime date) {
    return [
      date.subtract(const Duration(days: 2)),
      date.subtract(const Duration(days: 1)),
      date,
      date.add(const Duration(days: 1)),
      date.add(const Duration(days: 2)),
    ];
  }

  // Fungsi untuk ganti tanggal aktif
  void changeActiveDate(DateTime newDate) {
    activeDate.value = newDate;
    // Di sini Anda bisa menambahkan logic untuk filter kereta berdasarkan tanggal
    // Tapi untuk sekarang, kita hanya ganti UI
  }

  // Helper untuk format hari (SEN, SEL, RAB, ...)
  String getDayAbbreviation(DateTime date) {
    return DateFormat('E', 'id_ID').format(date).toUpperCase();
  }
}