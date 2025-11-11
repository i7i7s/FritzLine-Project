import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../models/passenger.dart';

class ProfilController extends GetxController {
  final authService = Get.find<AuthService>();

  final List<String> idTypes = ['KTP', 'Paspor', 'SIM'];

  void logout() {
    authService.logout();
    Get.offAllNamed(Routes.LOGIN_PAGE);
  }

  void goToHelpCenter() {
    Get.snackbar("Fitur Dalam Pengembangan",
        "Halaman 'Help Center' belum dibuat.");
  }

  void showDeleteConfirmationDialog(int index) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Hapus Penumpang"),
        content:
            const Text("Apakah Anda yakin ingin menghapus data penumpang ini?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              authService.deleteSavedPassenger(index);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showEditPassengerDialog(int index, Passenger passenger) {
    final nameController = TextEditingController(text: passenger.nama);
    final idNumberController = TextEditingController(text: passenger.idNumber);
    final selectedIdType = (passenger.idType).obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Edit Penumpang",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => DropdownButtonFormField<String>(
                    value: selectedIdType.value,
                    items: idTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        selectedIdType.value = newValue;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Jenis Identitas",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                  )),
              const SizedBox(height: 16),
              TextFormField(
                controller: idNumberController,
                decoration: InputDecoration(
                  labelText: "Nomor Identitas",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi nomor identitas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap isi nama lengkap';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final updatedPassenger = {
                  "nama": nameController.text,
                  "id_type": selectedIdType.value,
                  "id_number": idNumberController.text,
                };
                authService.updateSavedPassenger(index, updatedPassenger);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF656CEE),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}