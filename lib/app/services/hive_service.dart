import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HiveService extends GetxService {
  final String _apiBaseUrl = "https://kereta-api-production.up.railway.app";

  Future<HiveService> init() async {
    return this;
  }

  Future<List<Map<String, dynamic>>> cariKereta(
      String kodeAsal, String kodeTujuan) async {
    final uri = Uri.parse('$_apiBaseUrl/search?from=$kodeAsal&to=$kodeTujuan');

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
            'Gagal memuat data dari server (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar(
          "Error Jaringan", "Gagal terhubung ke server: ${e.toString()}");
      return [];
    }
  }

  Future<void> kurangiStokTiket(String trainId, int jumlahBeli) async {
    print("LOG: Aksi 'kurangiStokTiket' dipanggil (belum terhubung ke API).");
  }
}