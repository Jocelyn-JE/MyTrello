import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get backendUrl {
    try {
      return dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
    } catch (e) {
      // dotenv not loaded, return default
      return 'http://localhost:3000';
    }
  }

  static int get apiTimeout {
    try {
      return int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
    } catch (e) {
      // dotenv not loaded, return default
      return 30000;
    }
  }

  static bool get debugMode {
    try {
      return dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
    } catch (e) {
      // dotenv not loaded, return default
      return false;
    }
  }

  // Add more configuration getters as needed
}
