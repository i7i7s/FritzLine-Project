import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profil_controller.dart';
import '../../../routes/app_pages.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  static const pageBackgroundColor = Color(0xFFF5F7FA);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildLoyaltyPreview(),
                  const SizedBox(height: 16),
                  _buildSavedPassengersList(context),
                  const SizedBox(height: 16),
                  _buildHelpCenterCard(),
                  const SizedBox(height: 16),
                  _buildLogoutCard(),
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
    const gradientColor1 = Color(0xFF656CEE);  
    const gradientColor2 = Color(0xFF4147D5); 
    const avatarBgColor = Color(0xFFFF6B35);   
    const badgeBgColor = Colors.white;         
    const textColor = Colors.white;           
    const badgeIconColor = Color(0xFFFFD700); 
    
    final user = controller.authService.currentUser.value;
    final userInitial = user?.name.substring(0, 2).toUpperCase() ?? '..';

    return Container(
      padding: const EdgeInsets.only(bottom: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientColor1, gradientColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: avatarBgColor,
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Nama Pengguna',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBgColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: badgeIconColor,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Premium Member",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltyPreview() {
    const gradientColor1 = Color(0xFFFFD700);  
    const gradientColor2 = Color(0xFFFFA500);  
    const iconBgColor = Colors.white;        
    const textColor = Colors.white;         
    
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.LOYALTY),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [gradientColor1, gradientColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColor1.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: textColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Loyalty Rewards",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text("✨", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Dapatkan poin & benefit eksklusif",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: textColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCenterCard() {
    const cardBackgroundColor = Colors.white;  
    const iconColor = Color(0xFF656CEE);    
    const titleColor = Color(0xFF1B1B1F);     
    
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.goToHelpCenter(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Help Center",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Bantuan dan dukungan",
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF49454F).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    const cardBackgroundColor = Colors.white;  
    const iconColor = Color(0xFFE53935);     
    const titleColor = Color(0xFFE53935);  
    
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.logout(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Logout",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Keluar dari akun",
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF49454F).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedPassengersList(BuildContext context) {
    const cardBgColor = Colors.white;          
    const iconBgColor = Color(0xFF656CEE);    
    const iconColor = Color(0xFF656CEE);       
    const titleColor = Color(0xFF1B1B1F);    
    const subtitleColor = Color(0xFF49454F);   
    const itemGradient1 = Color(0xFF656CEE);  
    const itemGradient2 = Color(0xFF4147D5);  
    
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: iconColor,
              size: 24,
            ),
          ),
          title: const Text(
            "Passenger List",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: titleColor,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            "Kelola data penumpang",
            style: TextStyle(fontSize: 13, color: subtitleColor),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade400,
          ),
          children: [
            Obx(() {
              final passengers = controller.authService.savedPassengers;
              if (passengers.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_alt_rounded,
                        size: 48,
                        color: iconColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada penumpang tersimpan",
                        style: TextStyle(
                          color: subtitleColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: passengers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final passenger = passengers[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: iconBgColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [itemGradient1, itemGradient2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                passenger.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${passenger.idType} • ${passenger.idNumber}",
                                style: TextStyle(
                                  color: subtitleColor.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Color(0xFFFF6B35),
                            size: 20,
                          ),
                          onPressed: () {
                            controller.showEditPassengerDialog(
                              index,
                              passenger,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          onPressed: () {
                            controller.showDeleteConfirmationDialog(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSarkasCard() {
    const cardBgColor = Colors.white;          
    const iconGradient1 = Color(0xFF656CEE);    
    const iconGradient2 = Color(0xFFFF6B35);   
    const iconColor = Colors.white;            
    const titleColor = Color(0xFF1B1B1F);       
    const subtitleColor = Color(0xFF49454F);    
    const saranBadgeBg = Color(0xFF656CEE);    
    const kesanBadgeBg = Color(0xFFFF6B35);     
    const contentBgColor = Color(0xFFF5F7FA);   
    const textColor = Color(0xFF1B1B1F);       
    
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [iconGradient1, iconGradient2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: iconColor,
              size: 24,
            ),
          ),
          title: const Text(
            "Saran & Kesan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          subtitle: const Text(
            "Feedback mahasiswa",
            style: TextStyle(fontSize: 13, color: subtitleColor),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade400,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: contentBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: saranBadgeBg.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "SARAN",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: saranBadgeBg,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Karena proyeknya katanya 'simple banget' dan 'sesimple itu', mungkin bisa ditambahkan fitur-fitur yang lebih menantang seperti: real-time chat dengan WebSocket, payment gateway integration, push notification system, advanced analytics dashboard, atau machine learning untuk recommendation system. Dengan begitu, kita bisa merasakan seberapa 'simple' sebenarnya membuat aplikasi production-ready yang kompleks.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kesanBadgeBg.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "KESAN",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: kesanBadgeBg,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Mata kuliah Pemrograman Mobile memberikan pengalaman berharga dalam mengembangkan aplikasi berbasis Flutter. Melalui proyek ini, saya belajar banyak tentang state management, API integration, database lokal, dan UI/UX design. Tantangan yang dihadapi selama pengerjaan membuat saya lebih memahami kompleksitas development aplikasi mobile yang sesungguhnya. Terima kasih atas bimbingan dan ilmu yang telah diberikan selama semester ini.",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "— Muhammad Daffa Alwafi",
                      style: TextStyle(
                        color: subtitleColor.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
