import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/password_field.dart';

void main() {
  group('PasswordField Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Basic Rendering Tests', () {
      testWidgets('renders with default properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PasswordField(controller: controller)),
          ),
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
        expect(textField.enabled, isTrue);
      });

      testWidgets('renders with custom label', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                labelText: 'Custom Password',
              ),
            ),
          ),
        );

        expect(find.text('Custom Password'), findsOneWidget);
        expect(find.text('Password'), findsNothing);
      });

      testWidgets('renders with custom hint text', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                hintText: 'Enter your password',
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.hintText, equals('Enter your password'));
      });

      testWidgets('renders as disabled when enabled is false', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(controller: controller, enabled: false),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isFalse);
      });
    });

    group('Visibility Toggle Tests', () {
      testWidgets('toggles password visibility when icon is tapped', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PasswordField(controller: controller)),
          ),
        );

        // Initially obscured
        TextField textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Should be visible now
        textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isFalse);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off), findsNothing);

        // Tap again to hide
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Should be obscured again
        textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
      });

      testWidgets('visibility state is maintained across rebuilds', (
        WidgetTester tester,
      ) async {
        Widget buildPasswordField(String key) {
          return MaterialApp(
            key: ValueKey(key),
            home: Scaffold(body: PasswordField(controller: controller)),
          );
        }

        await tester.pumpWidget(buildPasswordField('first'));

        // Make password visible
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        TextField textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isFalse);

        // Rebuild widget tree
        await tester.pumpWidget(buildPasswordField('second'));

        // Visibility should reset to default (obscured) since it's a new widget instance
        textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
      });
    });

    group('Input Interaction Tests', () {
      testWidgets('accepts text input', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PasswordField(controller: controller)),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test password');
        expect(controller.text, equals('test password'));
      });

      testWidgets('calls onChanged callback', (WidgetTester tester) async {
        String? changedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                onChanged: (value) => changedValue = value,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'callback test');
        expect(changedValue, equals('callback test'));
      });

      testWidgets('calls onTap callback', (WidgetTester tester) async {
        bool wasTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
        expect(wasTapped, isTrue);
      });

      testWidgets('calls onEditingComplete callback', (
        WidgetTester tester,
      ) async {
        bool editingCompleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                onEditingComplete: () => editingCompleted = true,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'test');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        expect(editingCompleted, isTrue);
      });
    });

    group('Autofill Tests', () {
      testWidgets('uses default autofill hints', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PasswordField(controller: controller)),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.autofillHints, contains(AutofillHints.password));
      });

      testWidgets('uses custom autofill hints', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                autofillHints: const [AutofillHints.newPassword],
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.autofillHints, contains(AutofillHints.newPassword));
        expect(
          textField.autofillHints,
          isNot(contains(AutofillHints.password)),
        );
      });
    });

    group('Custom Decoration Tests', () {
      testWidgets('merges custom decoration with defaults', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        );

        // Should have custom prefix icon
        expect(find.byIcon(Icons.lock), findsOneWidget);
        // Should still have visibility toggle suffix icon
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.prefixIcon, isA<Icon>());
        expect(textField.decoration?.suffixIcon, isA<IconButton>());
      });

      testWidgets('overrides default labelText with decoration labelText', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                labelText: 'Default Label',
                decoration: const InputDecoration(labelText: 'Custom Label'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Label'), findsOneWidget);
        expect(find.text('Default Label'), findsNothing);
      });
    });

    group('TextInputAction Tests', () {
      testWidgets('uses custom textInputAction', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordField(
                controller: controller,
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.textInputAction, equals(TextInputAction.next));
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('handles rapid visibility toggles', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PasswordField(controller: controller)),
          ),
        );

        // Rapidly toggle visibility multiple times
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.visibility_off));
          await tester.pump();
          await tester.tap(find.byIcon(Icons.visibility));
          await tester.pump();
        }

        // Should end up in obscured state
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
      });

      testWidgets('preserves text when toggling visibility', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PasswordField(controller: controller)),
          ),
        );

        // Enter text
        await tester.enterText(find.byType(TextField), 'preserved text');
        expect(controller.text, equals('preserved text'));

        // Toggle visibility
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Text should be preserved
        expect(controller.text, equals('preserved text'));

        // Toggle back
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Text should still be preserved
        expect(controller.text, equals('preserved text'));
      });
    });
  });
}
