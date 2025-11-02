import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle,
                size: 100, color: Color(0xFF656CEE)),
            const SizedBox(height: 16),
            Obx(() => Text(
                  controller.authService.currentUser.value['email'] ??
                      'user@email.com',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: 8),
            const Text(
              "Member FritzLine",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              "Stasiun Terdekat Anda",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333E63),
              ),
            ),
            const SizedBox(height: 10),
            _buildNearestStationsCard(),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
              onPressed: () => controller.logout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestStationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoadingStasiun.isTrue) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Mencari stasiun terdekat..."),
                  ],
                ),
              ),
            );
          }
          
          if (controller.stasiunTerdekat.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Gagal. Pastikan GPS aktif.",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF656CEE)),
                    onPressed: () => controller.fetchNearestStations(),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: controller.stasiunTerdekat.map((stasiun) {
              return ListTile(
                leading: const Icon(Icons.train, color: Color(0xFF656CEE)),
                title: Text("${stasiun['nama']} (${stasiun['id']})"),
                subtitle: Text("${stasiun['distance_km']} km dari lokasi Anda"),
                dense: true,
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}