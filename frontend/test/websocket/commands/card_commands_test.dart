import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/websocket/commands/card_commands.dart';

void main() {
  group('ListCardsCommand Tests', () {
    test('creates valid JSON for list cards command', () {
      final command = ListCardsCommand(columnId: 'col-123');
      final json = command.toJson();

      expect(json['type'], equals('card.list'));
      expect(json['data']['columnId'], equals('col-123'));
    });

    test('creates command with different column ID', () {
      final command = ListCardsCommand(columnId: 'different-col-id');
      final json = command.toJson();

      expect(json['data']['columnId'], equals('different-col-id'));
    });
  });

  group('CreateCardCommand Tests', () {
    test('creates valid JSON with all required fields', () {
      final command = CreateCardCommand(
        columnId: 'col-123',
        title: 'Test Card',
        content: 'Test content',
      );
      final json = command.toJson();

      expect(json['type'], equals('card.create'));
      expect(json['data']['columnId'], equals('col-123'));
      expect(json['data']['title'], equals('Test Card'));
      expect(json['data']['content'], equals('Test content'));
      expect(json['data'].containsKey('tagId'), isFalse);
      expect(json['data'].containsKey('startDate'), isFalse);
      expect(json['data'].containsKey('dueDate'), isFalse);
    });

    test('creates valid JSON with tag ID', () {
      final command = CreateCardCommand(
        columnId: 'col-123',
        title: 'Test Card',
        content: 'Test content',
        tagId: 'tag-123',
      );
      final json = command.toJson();

      expect(json['data']['tagId'], equals('tag-123'));
    });

    test('creates valid JSON with startDate', () {
      final startDate = DateTime(2024, 1, 1);
      final command = CreateCardCommand(
        columnId: 'col-123',
        title: 'Test Card',
        content: 'Test content',
        startDate: startDate,
      );
      final json = command.toJson();

      expect(json['data']['startDate'], equals(startDate.toIso8601String()));
    });

    test('creates valid JSON with dueDate', () {
      final dueDate = DateTime(2024, 1, 15);
      final command = CreateCardCommand(
        columnId: 'col-123',
        title: 'Test Card',
        content: 'Test content',
        dueDate: dueDate,
      );
      final json = command.toJson();

      expect(json['data']['dueDate'], equals(dueDate.toIso8601String()));
    });

    test('creates valid JSON with all optional fields', () {
      final startDate = DateTime(2024, 1, 1);
      final dueDate = DateTime(2024, 1, 15);
      final command = CreateCardCommand(
        columnId: 'col-123',
        title: 'Test Card',
        content: 'Test content',
        tagId: 'tag-123',
        startDate: startDate,
        dueDate: dueDate,
      );
      final json = command.toJson();

      expect(json['type'], equals('card.create'));
      expect(json['data']['columnId'], equals('col-123'));
      expect(json['data']['title'], equals('Test Card'));
      expect(json['data']['content'], equals('Test content'));
      expect(json['data']['tagId'], equals('tag-123'));
      expect(json['data']['startDate'], equals(startDate.toIso8601String()));
      expect(json['data']['dueDate'], equals(dueDate.toIso8601String()));
    });

    test('handles empty content', () {
      final command = CreateCardCommand(
        columnId: 'col-123',
        title: 'Test Card',
        content: '',
      );
      final json = command.toJson();

      expect(json['data']['content'], equals(''));
    });

    test('handles special characters in title and content', () {
      final command = CreateCardCommand(
        columnId: 'col-123',
        title: 'Test "Card" with \'quotes\'',
        content: 'Content with\nnewlines\tand tabs',
      );
      final json = command.toJson();

      expect(json['data']['title'], equals('Test "Card" with \'quotes\''));
      expect(
        json['data']['content'],
        equals('Content with\nnewlines\tand tabs'),
      );
    });
  });
}
