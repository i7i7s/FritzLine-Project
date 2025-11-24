import 'package:get/get.dart';
import '../models/passenger_type.dart';

class BookingService extends GetxService {
  final selectedDeparture = <String, String>{}.obs;
  final selectedArrival = <String, String>{}.obs;
  final selectedDate = DateTime.now().obs;
  final passengerCount = 1.obs;

  final selectedTrain = <String, dynamic>{}.obs;

  final passengerData = <Map<String, String>>[].obs;
  final passengerInfoList = <PassengerInfo>[].obs;

  final selectedSeats = <String>[].obs;

  final adultCount = 1.obs;
  final childWithSeatCount = 0.obs;
  final infantCount = 0.obs;

  int get totalPassengersNeedingSeat => adultCount.value + childWithSeatCount.value;
  
  int get totalPayingPassengers => adultCount.value + childWithSeatCount.value;
  
  int get totalAllPassengers => adultCount.value + childWithSeatCount.value + infantCount.value;

  void incrementAdult() {
    adultCount.value++;
    updateTotalPassengers();
  }

  void decrementAdult() {
    if (adultCount.value > 1) {
      adultCount.value--;
      updateTotalPassengers();
    }
  }

  void incrementChild() {
    childWithSeatCount.value++;
    updateTotalPassengers();
  }

  void decrementChild() {
    if (childWithSeatCount.value > 0) {
      childWithSeatCount.value--;
      updateTotalPassengers();
    }
  }

  void incrementInfant() {
    infantCount.value++;
  }

  void decrementInfant() {
    if (infantCount.value > 0) {
      infantCount.value--;
    }
  }

  void updateTotalPassengers() {
    passengerCount.value = totalPassengersNeedingSeat;
  }

  void resetBooking() {
    selectedDeparture.value = {};
    selectedArrival.value = {};
    selectedDate.value = DateTime.now();
    passengerCount.value = 1;
    adultCount.value = 1;
    childWithSeatCount.value = 0;
    infantCount.value = 0;
    selectedTrain.value = {};
    passengerData.clear();
    passengerInfoList.clear();
    selectedSeats.clear();
  }
}
