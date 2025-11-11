import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpCenterController extends GetxController {
  var expandedFaqIndex = RxInt(-1);
  var searchQuery = ''.obs;

  final List<Map<String, String>> faqList = [
    {
      'question': 'Bagaimana cara memesan tiket kereta?',
      'answer':
          'Anda dapat memesan tiket dengan memilih stasiun keberangkatan dan tujuan, pilih tanggal perjalanan, kemudian pilih jadwal kereta yang tersedia. Setelah itu, isi data penumpang dan pilih kursi, lalu lanjutkan ke pembayaran.',
    },
    {
      'question': 'Metode pembayaran apa saja yang tersedia?',
      'answer':
          'Kami menyediakan berbagai metode pembayaran seperti transfer bank, e-wallet (GoPay, OVO, Dana, LinkAja), kartu kredit/debit, dan virtual account.',
    },
    {
      'question': 'Bagaimana cara membatalkan tiket?',
      'answer':
          'Untuk membatalkan tiket, buka menu Tiket Saya, pilih tiket yang ingin dibatalkan, lalu klik tombol "Batalkan Tiket". Pastikan membatalkan minimal 3 jam sebelum keberangkatan.',
    },
    {
      'question': 'Apakah bisa reschedule tiket?',
      'answer':
          'Ya, Anda dapat mengubah jadwal tiket maksimal 3 jam sebelum keberangkatan. Biaya reschedule akan disesuaikan dengan kebijakan yang berlaku.',
    },
    {
      'question': 'Bagaimana jika lupa membawa e-ticket?',
      'answer':
          'E-ticket Anda dapat diakses kapan saja melalui aplikasi di menu "Tiket Saya". Anda juga bisa melakukan screenshot atau menyimpannya sebagai PDF untuk berjaga-jaga.',
    },
    {
      'question': 'Apakah harga tiket sudah termasuk bagasi?',
      'answer':
          'Ya, harga tiket sudah termasuk bagasi sesuai dengan kebijakan masing-masing kelas kereta. Pastikan membawa bagasi sesuai ketentuan yang berlaku.',
    },
    {
      'question': 'Bagaimana cara menghubungi customer service?',
      'answer':
          'Anda dapat menghubungi customer service kami melalui WhatsApp, email, atau telepon yang tersedia di menu Contact Us.',
    },
    {
      'question': 'Apakah ada diskon untuk pelajar atau lansia?',
      'answer':
          'Ya, kami menyediakan diskon khusus untuk pelajar dan lansia. Syarat dan ketentuan berlaku. Silakan hubungi customer service untuk informasi lebih lanjut.',
    },
  ];

  final List<Map<String, dynamic>> quickActions = [
    {
      'icon': Icons.receipt_long_rounded,
      'title': 'Cara Pesan Tiket',
      'description': 'Panduan lengkap pemesanan',
      'color': Color(0xFF656CEE),
    },
    {
      'icon': Icons.payment_rounded,
      'title': 'Metode Pembayaran',
      'description': 'Lihat opsi pembayaran',
      'color': Color(0xFFFF6B35),
    },
    {
      'icon': Icons.cancel_rounded,
      'title': 'Pembatalan Tiket',
      'description': 'Syarat & ketentuan',
      'color': Color(0xFF00C853),
    },
    {
      'icon': Icons.schedule_rounded,
      'title': 'Reschedule',
      'description': 'Ubah jadwal perjalanan',
      'color': Color(0xFFFFB300),
    },
  ];

  final List<Map<String, dynamic>> contactOptions = [
    {
      'icon': Icons.phone_rounded,
      'title': 'Telepon',
      'subtitle': '021-1234-5678',
      'action': 'tel:02112345678',
      'color': Color(0xFF656CEE),
    },
    {
      'icon': Icons.email_rounded,
      'title': 'Email',
      'subtitle': 'support@fritzline.com',
      'action': 'mailto:support@fritzline.com',
      'color': Color(0xFFFF6B35),
    },
    {
      'icon': Icons.chat_rounded,
      'title': 'WhatsApp',
      'subtitle': '+62 812-3456-7890',
      'action': 'https://wa.me/6281234567890',
      'color': Color(0xFF25D366),
    },
    {
      'icon': Icons.language_rounded,
      'title': 'Website',
      'subtitle': 'www.fritzline.com',
      'action': 'https://www.fritzline.com',
      'color': Color(0xFF333E63),
    },
  ];

  void toggleFaq(int index) {
    if (expandedFaqIndex.value == index) {
      expandedFaqIndex.value = -1;
    } else {
      expandedFaqIndex.value = index;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Map<String, String>> getFilteredFaqs() {
    if (searchQuery.value.isEmpty) {
      return faqList;
    }
    return faqList
        .where(
          (faq) =>
              faq['question']!.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              faq['answer']!.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  void launchContact(String url, String title) {
    Get.snackbar(
      'Kontak',
      '$title: $url',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF656CEE),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  void showQuickActionDetail(String title) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF656CEE), Color(0xFF4147D5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333E63),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Informasi detail tentang $title akan segera tersedia. Untuk bantuan lebih lanjut, silakan hubungi customer service kami.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF656CEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
