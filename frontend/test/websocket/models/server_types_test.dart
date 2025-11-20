import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/websocket/models/server_types.dart';

void main() {
  group('TrelloBoard Tests', () {
    final sampleBoardJson = {
      'id': 'board-123',
      'ownerId': 'owner-123',
      'title': 'Test Board',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    };

    test('creates TrelloBoard from valid JSON', () {
      final board = TrelloBoard.fromJson(sampleBoardJson);

      expect(board.id, equals('board-123'));
      expect(board.ownerId, equals('owner-123'));
      expect(board.title, equals('Test Board'));
      expect(board.createdAt, isA<DateTime>());
      expect(board.updatedAt, isA<DateTime>());
    });
  });

  group('TrelloColumn Tests', () {
    final sampleColumnJson = {
      'id': 'col-123',
      'boardId': 'board-123',
      'index': 0,
      'title': 'To Do',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    };

    test('creates TrelloColumn from valid JSON without cards', () {
      final column = TrelloColumn.fromJson(sampleColumnJson);

      expect(column.id, equals('col-123'));
      expect(column.boardId, equals('board-123'));
      expect(column.index, equals(0));
      expect(column.title, equals('To Do'));
      expect(column.createdAt, isA<DateTime>());
      expect(column.updatedAt, isA<DateTime>());
      expect(column.cards, isEmpty);
    });

    test('creates TrelloColumn with default empty cards list', () {
      final column = TrelloColumn(
        id: 'col-123',
        boardId: 'board-123',
        index: 0,
        title: 'To Do',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(column.cards, isEmpty);
    });

    test('update method creates new instance with updated title', () {
      final column = TrelloColumn.fromJson(sampleColumnJson);
      final updated = column.update(title: 'In Progress');

      expect(updated.id, equals(column.id));
      expect(updated.boardId, equals(column.boardId));
      expect(updated.index, equals(column.index));
      expect(updated.title, equals('In Progress'));
      expect(updated.createdAt, equals(column.createdAt));
      expect(updated.updatedAt, equals(column.updatedAt));
      expect(updated.cards, equals(column.cards));
    });

    test('update method creates new instance with updated cards', () {
      final column = TrelloColumn.fromJson(sampleColumnJson);
      final card = TrelloCard(
        id: 'card-123',
        columnId: 'col-123',
        index: 0,
        title: 'Test Card',
        content: 'Test content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final updated = column.update(cards: [card]);

      expect(updated.cards, hasLength(1));
      expect(updated.cards.first.id, equals('card-123'));
      expect(updated.id, equals(column.id));
    });

    test('update method preserves other fields when updating cards', () {
      final column = TrelloColumn.fromJson(sampleColumnJson);
      final card = TrelloCard(
        id: 'card-123',
        columnId: 'col-123',
        index: 0,
        title: 'Test Card',
        content: 'Test content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final updated = column.update(cards: [card]);

      expect(updated.id, equals(column.id));
      expect(updated.boardId, equals(column.boardId));
      expect(updated.index, equals(column.index));
      expect(updated.title, equals(column.title));
    });

    test('update method with no parameters returns identical column', () {
      final column = TrelloColumn.fromJson(sampleColumnJson);
      final updated = column.update();

      expect(updated.id, equals(column.id));
      expect(updated.boardId, equals(column.boardId));
      expect(updated.index, equals(column.index));
      expect(updated.title, equals(column.title));
      expect(updated.cards, equals(column.cards));
    });
  });

  group('TrelloCard Tests', () {
    final sampleCardJson = {
      'id': 'card-123',
      'columnId': 'col-123',
      'tagId': 'tag-123',
      'index': 0,
      'title': 'Test Card',
      'content': 'This is a test card',
      'startDate': '2024-01-01T00:00:00.000Z',
      'dueDate': '2024-01-15T00:00:00.000Z',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    };

    test('creates TrelloCard from valid JSON with all fields', () {
      final card = TrelloCard.fromJson(sampleCardJson);

      expect(card.id, equals('card-123'));
      expect(card.columnId, equals('col-123'));
      expect(card.tagId, equals('tag-123'));
      expect(card.index, equals(0));
      expect(card.title, equals('Test Card'));
      expect(card.content, equals('This is a test card'));
      expect(card.startDate, isA<DateTime>());
      expect(card.dueDate, isA<DateTime>());
      expect(card.createdAt, isA<DateTime>());
      expect(card.updatedAt, isA<DateTime>());
    });

    test('creates TrelloCard with null optional fields', () {
      final jsonWithoutOptional = {
        'id': 'card-123',
        'columnId': 'col-123',
        'tagId': null,
        'index': 0,
        'title': 'Test Card',
        'content': 'This is a test card',
        'startDate': null,
        'dueDate': null,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };

      final card = TrelloCard.fromJson(jsonWithoutOptional);

      expect(card.id, equals('card-123'));
      expect(card.tagId, isNull);
      expect(card.startDate, isNull);
      expect(card.dueDate, isNull);
    });

    test('creates TrelloCard with empty content', () {
      final jsonWithEmptyContent = Map<String, dynamic>.from(sampleCardJson);
      jsonWithEmptyContent['content'] = '';

      final card = TrelloCard.fromJson(jsonWithEmptyContent);

      expect(card.content, equals(''));
    });
  });

  group('TrelloTag Tests', () {
    final sampleTagJson = {
      'id': 'tag-123',
      'boardId': 'board-123',
      'name': 'Urgent',
      'color': '#FF0000',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    };

    test('creates TrelloTag from valid JSON', () {
      final tag = TrelloTag.fromJson(sampleTagJson);

      expect(tag.id, equals('tag-123'));
      expect(tag.boardId, equals('board-123'));
      expect(tag.name, equals('Urgent'));
      expect(tag.color, equals('#FF0000'));
      expect(tag.createdAt, isA<DateTime>());
      expect(tag.updatedAt, isA<DateTime>());
    });
  });

  group('TrelloUser Tests', () {
    final sampleUserJson = {
      'id': 'user-123',
      'email': 'test@example.com',
      'username': 'testuser',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    };

    test('creates TrelloUser from valid JSON', () {
      final user = TrelloUser.fromJson(sampleUserJson);

      expect(user.id, equals('user-123'));
      expect(user.email, equals('test@example.com'));
      expect(user.username, equals('testuser'));
      expect(user.createdAt, isA<DateTime>());
      expect(user.updatedAt, isA<DateTime>());
    });
  });

  group('MinimalUser Tests', () {
    final sampleMinimalUserJson = {
      'id': 'user-123',
      'username': 'testuser',
      'email': 'test@example.com',
    };

    test('creates MinimalUser from valid JSON', () {
      final user = MinimalUser.fromJson(sampleMinimalUserJson);

      expect(user.id, equals('user-123'));
      expect(user.username, equals('testuser'));
      expect(user.email, equals('test@example.com'));
    });
  });
}
