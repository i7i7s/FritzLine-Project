import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fritzlinee/app/services/booking_service.dart';
import 'package:fritzlinee/app/services/auth_service.dart';
import 'package:fritzlinee/app/services/hive_service.dart';
import 'package:fritzlinee/app/services/encryption_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';
import '../../../models/passenger.dart';
import '../../pilih_kursi/controllers/pilih_kursi_controller.dart';
import '../../../models/passenger_type.dart';

class PassengerFormControllers {
  final TextEditingController fullNameController;
  final TextEditingController idNumberController;
  final RxString selectedIdType;
  final Rx<PassengerType> passengerType;
  final RxString selectedGender;
  final RxBool isExpanded;
  final RxBool savePassenger;
  final int passengerIndex;

  PassengerFormControllers(this.passengerIndex)
    : fullNameController = TextEditingController(),
      idNumberController = TextEditingController(),
      selectedIdType = 'KTP'.obs,
      passengerType = PassengerType.adult.obs,
      selectedGender = 'Laki-laki'.obs,
      isExpanded = true.obs,
      savePassenger = false.obs;

  void dispose() {
    fullNameController.dispose();
    idNumberController.dispose();
  }
}

class RingkasanPemesananController extends GetxController {
  final bookingService = Get.find<BookingService>();
  final authService = Get.find<AuthService>();
  final hiveService = Get.find<HiveService>();
  final encryptionService = Get.find<EncryptionService>();

  final trainData = <String, dynamic>{}.obs;
  final passengerCount = 0.obs;

  final savedPassengers = <Passenger>[].obs;

  final List<String> idTypes = ['KTP', 'Paspor', 'SIM'];
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  final formList = <PassengerFormControllers>[].obs;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic>? data = Get.arguments as Map<String, dynamic>?;
    if (data != null) {
      trainData.value = data;
      bookingService.selectedTrain.value = data;
    } else {
      trainData.value = Map<String, dynamic>.from(bookingService.selectedTrain);
    }

    passengerCount.value = bookingService.totalAllPassengers;
    savedPassengers.assignAll(authService.savedPassengers);

    if (passengerCount.value <= 0) {
      passengerCount.value = 1;
    }

    bookingService.selectedSeats.clear();

    int currentIndex = 0;
    
    for (int i = 0; i < bookingService.adultCount.value; i++) {
      final form = PassengerFormControllers(currentIndex);
      form.passengerType.value = PassengerType.adult;
      formList.add(form);
      currentIndex++;
    }
    
    for (int i = 0; i < bookingService.childWithSeatCount.value; i++) {
      final form = PassengerFormControllers(currentIndex);
      form.passengerType.value = PassengerType.childWithSeat;
      formList.add(form);
      currentIndex++;
    }
    
    for (int i = 0; i < bookingService.infantCount.value; i++) {
      final form = PassengerFormControllers(currentIndex);
      form.passengerType.value = PassengerType.infant;
      formList.add(form);
      currentIndex++;
    }
  }

  @override
  void onClose() {
    for (var form in formList) {
      form.dispose();
    }
    super.onClose();
  }

  void cancelBookingAndGoBack() {
    if (Get.isRegistered<PilihKursiController>()) {
      final pilihKursiController = Get.find<PilihKursiController>();
      if (pilihKursiController.myBookedSeatIds.isNotEmpty) {
        hiveService.releaseSeats(
          pilihKursiController.myBookedSeatIds,
          tanggalKeberangkatan: bookingService.selectedDate.value,
        );
      }
    }
    Get.until((route) => route.settings.name == Routes.DETAIL_JADWAL);
  }

  void changeIdType(int index, String? newValue) {
    if (newValue != null) {
      formList[index].selectedIdType.value = newValue;
    }
  }

  void changeGender(int index, String? newValue) {
    if (newValue != null) {
      formList[index].selectedGender.value = newValue;
    }
  }

  void toggleExpansion(int index, bool newState) {
    formList[index].isExpanded.value = newState;
  }

  void toggleSavePassenger(int index, bool? newValue) {
    if (newValue != null) {
      formList[index].savePassenger.value = newValue;
    }
  }

  void applySavedPassenger(Passenger passenger) {
    int emptyFormIndex = -1;
    for (int i = 0; i < formList.length; i++) {
      if (formList[i].fullNameController.text.isEmpty) {
        emptyFormIndex = i;
        break;
      }
    }

    if (emptyFormIndex != -1) {
      formList[emptyFormIndex].fullNameController.text = passenger.nama;
      formList[emptyFormIndex].idNumberController.text = passenger.idNumber;
      formList[emptyFormIndex].selectedIdType.value = passenger.idType;
    } else {
      Get.snackbar("Penuh", "Semua form penumpang sudah terisi.");
    }
  }

  Future<void> goToPilihKursi() async {
    List<Map<String, String>> passengersToBook = [];
    List<PassengerInfo> passengerInfos = [];

    for (int i = 0; i < formList.length; i++) {
      var form = formList[i];
      if (form.fullNameController.text.isEmpty ||
          form.idNumberController.text.isEmpty) {
        Get.snackbar("Error", "Harap isi semua data untuk Penumpang ${i + 1}.");
        return;
      }

      Map<String, String> passenger = {
        "nama": form.fullNameController.text,
        "id_type": form.selectedIdType.value,
        "id_number": form.idNumberController.text,
      };

      passengersToBook.add(passenger);

      final passengerInfo = PassengerInfo.fromType(
        type: form.passengerType.value,
        name: form.fullNameController.text,
        idNumber: form.idNumberController.text,
        idType: form.selectedIdType.value,
        passengerIndex: i,
        gender: form.selectedGender.value,
      );
      passengerInfos.add(passengerInfo);

      if (form.savePassenger.value) {
        await authService.addSavedPassenger(passenger);
      }
    }

    bookingService.passengerData.value = passengersToBook;
    bookingService.passengerInfoList.value = passengerInfos;
    
    final trainDataWithDate = Map<String, dynamic>.from(trainData);
    trainDataWithDate['tanggal_keberangkatan'] = bookingService.selectedDate.value;
    
    Get.toNamed(
      Routes.PILIH_KURSI,
      arguments: trainDataWithDate,
    );
  }

  void goToDetailBooking() {
    Get.toNamed(Routes.DETAIL_BOOKING_TIKET);
  }

  Future<void> confirmBookingToServer() async {
    for (int i = 0; i < formList.length; i++) {
      var form = formList[i];
      if (form.fullNameController.text.isEmpty ||
          form.idNumberController.text.isEmpty) {
        Get.snackbar(
          "Data Tidak Lengkap",
          "Harap isi semua data untuk Penumpang ${i + 1}.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    }

    PilihKursiController? pilihKursiController;
    try {
      pilihKursiController = Get.find<PilihKursiController>();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mendapatkan data kursi. Silakan pilih kursi kembali.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final seatIds = pilihKursiController.myBookedSeatIds;

    if (seatIds.isEmpty) {
      Get.snackbar(
        "Error",
        "Tidak ada kursi yang di-book. Silakan pilih kursi terlebih dahulu.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    List<Map<String, String>> passengerData = formList.map((form) {
      final encryptedIdNumber = encryptionService.encryptData(form.idNumberController.text);
      
      return {
        'nama': form.fullNameController.text,
        'id_number': encryptedIdNumber,
        'gender': form.selectedGender.value,
      };
    }).toList();

    final pricePerSeat = trainData['harga'] ?? 0;
    final totalPrice = (pricePerSeat * seatIds.length).toDouble();

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF656CEE),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Memproses booking...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final kodeBooking = await hiveService.confirmBooking(
        idKereta: trainData['id'].toString(),
        tanggalKeberangkatan: bookingService.selectedDate.value,
        seatIds: seatIds,
        passengerData: passengerData,
        totalPrice: totalPrice,
      );

      Get.back();

      if (kodeBooking != null) {
        pilihKursiController.isTimerActive.value = false;
        pilihKursiController.remainingSeconds.value = 0;

        Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Booking Berhasil!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333E63),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Kode Booking",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kodeBooking,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF656CEE),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Simpan kode booking ini untuk melihat tiket Anda",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed(Routes.DASHBOARD);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF656CEE),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Selesai",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          "Booking Gagal",
          "Terjadi kesalahan saat memproses booking. Silakan coba lagi.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
