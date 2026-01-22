import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/print_to_console.dart';

class AppConfig {
  static String get backendHost {
    try {
      return dotenv.env['BACKEND_HOST'] ?? 'localhost:3000';
    } catch (e) {
      // dotenv not loaded, return default
      return 'localhost:3000';
    }
  }

  static String get backendUrl {
    return 'http://$backendHost';
  }

  static int get apiTimeout {
    try {
      var apiTimeoutValue = dotenv.env['API_TIMEOUT'];
      if (apiTimeoutValue == null) return 30000;
      return int.tryParse(apiTimeoutValue) ?? 30000;
    } catch (e) {
      // dotenv not loaded, return default
      return 30000;
    }
  }

  static bool get debugMode {
    try {
      var debugModeValue = dotenv.env['DEBUG_MODE'];
      if (debugModeValue == null) return false;
      return debugModeValue.toLowerCase() == 'true';
    } catch (e) {
      // dotenv not loaded, return default
      return false;
    }
  }

  static void printConfig() {
    printToConsole('Backend URL: $backendUrl');
    printToConsole('API Timeout: $apiTimeout ms');
    printToConsole('Debug Mode: $debugMode');
  }

  // Add more configuration getters as needed
}
