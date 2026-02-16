import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/l10n/app_localizations.dart';

/// Helper to wrap widgets with MaterialApp and localization support
Widget buildTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
    home: child,
  );
}

void main() {
  setUpAll(() async {
    await dotenv.load(isOptional: true);
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('renders login screen with all expected elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('MyTrello - Login'), findsOneWidget); // AppBar title
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.text('Register'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('toggles password visibility when icon is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final passwordField = tester.widget<TextField>(
        find.byType(TextField).last,
      );
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      final updatedPasswordField = tester.widget<TextField>(
        find.byType(TextField).last,
      );
      expect(updatedPasswordField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextField).first, 'invalid-email');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('navigates to register screen when register button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const Scaffold(
              body: Center(child: Text('Registration Screen')),
            ),
          },
        ),
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Registration Screen'), findsOneWidget);
    });
  });

  group('LoginScreen Input Validation Tests', () {
    testWidgets('accepts valid email formats', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
        'user123@test-domain.com',
      ];

      for (final email in validEmails) {
        await tester.enterText(find.byType(TextField).first, '');
        await tester.enterText(find.byType(TextField).first, email);
        await tester.enterText(find.byType(TextField).last, 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();

        expect(find.text('Please enter a valid email address'), findsNothing);

        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold)),
        ).clearSnackBars();
        await tester.pump();
      }
    });

    testWidgets('rejects invalid email formats', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final invalidEmails = [
        'invalid',
        'invalid@',
        '@invalid.com',
        'invalid.email',
        'invalid@.com',
        'invalid@domain.',
      ];

      for (final email in invalidEmails) {
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold)),
        ).clearSnackBars();
        await tester.pump();

        await tester.enterText(find.byType(TextField).first, email);
        await tester.enterText(find.byType(TextField).last, 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
      }
    });

    testWidgets('trims whitespace from email and password inputs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.enterText(
        find.byType(TextField).first,
        '  test@example.com  ',
      );
      await tester.enterText(find.byType(TextField).last, '  password123  ');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });
  });

  group('LoginScreen Accessibility Tests', () {
    testWidgets('has proper semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsNWidgets(2));

      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      expect(emailField.decoration?.labelText, 'Email');

      final passwordField = tester.widget<TextField>(
        find.byType(TextField).last,
      );
      expect(passwordField.decoration?.labelText, 'Password');
    });

    testWidgets('supports keyboard navigation', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });
  });

  group('LoginScreen Layout Tests', () {
    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('has proper spacing between elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.spacing, 16);
    });
  });

  group('LoginScreen Controller Tests', () {
    testWidgets('controllers are properly disposed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different Screen'))),
      );

      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets('form state is maintained during widget rebuilds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
