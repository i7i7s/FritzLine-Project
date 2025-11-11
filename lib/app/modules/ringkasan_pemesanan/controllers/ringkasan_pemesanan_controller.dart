import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fritzlinee/app/services/booking_service.dart';
import 'package:fritzlinee/app/services/auth_service.dart';
import 'package:fritzlinee/app/routes/app_pages.dart';
import '../../../models/passenger.dart';

class PassengerFormControllers {
  final TextEditingController fullNameController;
  final TextEditingController idNumberController;
  final RxString selectedIdType;
  final RxBool isExpanded;
  final RxBool savePassenger;

  PassengerFormControllers()
    : fullNameController = TextEditingController(),
      idNumberController = TextEditingController(),
      selectedIdType = 'KTP'.obs,
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

  final trainData = {}.obs;
  final passengerCount = 0.obs;

  final savedPassengers = <Passenger>[].obs;

  final List<String> idTypes = ['KTP', 'Paspor', 'SIM'];

  final formList = <PassengerFormControllers>[].obs;

  @override
  void onInit() {
    super.onInit();

    final Map<String, dynamic>? data = Get.arguments as Map<String, dynamic>?;
    if (data != null) {
      trainData.value = data;
      bookingService.selectedTrain.value = data;
    } else {
      trainData.value = bookingService.selectedTrain.value;
    }

    passengerCount.value = bookingService.passengerCount.value;
    savedPassengers.assignAll(authService.savedPassengers);

    if (passengerCount.value <= 0) {
      passengerCount.value = 1;
    }

    bookingService.selectedSeats.clear();

    for (int i = 0; i < passengerCount.value; i++) {
      formList.add(PassengerFormControllers());
    }
  }

  @override
  void onClose() {
    for (var form in formList) {
      form.dispose();
    }
    super.onClose();
  }

  void changeIdType(int index, String? newValue) {
    if (newValue != null) {
      formList[index].selectedIdType.value = newValue;
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

      if (form.savePassenger.value) {
        await authService.addSavedPassenger(passenger);
      }
    }

    bookingService.passengerData.value = passengersToBook;
    Get.toNamed(Routes.PILIH_KURSI);
  }

  void goToDetailBooking() {
    Get.toNamed(Routes.DETAIL_BOOKING_TIKET);
  }
}
