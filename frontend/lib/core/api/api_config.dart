import 'package:flutter/foundation.dart';

class ApiConfig {
  // iOS simulator, desktop, and web local development.
  static const localhostBaseUrl = 'http://127.0.0.1:8000';

  // Android emulator local development. Switch baseUrl to this when running
  // on the Android emulator against a backend on the host machine.
  static const androidEmulatorBaseUrl = 'http://10.0.2.2:8000';

  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }
    return localhostBaseUrl;
  }
}
