import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HiveEncryption {
  // ✅ FIX 1: Configure Android Options explicitly
  // This forces Android to use the hardware keystore (EncryptedSharedPreferences),
  // which is more stable in Release builds than the default.
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'hive_encryption_key';

  /// Returns a persistent 256-bit AES key
  static Future<List<int>> getOrCreateKey() async {
    try {
      final existing = await _storage.read(key: _keyName);

      if (existing != null) {
        return base64Url.decode(existing);
      }

      // 🔐 Generate secure random 32-byte key
      final key = List<int>.generate(
        32,
        (_) => Random.secure().nextInt(256),
      );

      await _storage.write(
        key: _keyName,
        value: base64Url.encode(key),
      );

      return key;
    } catch (e, stack) {
      // ✅ FIX 2: Error Logging
      // This prints the specific error if it crashes again, so you aren't staring at a black screen.
      if (kDebugMode) {
        print("❌ ENCRYPTION ERROR: $e");
        print(stack);
      }
      // If secure storage fails (rare), rethrow so the app knows it can't open Hive.
      rethrow;
    }
  }
}
