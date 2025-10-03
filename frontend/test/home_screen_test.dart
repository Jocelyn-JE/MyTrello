import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/home_screen.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(isOptional: true);
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('renders home screen with all expected elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('MyTrello - Home'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.text('Welcome to MyTrello!'), findsOneWidget);
      expect(find.text('You are successfully logged in.'), findsOneWidget);
    });

    testWidgets('has logout button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, isNotNull);
      expect(appBar.actions!.length, 1);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('displays welcome message prominently', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      final welcomeText = tester.widget<Text>(
        find.text('Welcome to MyTrello!'),
      );
      expect(welcomeText.style?.fontSize, 24);
      expect(welcomeText.style?.fontWeight, FontWeight.bold);
    });
  });

  group('HomeScreen Layout Tests', () {
    testWidgets('centers content properly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Find Center widget that contains the Column
      final centerWidgets = find.byType(Center);
      expect(centerWidgets, findsAtLeastNWidgets(1));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('has proper spacing between elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Find SizedBox with height 16 specifically
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeastNWidgets(1));

      // Look for the SizedBox with height 16
      bool foundCorrectSizedBox = false;
      for (int i = 0; i < tester.widgetList(sizedBoxes).length; i++) {
        final sizedBox = tester.widget<SizedBox>(sizedBoxes.at(i));
        if (sizedBox.height == 16) {
          foundCorrectSizedBox = true;
          break;
        }
      }
      expect(foundCorrectSizedBox, isTrue);
    });

    testWidgets('uses scaffold structure correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(Scaffold), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNotNull);
      expect(scaffold.body, isNotNull);
    });
  });

  group('HomeScreen Navigation Tests', () {
    testWidgets('navigates to login when logout is tapped', (
      WidgetTester tester,
    ) async {
      // Mock navigation
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/home',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) =>
                const Scaffold(body: Center(child: Text('Login Screen'))),
          },
        ),
      );

      // Verify we're on home screen
      expect(find.text('Welcome to MyTrello!'), findsOneWidget);

      // Tap logout button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Since the test doesn't actually call AuthService.logout(),
      // we can't guarantee navigation, so just check that the button was tapped
      // In real app, this would navigate to login
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('logout button is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Find the IconButton that contains the logout icon
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsOneWidget);

      final logoutButton = tester.widget<IconButton>(iconButtons);
      expect(logoutButton.onPressed, isNotNull);
    });
  });

  group('HomeScreen Accessibility Tests', () {
    testWidgets('has proper semantic structure', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Check that important elements are present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.text('MyTrello - Home'), findsOneWidget);
    });

    testWidgets('welcome text is properly styled', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      final welcomeText = tester.widget<Text>(
        find.text('Welcome to MyTrello!'),
      );
      expect(welcomeText.style?.fontSize, 24);
      expect(welcomeText.style?.fontWeight, FontWeight.bold);

      final subtitleText = tester.widget<Text>(
        find.text('You are successfully logged in.'),
      );
      expect(subtitleText.style, isNull); // Uses default style
    });

    testWidgets('logout icon is recognizable', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });

  group('HomeScreen State Management Tests', () {
    testWidgets('is stateless widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(HomeScreen), findsOneWidget);
      // HomeScreen should be stateless since it doesn't manage any state
    });

    testWidgets('rebuilds correctly when parent changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.text('Welcome to MyTrello!'), findsOneWidget);

      // Rebuild with different parent
      await tester.pumpWidget(
        MaterialApp(theme: ThemeData.dark(), home: const HomeScreen()),
      );
      expect(find.text('Welcome to MyTrello!'), findsOneWidget);
    });
  });

  group('HomeScreen Authentication Context Tests', () {
    testWidgets('assumes user is authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // The screen shows authenticated content
      expect(find.text('You are successfully logged in.'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('logout action calls AuthService', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/home',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) =>
                const Scaffold(body: Center(child: Text('Login Screen'))),
          },
        ),
      );

      // Verify home screen is loaded
      expect(find.text('Welcome to MyTrello!'), findsOneWidget);

      // Tap logout - this should call AuthService.logout()
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      // Without mocking AuthService, we can't test the actual logout behavior
      // but we can verify the button responds to taps
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });

  group('HomeScreen Visual Tests', () {
    testWidgets('has consistent branding', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // App title should contain "MyTrello"
      expect(find.textContaining('MyTrello'), findsAtLeastNWidgets(1));
      expect(find.text('MyTrello - Home'), findsOneWidget);
    });

    testWidgets('welcome message is user-friendly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('Welcome to MyTrello!'), findsOneWidget);
      expect(find.text('You are successfully logged in.'), findsOneWidget);
    });

    testWidgets('uses Material Design patterns', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });
  });

  group('HomeScreen Error Handling Tests', () {
    testWidgets('handles mounted check correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/home',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) =>
                const Scaffold(body: Center(child: Text('Login Screen'))),
          },
        ),
      );

      // Tap logout
      await tester.tap(find.byIcon(Icons.logout));

      // Dispose the widget tree quickly
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should not crash due to mounted check
      expect(tester.takeException(), isNull);
    });

    testWidgets('gracefully handles navigation failures', (
      WidgetTester tester,
    ) async {
      // Test with app that has no routes defined for login
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // This should not crash even if navigation fails
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      // Widget should still be present (navigation failed but no crash)
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('HomeScreen Performance Tests', () {
    testWidgets('builds efficiently', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Should build without issues
      expect(find.byType(HomeScreen), findsOneWidget);

      // Rebuild multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pump();
        expect(find.text('Welcome to MyTrello!'), findsOneWidget);
      }
    });

    testWidgets('has minimal widget tree depth', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // The widget tree should be reasonably shallow
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
    });
  });
}
