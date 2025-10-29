import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RingkasanPemesananController extends GetxController {
  // Data kereta yang dipilih (diterima dari Get.arguments)
  final trainData = {}.obs;
  // Penumpang (diterima dari home, tapi kita hardcode 1 dulu)
  final passengerCount = 1.obs;

  // State untuk ExpansionTile
  final isExpanded = true.obs;

  // Data dummy untuk penumpang tersimpan
  final savedPassengers = [
    {"nama": "Chiko Armani", "email": "chiko@armani.com"},
    {"nama": "Samsung", "email": "samsung@galaxy.com"},
    {"nama": "Ibnu Batutah", "email": "ibnu@traveler.com"},
  ].obs;

  // Data untuk form
  final List<String> idTypes = ['Paspor', 'KTP', 'SIM'];
  final selectedIdType = 'Paspor'.obs;

  // Controller untuk text fields
  // Nanti ini akan jadi List<TextEditingController> jika penumpang > 1
  late TextEditingController idNumberController;
  late TextEditingController fullNameController;

  @override
  void onInit() {
    super.onInit();
    // Ambil data kereta dari halaman sebelumnya
    if (Get.arguments != null) {
      trainData.value = Get.arguments as Map<String, dynamic>;
    }
    
    // Inisialisasi text controller
    idNumberController = TextEditingController(text: "A 38910381");
    fullNameController = TextEditingController(text: "Ibnu Batutah");
  }

  @override
  void onClose() {
    // Selalu dispose controller
    idNumberController.dispose();
    fullNameController.dispose();
    super.onClose();
  }

  // Fungsi untuk mengubah tipe ID
  void changeIdType(String? newValue) {
    if (newValue != null) {
      selectedIdType.value = newValue;
    }
  }

  // Fungsi untuk toggle expansion tile
  void toggleExpansion(bool newState) {
    isExpanded.value = newState;
  }
}