import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    group('Backend URL Configuration', () {
      test('returns default backend URL when dotenv is not available', () {
        final url = AppConfig.backendUrl;
        expect(url, equals('http://localhost:3000'));
      });

      test('backendUrl getter does not throw exceptions', () {
        expect(() => AppConfig.backendUrl, returnsNormally);
      });

      test('backendUrl returns a valid string', () {
        final url = AppConfig.backendUrl;
        expect(url, isA<String>());
        expect(url.isNotEmpty, isTrue);
      });
    });

    group('API Timeout Configuration', () {
      test('returns default timeout when dotenv is not available', () {
        final timeout = AppConfig.apiTimeout;
        expect(timeout, equals(30000));
      });

      test('apiTimeout getter does not throw exceptions', () {
        expect(() => AppConfig.apiTimeout, returnsNormally);
      });

      test('apiTimeout returns a valid integer', () {
        final timeout = AppConfig.apiTimeout;
        expect(timeout, isA<int>());
        expect(timeout, greaterThanOrEqualTo(0));
      });
    });

    group('Debug Mode Configuration', () {
      test('returns false when dotenv is not available', () {
        final debugMode = AppConfig.debugMode;
        expect(debugMode, isFalse);
      });

      test('debugMode getter does not throw exceptions', () {
        expect(() => AppConfig.debugMode, returnsNormally);
      });

      test('debugMode returns a valid boolean', () {
        final debugMode = AppConfig.debugMode;
        expect(debugMode, isA<bool>());
      });
    });

    group('Configuration Consistency', () {
      test('multiple calls return same values', () {
        final url1 = AppConfig.backendUrl;
        final url2 = AppConfig.backendUrl;
        expect(url1, equals(url2));

        final timeout1 = AppConfig.apiTimeout;
        final timeout2 = AppConfig.apiTimeout;
        expect(timeout1, equals(timeout2));

        final debug1 = AppConfig.debugMode;
        final debug2 = AppConfig.debugMode;
        expect(debug1, equals(debug2));
      });

      test('all getters work together without conflicts', () {
        expect(() {
          final url = AppConfig.backendUrl;
          final timeout = AppConfig.apiTimeout;
          final debug = AppConfig.debugMode;

          expect(url, isA<String>());
          expect(timeout, isA<int>());
          expect(debug, isA<bool>());
        }, returnsNormally);
      });
    });

    group('Default Values', () {
      test('has reasonable default values', () {
        expect(AppConfig.backendUrl, contains('localhost'));
        expect(AppConfig.apiTimeout, greaterThan(0));
        expect(AppConfig.apiTimeout, lessThan(300000)); // Less than 5 minutes
        expect(AppConfig.debugMode, isFalse); // Should default to false
      });

      test('default backend URL is well-formed', () {
        final url = AppConfig.backendUrl;
        expect(url.startsWith('http'), isTrue);
        expect(url.contains(':'), isTrue);
      });

      test('default timeout is reasonable', () {
        final timeout = AppConfig.apiTimeout;
        expect(timeout, greaterThanOrEqualTo(1000)); // At least 1 second
        expect(timeout, lessThanOrEqualTo(120000)); // At most 2 minutes
      });
    });

    group('Error Handling', () {
      test('gracefully handles configuration access errors', () {
        // Should not throw exceptions even if dotenv fails
        expect(() => AppConfig.backendUrl, returnsNormally);
        expect(() => AppConfig.apiTimeout, returnsNormally);
        expect(() => AppConfig.debugMode, returnsNormally);
      });

      test('returns sensible defaults on any error', () {
        final url = AppConfig.backendUrl;
        final timeout = AppConfig.apiTimeout;
        final debug = AppConfig.debugMode;

        expect(url, isNotEmpty);
        expect(timeout, greaterThan(0));
        expect(debug, isA<bool>());
      });
    });

    group('Type Safety', () {
      test('backendUrl always returns String', () {
        final url = AppConfig.backendUrl;
        expect(url, isA<String>());
        expect(url.runtimeType, equals(String));
      });

      test('apiTimeout always returns int', () {
        final timeout = AppConfig.apiTimeout;
        expect(timeout, isA<int>());
        expect(timeout.runtimeType, equals(int));
      });

      test('debugMode always returns bool', () {
        final debug = AppConfig.debugMode;
        expect(debug, isA<bool>());
        expect(debug.runtimeType, equals(bool));
      });
    });
  });
}
