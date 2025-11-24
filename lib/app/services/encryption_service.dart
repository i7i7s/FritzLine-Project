import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';

class EncryptionService extends GetxService {
  static const String _secretKey = 'FritzLine2024SecretKey';

  String encryptData(String plainText) {
    try {
      if (plainText.isEmpty) return plainText;
      
      final plainBytes = utf8.encode(plainText);
      final keyBytes = utf8.encode(_secretKey);
      final encryptedBytes = <int>[];

      for (int i = 0; i < plainBytes.length; i++) {
        encryptedBytes.add(plainBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64.encode(encryptedBytes);
    } catch (e) {
      print('Encryption error: $e');
      return plainText;
    }
  }

  String decryptData(String encryptedText) {
    try {
      if (encryptedText.isEmpty) return encryptedText;
      
      final encryptedBytes = base64.decode(encryptedText);
      final keyBytes = utf8.encode(_secretKey);
      final decryptedBytes = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      print('Decryption error: $e');
      return encryptedText;
    }
  }

  String maskNIK(String nik) {
    if (nik.length <= 4) return nik;
    final visiblePart = nik.substring(nik.length - 4);
    final maskedPart = '*' * (nik.length - 4);
    return '$maskedPart$visiblePart';
  }

  String hashData(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  bool isEncrypted(String text) {
    try {
      base64.decode(text);
      return text.length > 20; 
    } catch (e) {
      return false;
    }
  }
}
