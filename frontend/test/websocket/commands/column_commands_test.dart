import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/websocket/commands/column_commands.dart';

void main() {
  group('CreateColumnCommand Tests', () {
    test('creates valid JSON for create column command', () {
      final command = CreateColumnCommand(title: 'To Do');
      final json = command.toJson();

      expect(json['type'], equals('column.create'));
      expect(json['data'], isNotNull);
      expect(json['data']['title'], equals('To Do'));
    });

    test('handles empty title', () {
      final command = CreateColumnCommand(title: '');
      final json = command.toJson();

      expect(json['data']['title'], equals(''));
    });

    test('handles special characters in title', () {
      final command = CreateColumnCommand(
        title: 'Test "Column" with \'quotes\'',
      );
      final json = command.toJson();

      expect(json['data']['title'], equals('Test "Column" with \'quotes\''));
    });
  });

  group('ListColumnsCommand Tests', () {
    test('creates valid JSON for list columns command', () {
      final command = ListColumnsCommand();
      final json = command.toJson();

      expect(json['type'], equals('column.list'));
      expect(json['data'], isNull);
    });
  });

  group('RenameColumnCommand Tests', () {
    test('creates valid JSON for rename column command', () {
      final command = RenameColumnCommand(
        columnId: 'col-123',
        newTitle: 'In Progress',
      );
      final json = command.toJson();

      expect(json['type'], equals('column.rename'));
      expect(json['data'], isNotNull);
      expect(json['data']['id'], equals('col-123'));
      expect(json['data']['title'], equals('In Progress'));
    });

    test('handles different column ID', () {
      final command = RenameColumnCommand(
        columnId: 'different-col-id',
        newTitle: 'Done',
      );
      final json = command.toJson();

      expect(json['data']['id'], equals('different-col-id'));
      expect(json['data']['title'], equals('Done'));
    });

    test('handles special characters in new title', () {
      final command = RenameColumnCommand(
        columnId: 'col-123',
        newTitle: 'Test "Column" with \'quotes\'',
      );
      final json = command.toJson();

      expect(json['data']['title'], equals('Test "Column" with \'quotes\''));
    });
  });

  group('DeleteColumnCommand Tests', () {
    test('creates valid JSON for delete column command', () {
      final command = DeleteColumnCommand(columnId: 'col-123');
      final json = command.toJson();

      expect(json['type'], equals('column.delete'));
      expect(json['data'], isNotNull);
      expect(json['data']['id'], equals('col-123'));
    });

    test('handles different column ID', () {
      final command = DeleteColumnCommand(columnId: 'different-col-id');
      final json = command.toJson();

      expect(json['data']['id'], equals('different-col-id'));
    });
  });
}
