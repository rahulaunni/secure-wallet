import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class SecurityStore {
  static const _storage = FlutterSecureStorage();

  static const _pinKey = 'user_pin';
  static const _answer1Key = 'security_a1';
  static const _answer2Key = 'security_a2';

  static Future<void> migrateFromSettings(Box settingsBox) async {
    await _moveSettingToSecureStorage(settingsBox, _pinKey);
    await _moveSettingToSecureStorage(settingsBox, _answer1Key);
    await _moveSettingToSecureStorage(settingsBox, _answer2Key);
  }

  static Future<String?> readPin() {
    return _storage.read(key: _pinKey);
  }

  static Future<void> savePin(String pin) {
    return _storage.write(key: _pinKey, value: pin);
  }

  static Future<void> deletePin() {
    return _storage.delete(key: _pinKey);
  }

  static Future<void> saveRecoveryAnswers({
    required String answer1,
    required String answer2,
  }) async {
    await _storage.write(key: _answer1Key, value: answer1);
    await _storage.write(key: _answer2Key, value: answer2);
  }

  static Future<(String?, String?)> readRecoveryAnswers() async {
    final answer1 = await _storage.read(key: _answer1Key);
    final answer2 = await _storage.read(key: _answer2Key);
    return (answer1, answer2);
  }

  static Future<void> clearRecoveryAnswers() async {
    await _storage.delete(key: _answer1Key);
    await _storage.delete(key: _answer2Key);
  }

  static Future<void> clearAll() async {
    await deletePin();
    await clearRecoveryAnswers();
  }

  static Future<void> _moveSettingToSecureStorage(
    Box settingsBox,
    String key,
  ) async {
    final existingSecureValue = await _storage.read(key: key);
    final existingSettingValue = settingsBox.get(key);

    if (existingSecureValue == null && existingSettingValue is String) {
      await _storage.write(key: key, value: existingSettingValue);
    }

    if (settingsBox.containsKey(key)) {
      await settingsBox.delete(key);
    }
  }
}
