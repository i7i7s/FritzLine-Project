import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HiveService extends GetxService {
  final String _apiBaseUrl = "https://kereta-api-production.up.railway.app";

  Future<HiveService> init() async {
    return this;
  }

  Future<List<Map<String, dynamic>>> cariKereta(
    String kodeAsal,
    String kodeTujuan, {
    DateTime? tanggalKeberangkatan,
  }) async {
    // Default ke hari ini jika tidak disediakan
    final date = tanggalKeberangkatan ?? DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    
    final uri = Uri.parse('$_apiBaseUrl/search?from=$kodeAsal&to=$kodeTujuan&date=$dateString');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> dataFromServer = json.decode(response.body);

        List<Map<String, dynamic>> results = dataFromServer.map((train) {
          return {
            "id": train['id_kereta'],
            "namaKereta": train['nama_kereta'],
            "stasiunBerangkat": kodeAsal,
            "stasiunTiba": kodeTujuan,
            "jadwalBerangkat": train['jadwalBerangkat'] ?? '??:??',
            "jadwalTiba": train['jadwalTiba'] ?? '??:??',
            "kelas": train['kelas'],
            "harga": train['harga'],
            "durasi": train['durasi'] ?? '??j ??m',
            "sisaTiket": train['sisaTiket'] ?? 0,
          };
        }).toList();

        return results;
      } else {
        throw Exception(
          'Gagal memuat data dari server (${response.statusCode})',
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error Jaringan",
        "Gagal terhubung ke server: ${e.toString()}",
      );
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAvailableSeats(
    String idKereta, {
    required DateTime tanggalKeberangkatan,
  }) async {
    final dateString = DateFormat('yyyy-MM-dd').format(tanggalKeberangkatan);
    
    final uri = Uri.parse('$_apiBaseUrl/seats/$idKereta?date=$dateString');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat data kursi (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat kursi: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<bool> bookSeats(
    String idKereta,
    List<int> seatIds, {
    required DateTime tanggalKeberangkatan,
    List<Map<String, dynamic>>? seatDetails,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/seats/book');

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(tanggalKeberangkatan);
      
      final Map<String, dynamic> requestBody = {
        'id_kereta': idKereta,
        'seat_ids': seatIds,
        'tanggal_keberangkatan': dateString,
      };
      
      if (seatDetails != null && seatDetails.isNotEmpty) {
        requestBody['seat_details'] = seatDetails;
      }
      
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        Get.snackbar(
          "Sukses",
          result['message'] ?? "Kursi berhasil di-reserve",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00C853),
          colorText: Colors.white,
        );
        return true;
      } else if (response.statusCode == 409) {
        final error = json.decode(response.body);
        Get.snackbar(
          "Kursi Tidak Tersedia",
          error['error'] ?? "Kursi sudah dibooking penumpang lain",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      } else {
        throw Exception('Booking gagal (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar(
        "Error Booking",
        "Gagal mem-booking kursi: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> releaseSeats(
    List<int> seatIds, {
    required DateTime tanggalKeberangkatan,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/seats/release');

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(tanggalKeberangkatan);
      
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'seat_ids': seatIds,
              'tanggal_keberangkatan': dateString,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Release gagal (${response.statusCode})');
      }
    } catch (e) {
      print("Error releasing seats: $e");
      return false;
    }
  }

  Future<String?> confirmBooking({
    required String idKereta,
    required DateTime tanggalKeberangkatan,
    required List<int> seatIds,
    required List<Map<String, String>> passengerData,
    required double totalPrice,
    String? kodeBooking,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/bookings/confirm');

    final dateString = DateFormat('yyyy-MM-dd').format(tanggalKeberangkatan);

    print('🚀 [API] Confirm Booking Request:');
    print('   Train ID: $idKereta');
    print('   Date: $dateString');
    print('   Seat IDs: $seatIds');
    print('   Passengers: ${passengerData.length}');
    print('   Total: $totalPrice');

    try {
      final requestBody = {
        'id_kereta': idKereta,
        'tanggal_keberangkatan': dateString,
        'seat_ids': seatIds,
        'passenger_data': passengerData,
        'total_price': totalPrice,
        'kode_booking': kodeBooking,
      };

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 20));

      print('📥 [API] Confirm Response: ${response.statusCode}');
      print('📥 [API] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ [API] Booking Confirmed! Code: ${result['kode_booking']}');
        return result['kode_booking'];
      } else {
        print('❌ [API] Confirm Failed: ${response.statusCode}');
        throw Exception('Konfirmasi booking gagal (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar(
        "Error Konfirmasi",
        "Gagal mengkonfirmasi booking: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBookingHistory(String kodeBooking) async {
    final uri = Uri.parse('$_apiBaseUrl/bookings/history/$kodeBooking');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        Get.snackbar(
          "Tidak Ditemukan",
          "Booking dengan kode $kodeBooking tidak ditemukan",
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      } else {
        throw Exception('Gagal memuat history (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal memuat history: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  @deprecated
  Future<void> kurangiStokTiket(String trainId, int jumlahBeli) async {
    print(
      "DEPRECATED: Method ini sudah tidak digunakan. Gunakan bookSeats() dan confirmBooking().",
    );
  }
}
