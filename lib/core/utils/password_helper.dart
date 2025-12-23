import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Password hashing utility
class PasswordHelper {
  PasswordHelper._();

  /// Hash password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}
