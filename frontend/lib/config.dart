import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get backendUrl {
    return dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
  }

  static int get apiTimeout {
    return int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  }

  static bool get debugMode {
    return dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  }

  // Add more configuration getters as needed
}
