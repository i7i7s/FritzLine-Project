import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';

class AuthService extends GetxService {
  late Box _userBox;
  late Box _sessionBox;

  final isLoggedIn = false.obs;
  final currentUser = <String, dynamic>{}.obs;
  final savedPassengers = <Map<String, dynamic>>[].obs;

  Future<AuthService> init() async {
    _userBox = Hive.box('users');
    _sessionBox = Hive.box('auth_session');
    checkSession();
    return this;
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> originalMap) {
    return originalMap.map((key, value) => MapEntry(key.toString(), value));
  }

  bool checkSession() {
    final sessionData = _sessionBox.get('currentUser');
    if (sessionData != null && sessionData is Map) {
      currentUser.value = _convertMap(sessionData);
      _loadSavedPassengers();
      isLoggedIn.value = true;
      return true;
    } else {
      isLoggedIn.value = false;
      return false;
    }
  }

  void _loadSavedPassengers() {
    String userEmail = currentUser['email'] ?? '';
    if (userEmail.isEmpty) return;

    final userData = _userBox.get(userEmail);
    if (userData != null && userData is Map) {
      final user = _convertMap(userData);
      List<dynamic> passengersDynamic = user['saved_passengers'] ?? [];
      savedPassengers.value =
          List<Map<String, dynamic>>.from(passengersDynamic.map((passenger) {
        if (passenger is Map) {
          return _convertMap(passenger);
        }
        return <String, dynamic>{};
      }));
    }
  }

  Future<void> addSavedPassenger(Map<String, String> passenger) async {
    String userEmail = currentUser['email'] ?? '';
    if (userEmail.isEmpty) return;

    final userData = _userBox.get(userEmail);
    if (userData != null && userData is Map) {
      final user = _convertMap(userData);
      List<dynamic> passengersDynamic = user['saved_passengers'] ?? [];
      List<Map<String, dynamic>> currentPassengers =
          List<Map<String, dynamic>>.from(passengersDynamic.map((p) {
        if (p is Map) return _convertMap(p);
        return <String, dynamic>{};
      }));

      bool alreadyExists = currentPassengers.any((p) =>
          p['nama'] == passenger['nama'] &&
          p['id_number'] == passenger['id_number']);
      if (!alreadyExists) {
        currentPassengers.add(passenger);
        user['saved_passengers'] = currentPassengers;
        await _userBox.put(userEmail, user);
        _loadSavedPassengers();
      }
    }
  }

  Future<bool> register(String name, String email, String password) async {
    if (_userBox.containsKey(email)) {
      Get.snackbar("Error", "Email sudah terdaftar.");
      return false;
    }
    String hashedPassword = _hashPassword(password);
    await _userBox.put(email, {
      "name": name,
      "email": email,
      "password": hashedPassword,
      "saved_passengers": [],
    });
    return true;
  }

  Future<bool> login(String email, String password) async {
    if (!_userBox.containsKey(email)) {
      Get.snackbar("Error", "Email tidak ditemukan.");
      return false;
    }

    final userData = _userBox.get(email);
    if (userData != null && userData is Map) {
      final user = _convertMap(userData);
      String storedHash = user['password'] ?? '';
      String inputHash = _hashPassword(password);
      if (storedHash != inputHash) {
        Get.snackbar("Error", "Password salah.");
        return false;
      }
      await _sessionBox.put('currentUser', user);
      currentUser.value = user;
      _loadSavedPassengers();
      isLoggedIn.value = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _sessionBox.clear();
    currentUser.value = <String, dynamic>{};
    savedPassengers.clear();
    isLoggedIn.value = false;
  }
}