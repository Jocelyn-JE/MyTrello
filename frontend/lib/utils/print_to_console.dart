import 'package:flutter/foundation.dart';
import 'package:frontend/utils/config.dart';

void printToConsole(String message) {
  if (kDebugMode && AppConfig.debugMode) {
    debugPrint(message);
  }
}
