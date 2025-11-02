import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 16),
              Obx(() => Text(
                    controller.authService.currentUser.value['name'] ??
                        'Muhammad Daffa Alwafi',
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
              _buildSarkasExpansionTile(),
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
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label:
                    const Text("LOGOUT", style: TextStyle(color: Colors.white)),
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
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('assets/images/profile.jpg'),
            fit: BoxFit.cover,
          ),
          border: Border.all(color: const Color(0xFF656CEE), width: 3),
        ),
      ),
    );
  }

  Widget _buildSarkasExpansionTile() {
    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.school_outlined, color: Color(0xFF656CEE)),
        title: const Text(
          "Saran & Kesan Mata Kuliah PAM",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333E63),
          ),
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                .copyWith(top: 0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Saran:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "Mungkin waktu pengerjaan proyek bisa diperpanjang sedikit, seperti dari 1 minggu menjadi 6 bulan. Agar otak kami punya waktu untuk sekadar menghirup udara segar di luar VS Code.",
          ),
          const SizedBox(height: 10),
          const Text(
            "Kesan:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "Mata kuliah ini mengajarkan saya betapa cepatnya tenggat waktu itu tiba. Sangat mendidik, terutama dalam manajemen stres dan mencari solusi di jam 3 pagi. Nilai A adalah bonus, pencerahan ini adalah hadiah sesungguhnya.",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "- Muhammad Daffa Alwafi",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 10),
        ],
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