import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';
import '../models/passenger.dart';
import '../models/user.dart';

class AuthService extends GetxService {
  late Box<User> _userBox;
  late Box _sessionBox;
  late Box<Passenger> _passengerBox;

  final isLoggedIn = false.obs;
  final currentUser = Rxn<User>();
  final savedPassengers = <Passenger>[].obs;

  Future<AuthService> init() async {
    _passengerBox = await Hive.openBox<Passenger>('passengers');
    _userBox = await Hive.openBox<User>('users');
    _sessionBox = await Hive.openBox('auth_session');
    checkSession();
    return this;
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool checkSession() {
    final userKey = _sessionBox.get('currentUserKey');
    if (userKey != null) {
      final user = _userBox.get(userKey);
      if (user != null) {
        currentUser.value = user;
        _loadSavedPassengers();
        isLoggedIn.value = true;
        return true;
      }
    }
    isLoggedIn.value = false;
    return false;
  }

  void _loadSavedPassengers() {
    if (currentUser.value != null) {
      savedPassengers.assignAll(currentUser.value!.savedPassengers.toList());
    } else {
      savedPassengers.clear();
    }
  }

  Future<void> addSavedPassenger(Map<String, String> passengerData) async {
    if (currentUser.value == null) return;

    final newPassenger = Passenger(
      nama: passengerData['nama']!,
      idType: passengerData['id_type']!,
      idNumber: passengerData['id_number']!,
    );

    bool alreadyExists = currentUser.value!.savedPassengers.any(
      (p) => p.nama == newPassenger.nama && p.idNumber == newPassenger.idNumber,
    );

    if (!alreadyExists) {
      await _passengerBox.add(newPassenger);

      currentUser.value!.savedPassengers.add(newPassenger);
      await currentUser.value!.save();

      _loadSavedPassengers();
    }
  }

  Future<void> updateSavedPassenger(
    int index,
    Map<String, dynamic> updatedPassenger,
  ) async {
    if (currentUser.value == null ||
        index < 0 ||
        index >= currentUser.value!.savedPassengers.length)
      return;

    final passengerToUpdate = currentUser.value!.savedPassengers[index];
    passengerToUpdate.nama = updatedPassenger['nama'];
    passengerToUpdate.idType = updatedPassenger['id_type'];
    passengerToUpdate.idNumber = updatedPassenger['id_number'];

    await passengerToUpdate.save();
    _loadSavedPassengers();
  }

  Future<void> deleteSavedPassenger(int index) async {
    if (currentUser.value == null ||
        index < 0 ||
        index >= currentUser.value!.savedPassengers.length)
      return;

    final passengerToDelete = currentUser.value!.savedPassengers[index];

    currentUser.value!.savedPassengers.removeAt(index);
    await currentUser.value!.save();

    await passengerToDelete.delete();

    _loadSavedPassengers();
  }

  Future<bool> register(String name, String email, String password) async {
    if (_userBox.containsKey(email)) {
      Get.snackbar("Error", "Email sudah terdaftar.");
      return false;
    }

    String hashedPassword = _hashPassword(password);

    final user = User(
      name: name,
      email: email,
      password: hashedPassword,
      savedPassengers: HiveList(_passengerBox),
    );

    await _userBox.put(email, user);
    return true;
  }

  Future<bool> login(String email, String password) async {
    final user = _userBox.get(email);

    if (user == null) {
      Get.snackbar("Error", "Email tidak ditemukan.");
      return false;
    }

    String storedHash = user.password;
    String inputHash = _hashPassword(password);

    if (storedHash != inputHash) {
      Get.snackbar("Error", "Password salah.");
      return false;
    }

    await _sessionBox.put('currentUserKey', user.email);
    currentUser.value = user;
    _loadSavedPassengers();
    isLoggedIn.value = true;

    print('👤 [AuthService] User logged in: ${user.email}');

    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        final ticketService = Get.find<dynamic>();
        if (ticketService.toString().contains('TicketService')) {
          print('🔄 [AuthService] Reloading tickets for: ${user.email}');
          ticketService.reloadTickets();
        }
      } catch (e) {
        print('❌ [AuthService] Could not reload tickets: $e');
      }

      try {
        final loyaltyService = Get.find<dynamic>();
        if (loyaltyService.toString().contains('LoyaltyService')) {
          print('🔄 [AuthService] Reloading loyalty for: ${user.email}');
          loyaltyService.reloadLoyaltyData();
        }
      } catch (e) {
        print('❌ [AuthService] Could not reload loyalty: $e');
      }
    });

    return true;
  }

  Future<void> logout() async {
    final loggedOutUser = currentUser.value?.email ?? 'unknown';
    print('👋 [AuthService] User logging out: $loggedOutUser');

    await _sessionBox.delete('currentUserKey');
    currentUser.value = null;
    savedPassengers.clear();
    isLoggedIn.value = false;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        final ticketService = Get.find<dynamic>();
        if (ticketService.toString().contains('TicketService')) {
          print('🔄 [AuthService] Clearing tickets after logout');
          ticketService.reloadTickets();
        }
      } catch (e) {
        print('❌ [AuthService] Could not reload tickets: $e');
      }

      try {
        final loyaltyService = Get.find<dynamic>();
        if (loyaltyService.toString().contains('LoyaltyService')) {
          print('🔄 [AuthService] Clearing loyalty after logout');
          loyaltyService.clearLoyaltyData();
        }
      } catch (e) {
        print('❌ [AuthService] Could not clear loyalty: $e');
      }
    });
  }
}
