import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    setUp(() async {
      // Clear shared preferences before each test and reset AuthService
      SharedPreferences.setMockInitialValues({});

      // Reset the AuthService static state for testing
      AuthService.resetForTesting();
    });

    group('Initialization Tests', () {
      test('initializes correctly when no token is stored', () async {
        SharedPreferences.setMockInitialValues({});

        await AuthService.initialize();

        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, isNull);
      });

      test('initializes correctly when token is stored', () async {
        const testToken = 'test-token-123';
        SharedPreferences.setMockInitialValues({'auth_token': testToken});

        await AuthService.initialize();

        expect(AuthService.isLoggedIn, isTrue);
        expect(AuthService.token, equals(testToken));
      });

      test('initializes correctly when empty token is stored', () async {
        SharedPreferences.setMockInitialValues({'auth_token': ''});

        await AuthService.initialize();

        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, equals(''));
      });

      test('does not re-initialize if already initialized', () async {
        SharedPreferences.setMockInitialValues({
          'auth_token': 'original-token',
        });

        await AuthService.initialize();
        expect(AuthService.token, equals('original-token'));

        // Change the mock values (simulating external change)
        SharedPreferences.setMockInitialValues({'auth_token': 'new-token'});

        // Call initialize again - should not reload since already initialized
        await AuthService.initialize();
        expect(
          AuthService.token,
          equals('original-token'),
        ); // Should still be original
      });
    });

    group('Login Tests', () {
      test('logs in user successfully', () async {
        const testToken = 'login-token-456';
        const testUserId = 'user-123';

        await AuthService.login(testToken, testUserId);

        expect(AuthService.isLoggedIn, isTrue);
        expect(AuthService.token, equals(testToken));

        // Verify token is persisted
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth_token'), equals(testToken));
      });

      test('handles empty token login', () async {
        await AuthService.login('', 'user-123');

        expect(AuthService.isLoggedIn, isTrue);
        expect(AuthService.token, equals(''));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth_token'), equals(''));
      });

      test('overwrites previous token', () async {
        await AuthService.login('first-token', 'user-1');
        expect(AuthService.token, equals('first-token'));

        await AuthService.login('second-token', 'user-2');
        expect(AuthService.token, equals('second-token'));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth_token'), equals('second-token'));
      });
    });

    group('Logout Tests', () {
      test('logs out user successfully', () async {
        // First login
        await AuthService.login('test-token', 'user-123');
        expect(AuthService.isLoggedIn, isTrue);

        // Then logout
        await AuthService.logout();

        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, isNull);

        // Verify token is removed from persistence
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth_token'), isNull);
      });

      test('logout works when already logged out', () async {
        expect(AuthService.isLoggedIn, isFalse);

        await AuthService.logout();

        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, isNull);
      });

      test('logout removes token from SharedPreferences', () async {
        // Setup initial state
        const testToken = 'token-to-remove';
        const testUserId = 'user-123';
        await AuthService.login(testToken, testUserId);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('auth_token'), equals(testToken));

        // Logout
        await AuthService.logout();

        // Verify token is removed
        expect(prefs.getString('auth_token'), isNull);
      });
    });

    group('State Management Tests', () {
      test('maintains state consistency between methods', () async {
        // Initial state
        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, isNull);

        // Login
        await AuthService.login('state-test-token', 'user-123');
        expect(AuthService.isLoggedIn, isTrue);
        expect(AuthService.token, equals('state-test-token'));

        // Logout
        await AuthService.logout();
        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, isNull);
      });

      test('getters return correct values', () async {
        // Test logged out state
        await AuthService.logout();
        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, isNull);

        // Test logged in state
        const token = 'getter-test-token';
        const userId = 'getter-test-user';
        await AuthService.login(token, userId);
        expect(AuthService.isLoggedIn, isTrue);
        expect(AuthService.token, equals(token));
      });
    });

    group('Edge Cases', () {
      test('handles missing token key gracefully', () async {
        // Test when the key doesn't exist at all
        SharedPreferences.setMockInitialValues({});

        await AuthService.initialize();

        expect(AuthService.isLoggedIn, isFalse);
        expect(AuthService.token, isNull);
      });

      test('login with very long token', () async {
        final longToken = 'a' * 1000; // 1000 character token
        const userId = 'user-123';

        await AuthService.login(longToken, userId);

        expect(AuthService.isLoggedIn, isTrue);
        expect(AuthService.token, equals(longToken));
        expect(AuthService.token!.length, equals(1000));
      });

      test('multiple rapid login/logout operations', () async {
        for (int i = 0; i < 5; i++) {
          await AuthService.login('token-$i', 'user-$i');
          expect(AuthService.isLoggedIn, isTrue);
          expect(AuthService.token, equals('token-$i'));

          await AuthService.logout();
          expect(AuthService.isLoggedIn, isFalse);
          expect(AuthService.token, isNull);
        }
      });
    });
  });
}
