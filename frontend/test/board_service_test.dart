import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/api/board_service.dart';
import 'package:frontend/services/api/auth_service.dart';

void main() {
  group('BoardService Tests', () {
    setUp(() {
      AuthService.resetForTesting();
    });

    tearDown(() {
      AuthService.resetForTesting();
    });

    group('getBoards', () {
      test('throws exception when no token is available', () async {
        // Execute & Verify
        expect(
          () => BoardService.getBoards(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No authentication token found'),
            ),
          ),
        );
      });
    });

    group('createBoard', () {
      test('throws exception when no token is available', () async {
        // Execute & Verify
        expect(
          () => BoardService.createBoard(title: 'Test', users: []),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No authentication token found'),
            ),
          ),
        );
      });
    });
  });

  group('BoardUserInput Tests', () {
    test('converts to JSON correctly', () {
      final userInput = BoardUserInput(id: 'user-123', role: 'member');
      final json = userInput.toJson();

      expect(json['id'], equals('user-123'));
      expect(json['role'], equals('member'));
    });
  });
}
