import 'package:local_auth/local_auth.dart';

class DeviceAuth {
  static final LocalAuthentication _auth =
      LocalAuthentication();

  /// 🔐 Authenticate using biometrics or device PIN / pattern
  /// Auth is REQUIRED every time for card reveal
  static Future<bool> authenticate({
    String reason =
        'Authenticate to reveal card details',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN / pattern
          stickyAuth: false,    // IMPORTANT: prevents silent failures
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      // Any exception = auth failed
      return false;
    }
  }
}
