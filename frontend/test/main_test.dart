import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/auth_service.dart';

void main() {
  group('MyApp Widget Tests', () {
    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      // Reset auth state before each test
      await AuthService.logout();
    });

    group('Basic App Structure Tests', () {
      testWidgets('creates MaterialApp with correct title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(const MyApp());

        expect(find.byType(MaterialApp), findsOneWidget);

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.title, 'MyTrello');
      });

      testWidgets('has proper theme configuration', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(const MyApp());

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.theme, isNotNull);
        expect(materialApp.theme!.useMaterial3, isTrue);
      });

      testWidgets('defines all required routes', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.routes, isNotNull);
        expect(materialApp.routes!.containsKey('/login'), isTrue);
        expect(materialApp.routes!.containsKey('/register'), isTrue);
        expect(materialApp.routes!.containsKey('/home'), isTrue);
      });
    });

    group('Theme Tests', () {
      testWidgets('uses material 3 design', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.theme!.useMaterial3, isTrue);
      });
    });

    group('Basic Functionality Tests', () {
      testWidgets('initializes without crashing', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Should create the app without any crashes
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });
  });
}
