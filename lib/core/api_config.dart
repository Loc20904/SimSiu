import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        // Android emulator maps localhost of the host machine to 10.0.2.2
        return 'http://10.0.2.2:5256/api';
      }
    } catch (_) {}
    // iOS simulator, web, or desktop uses localhost directly
    return 'http://localhost:5256/api';
  }
}
