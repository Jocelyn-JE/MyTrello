import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/utils/protected_routes.dart';
import 'package:frontend/services/api/auth_service.dart';

void main() {
  group('ProtectedRoute Widget Tests', () {
    const testChild = Scaffold(body: Center(child: Text('Protected Content')));

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      // Reset AuthService state before each test
      await AuthService.logout();
    });

    group('Authentication State Tests', () {
      testWidgets('shows child when user is authenticated', (
        WidgetTester tester,
      ) async {
        // Login first
        await AuthService.login('test-token', 'test-user-id');

        await tester.pumpWidget(
          MaterialApp(
            home: const ProtectedRoute(child: testChild),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login')),
            },
          ),
        );

        await tester.pumpAndSettle();

        // Should display the child content when authenticated
        expect(find.text('Protected Content'), findsOneWidget);
      });

      testWidgets('shows loading indicator when user is not authenticated', (
        WidgetTester tester,
      ) async {
        // Make sure user is logged out
        await AuthService.logout();

        await tester.pumpWidget(
          MaterialApp(
            home: const ProtectedRoute(child: testChild),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login')),
            },
          ),
        );

        // Only pump once to catch loading state
        await tester.pump();

        // Should display loading indicator while checking auth
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('redirects to login when not authenticated', (
        WidgetTester tester,
      ) async {
        await AuthService.logout();

        await tester.pumpWidget(
          MaterialApp(
            home: const ProtectedRoute(child: testChild),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login Screen')),
            },
          ),
        );

        await tester.pumpAndSettle();

        // Should redirect to login screen
        expect(find.text('Login Screen'), findsOneWidget);
        expect(find.text('Protected Content'), findsNothing);
      });
    });

    group('Widget Structure Tests', () {
      testWidgets('renders child widget correctly when authenticated', (
        WidgetTester tester,
      ) async {
        await AuthService.login('test-token', 'test-user-id');

        await tester.pumpWidget(
          MaterialApp(
            home: ProtectedRoute(
              child: Scaffold(
                appBar: AppBar(title: const Text('Test App')),
                body: const Center(child: Text('Content')),
              ),
            ),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login')),
            },
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Test App'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('loading state has proper structure', (
        WidgetTester tester,
      ) async {
        await AuthService.logout();

        await tester.pumpWidget(
          MaterialApp(
            home: const ProtectedRoute(child: testChild),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login')),
            },
          ),
        );

        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('works with null child safety', (WidgetTester tester) async {
        await AuthService.login('test-token', 'test-user-id');

        await tester.pumpWidget(
          MaterialApp(
            home: const ProtectedRoute(child: SizedBox.shrink()),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login')),
            },
          ),
        );

        await tester.pumpAndSettle();

        // Should not crash with minimal child
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('handles complex child widget trees', (
        WidgetTester tester,
      ) async {
        await AuthService.login('test-token', 'test-user-id');

        await tester.pumpWidget(
          MaterialApp(
            home: ProtectedRoute(
              child: Scaffold(
                appBar: AppBar(title: const Text('Complex App')),
                body: ListView(
                  children: const [
                    ListTile(title: Text('Item 1')),
                    ListTile(title: Text('Item 2')),
                    Card(child: Text('Card Content')),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login')),
            },
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Complex App'), findsOneWidget);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(find.text('Card Content'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('builds efficiently when authenticated', (
        WidgetTester tester,
      ) async {
        await AuthService.login('test-token', 'test-user-id');

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: const ProtectedRoute(child: testChild),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login')),
            },
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        // Should build quickly (under 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(find.text('Protected Content'), findsOneWidget);
      });
    });
  });
}
