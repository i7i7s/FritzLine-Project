import 'package:get/get.dart';

class BookingService extends GetxService {
  final selectedDeparture = <String, String>{}.obs;
  final selectedArrival = <String, String>{}.obs;
  final selectedDate = DateTime.now().obs;
  final passengerCount = 1.obs;

  final selectedTrain = <String, dynamic>{}.obs;

  final passengerData = <Map<String, String>>[].obs;

  final selectedSeats = <String>[].obs;

  void resetBooking() {
    selectedDeparture.value = {};
    selectedArrival.value = {};
    selectedDate.value = DateTime.now();
    passengerCount.value = 1;
    selectedTrain.value = {};
    passengerData.clear();
    selectedSeats.clear();
  }
}