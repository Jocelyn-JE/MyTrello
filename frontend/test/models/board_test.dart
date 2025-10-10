import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/board.dart';

void main() {
  group('Board Model Tests', () {
    final sampleBoardJson = {
      'id': 'board-123',
      'title': 'Test Board',
      'ownerId': 'owner-123',
      'owner': {'id': 'owner-123', 'username': 'testowner'},
      'members': [
        {'id': 'member-123', 'username': 'testmember'},
      ],
      'viewers': [
        {'id': 'viewer-123', 'username': 'testviewer'},
      ],
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    };

    group('Board.fromJson', () {
      test('creates Board from valid JSON', () {
        final board = Board.fromJson(sampleBoardJson);

        expect(board.id, equals('board-123'));
        expect(board.title, equals('Test Board'));
        expect(board.ownerId, equals('owner-123'));
        expect(board.owner.id, equals('owner-123'));
        expect(board.owner.username, equals('testowner'));
        expect(board.members, hasLength(1));
        expect(board.members.first.id, equals('member-123'));
        expect(board.members.first.username, equals('testmember'));
        expect(board.viewers, hasLength(1));
        expect(board.viewers.first.id, equals('viewer-123'));
        expect(board.viewers.first.username, equals('testviewer'));
        expect(board.createdAt, isA<DateTime>());
        expect(board.updatedAt, isA<DateTime>());
      });

      test('handles empty members and viewers lists', () {
        final jsonWithoutUsers = Map<String, dynamic>.from(sampleBoardJson);
        jsonWithoutUsers['members'] = [];
        jsonWithoutUsers['viewers'] = [];

        final board = Board.fromJson(jsonWithoutUsers);

        expect(board.members, isEmpty);
        expect(board.viewers, isEmpty);
      });

      test('handles null members and viewers lists', () {
        final jsonWithNullUsers = Map<String, dynamic>.from(sampleBoardJson);
        jsonWithNullUsers.remove('members');
        jsonWithNullUsers.remove('viewers');

        final board = Board.fromJson(jsonWithNullUsers);

        expect(board.members, isEmpty);
        expect(board.viewers, isEmpty);
      });
    });

    group('Board.toJson', () {
      test('converts Board to JSON correctly', () {
        final board = Board.fromJson(sampleBoardJson);
        final json = board.toJson();

        expect(json['id'], equals('board-123'));
        expect(json['title'], equals('Test Board'));
        expect(json['ownerId'], equals('owner-123'));
        expect(json['owner'], isA<Map<String, dynamic>>());
        expect(json['members'], isA<List>());
        expect(json['viewers'], isA<List>());
        expect(json['createdAt'], isA<String>());
        expect(json['updatedAt'], isA<String>());
      });
    });
  });

  group('BoardUser Model Tests', () {
    final sampleUserJson = {'id': 'user-123', 'username': 'testuser'};

    group('BoardUser.fromJson', () {
      test('creates BoardUser from valid JSON', () {
        final user = BoardUser.fromJson(sampleUserJson);

        expect(user.id, equals('user-123'));
        expect(user.username, equals('testuser'));
      });
    });

    group('BoardUser.toJson', () {
      test('converts BoardUser to JSON correctly', () {
        final user = BoardUser.fromJson(sampleUserJson);
        final json = user.toJson();

        expect(json['id'], equals('user-123'));
        expect(json['username'], equals('testuser'));
      });
    });
  });

  group('BoardOwner Model Tests', () {
    final sampleOwnerJson = {'id': 'owner-123', 'username': 'testowner'};

    group('BoardOwner.fromJson', () {
      test('creates BoardOwner from valid JSON', () {
        final owner = BoardOwner.fromJson(sampleOwnerJson);

        expect(owner.id, equals('owner-123'));
        expect(owner.username, equals('testowner'));
      });
    });

    group('BoardOwner.toJson', () {
      test('converts BoardOwner to JSON correctly', () {
        final owner = BoardOwner.fromJson(sampleOwnerJson);
        final json = owner.toJson();

        expect(json['id'], equals('owner-123'));
        expect(json['username'], equals('testowner'));
      });
    });
  });
}
