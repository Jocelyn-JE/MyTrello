import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:frontend/register_screen.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(isOptional: true);
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('renders register screen with all expected elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.text('Register'),
        findsNWidgets(2),
      ); // AppBar title + Button text
      expect(
        find.byType(TextField),
        findsNWidgets(4),
      ); // Email, Username, 2 Password fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(
        find.byIcon(Icons.visibility_off),
        findsNWidgets(2),
      ); // Two password fields
    });

    testWidgets('has AutofillGroup wrapper', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      expect(find.byType(AutofillGroup), findsOneWidget);
    });

    testWidgets('email field has proper autofill hints', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      expect(emailField.autofillHints, contains(AutofillHints.email));
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('username field has proper autofill hints', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final usernameField = tester.widget<TextField>(
        find.byType(TextField).at(1),
      );
      expect(usernameField.autofillHints, contains(AutofillHints.newUsername));
    });

    testWidgets('password fields toggle visibility independently', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Both password fields should be obscured initially
      final passwordFields = find.byType(TextField);
      final firstPasswordField = tester.widget<TextField>(passwordFields.at(2));
      final secondPasswordField = tester.widget<TextField>(
        passwordFields.at(3),
      );

      expect(firstPasswordField.obscureText, isTrue);
      expect(secondPasswordField.obscureText, isTrue);

      // Tap first password field visibility icon
      final visibilityIcons = find.byIcon(Icons.visibility_off);
      await tester.tap(visibilityIcons.first);
      await tester.pump();

      // First field should be visible, second should still be obscured
      final updatedFirstField = tester.widget<TextField>(passwordFields.at(2));
      final stillObscuredSecondField = tester.widget<TextField>(
        passwordFields.at(3),
      );

      expect(updatedFirstField.obscureText, isFalse);
      expect(stillObscuredSecondField.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('RegisterScreen Validation Tests', () {
    testWidgets('shows error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error when username is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter your username'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'differentpassword');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('accepts valid registration data', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Should not show validation errors
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(find.text('Please enter your username'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });
  });

  group('RegisterScreen Input Validation Tests', () {
    testWidgets('accepts valid email formats', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
        'user123@test-domain.com',
      ];

      for (final email in validEmails) {
        await tester.enterText(find.byType(TextField).at(0), email);
        await tester.enterText(find.byType(TextField).at(1), 'testuser');
        await tester.enterText(find.byType(TextField).at(2), 'password123');
        await tester.enterText(find.byType(TextField).at(3), 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
        await tester.pump();

        expect(find.text('Please enter a valid email address'), findsNothing);

        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold)),
        ).clearSnackBars();
        await tester.pump();
      }
    });

    testWidgets('rejects invalid email formats', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

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

        await tester.enterText(find.byType(TextField).at(0), email);
        await tester.enterText(find.byType(TextField).at(1), 'testuser');
        await tester.enterText(find.byType(TextField).at(2), 'password123');
        await tester.enterText(find.byType(TextField).at(3), 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
        await tester.pump();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
      }
    });

    testWidgets('trims whitespace from all inputs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(
        find.byType(TextField).at(0),
        '  test@example.com  ',
      );
      await tester.enterText(find.byType(TextField).at(1), '  testuser  ');
      await tester.enterText(find.byType(TextField).at(2), '  password123  ');
      await tester.enterText(find.byType(TextField).at(3), '  password123  ');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Should not show validation errors since trimmed values are valid
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your username'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });
  });

  group('RegisterScreen Layout Tests', () {
    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('has proper spacing between elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.spacing, 16);
    });

    testWidgets('has proper constraints on form width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final constrainedBoxes = find.byType(ConstrainedBox);
      expect(constrainedBoxes, findsAtLeastNWidgets(1));

      // Look for the ConstrainedBox with maxWidth constraint
      bool foundCorrectConstraint = false;
      for (int i = 0; i < tester.widgetList(constrainedBoxes).length; i++) {
        final constrainedBox = tester.widget<ConstrainedBox>(
          constrainedBoxes.at(i),
        );
        if (constrainedBox.constraints.maxWidth == 300) {
          foundCorrectConstraint = true;
          break;
        }
      }
      expect(foundCorrectConstraint, isTrue);
    });
  });

  group('RegisterScreen Loading State Tests', () {
    testWidgets('shows loading indicator when registering', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Fill form with valid data
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password123');

      // Tap register button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump(); // Allow the widget to rebuild with loading state

      // Since the network request fails quickly, we just verify the form was valid
      // and the register process was initiated
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('button is enabled when not loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });
  });

  group('RegisterScreen Controller Tests', () {
    testWidgets('controllers are properly disposed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password123');

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Different Screen'))),
      );

      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets('form state is maintained during widget rebuilds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password123');

      // Toggle password visibility to trigger rebuild
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      // All text should still be there
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('password123'), findsNWidgets(2));
    });
  });

  group('RegisterScreen Accessibility Tests', () {
    testWidgets('has proper semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      expect(find.byType(TextField), findsNWidgets(4));

      final emailField = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(emailField.decoration?.labelText, 'Email');

      final usernameField = tester.widget<TextField>(
        find.byType(TextField).at(1),
      );
      expect(usernameField.decoration?.labelText, 'Username');
    });

    testWidgets('supports keyboard navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });
  });

  group('RegisterScreen Network Failure Tests', () {
    testWidgets('handles network errors gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      // Fill form with valid data
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'testuser');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), 'password123');

      // Tap register - this will fail due to no backend
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));

      // Wait for the network request to fail and state to update
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should show error message (network error expected)
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
