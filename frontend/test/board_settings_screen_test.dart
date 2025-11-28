import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/board_settings_screen.dart';
import 'package:frontend/models/board.dart';
import 'package:frontend/auth_service.dart';

void main() {
  setUp(() {
    AuthService.resetForTesting();
  });

  group('BoardSettingsScreen', () {
    final mockBoard = Board(
      id: 'board-1',
      title: 'Test Board',
      ownerId: 'user-1',
      owner: BoardOwner(id: 'user-1', username: 'owner'),
      members: [
        BoardUser(id: 'user-2', username: 'member1'),
        BoardUser(id: 'user-3', username: 'member2'),
      ],
      viewers: [BoardUser(id: 'user-4', username: 'viewer1')],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('displays board title correctly', (WidgetTester tester) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      expect(find.text('Board Settings'), findsOneWidget);
      expect(find.text('Test Board'), findsOneWidget);
    });

    testWidgets('displays owner information', (WidgetTester tester) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('owner'), findsOneWidget);
      expect(find.text('Board Owner'), findsOneWidget);
    });

    testWidgets('displays members and viewers', (WidgetTester tester) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      expect(find.text('Users & Permissions'), findsOneWidget);
      expect(find.text('member1'), findsOneWidget);
      expect(find.text('member2'), findsOneWidget);
      expect(find.text('viewer1'), findsOneWidget);
    });

    testWidgets('shows action buttons for owner', (WidgetTester tester) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Delete Board'), findsOneWidget);
    });

    testWidgets('hides action buttons for non-owner', (
      WidgetTester tester,
    ) async {
      await AuthService.login('test-token', 'user-2');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      expect(find.text('Save Changes'), findsNothing);
      expect(find.text('Delete Board'), findsNothing);
    });

    testWidgets('title field is enabled for owner', (
      WidgetTester tester,
    ) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      final titleField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Test Board'),
      );
      expect(titleField.enabled, isTrue);
    });

    testWidgets('title field is disabled for non-owner', (
      WidgetTester tester,
    ) async {
      await AuthService.login('test-token', 'user-2');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      final titleField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Test Board'),
      );
      expect(titleField.enabled, isFalse);
    });

    testWidgets('save button is disabled when no changes', (
      WidgetTester tester,
    ) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Changes'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('save button is enabled after title change', (
      WidgetTester tester,
    ) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      // Change the title
      await tester.enterText(
        find.widgetWithText(TextField, 'Test Board'),
        'New Title',
      );
      await tester.pump();

      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Changes'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('shows delete confirmation dialog', (
      WidgetTester tester,
    ) async {
      await AuthService.login('test-token', 'user-1');

      await tester.pumpWidget(
        MaterialApp(home: BoardSettingsScreen(board: mockBoard)),
      );

      // Tap delete button
      await tester.tap(find.text('Delete Board'));
      await tester.pumpAndSettle();

      expect(
        find.text('Delete Board'),
        findsNWidgets(2),
      ); // One in dialog, one in screen
      expect(
        find.textContaining('Are you sure you want to delete'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
