import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  _buildMenuGroup(
                    children: [
                      _buildSavedPassengersList(context),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: "Help Center",
                        onTap: () => controller.goToHelpCenter(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMenuGroup(
                    children: [
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: "Logout",
                        color: Colors.red.shade600,
                        onTap: () => controller.logout(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSarkasCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = controller.authService.currentUser.value;
    final userInitial = user?.name.substring(0, 2).toUpperCase() ?? '..';

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF333E63),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        gradient: LinearGradient(
          colors: [const Color(0xFF656CEE).withValues(alpha: 0.8), const Color(0xFF333E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange.shade700,
                child: Text(
                  userInitial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Nama Pengguna',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "Premium Member",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? const Color(0xFF1B1B1F);
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w500, color: itemColor, fontSize: 16),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSavedPassengersList(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(Icons.people_alt_outlined, color: Color(0xFF1B1B1F)),
        title: const Text(
          "Passenger List",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B1B1F),
              fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Obx(() {
                  final passengers = controller.authService.savedPassengers;
                  if (passengers.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("Anda belum memiliki penumpang tersimpan."),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: passengers.length,
                    itemBuilder: (context, index) {
                      final passenger = passengers[index];
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          title: Text(
                            passenger.nama,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "${passenger.idType} (${passenger.idNumber})",
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note,
                                    color: Colors.orange),
                                onPressed: () {
                                  controller.showEditPassengerDialog(
                                      index, passenger);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  controller
                                      .showDeleteConfirmationDialog(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSarkasCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: const Icon(Icons.school_outlined, color: Color(0xFF656CEE)),
        title: const Text(
          "Saran & Kesan",
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
}