import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'auth_service.dart';
import 'models/board.dart';

class BoardService {
  static Future<List<Board>> getBoards() async {
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No authentication token found');
      final response = await http
          .get(
            Uri.parse('${AppConfig.backendUrl}/api/boards'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(milliseconds: AppConfig.apiTimeout));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final boardsJson = responseData['boards'] as List<dynamic>;

        return boardsJson
            .map(
              (boardJson) => Board.fromJson(boardJson as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Failed to fetch boards';
          throw Exception(errorMessage);
        } catch (jsonError) {
          // If response body is not valid JSON, throw a generic error
          throw Exception(
            'Failed to fetch boards. Server returned status ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      rethrow;
    }
  }

  static Future<Board> createBoard({
    required String title,
    required List<BoardUserInput> users,
  }) async {
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No authentication token found');
      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/boards'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({
              'title': title,
              'users': users.map((user) => user.toJson()).toList(),
            }),
          )
          .timeout(Duration(milliseconds: AppConfig.apiTimeout));
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Board.fromJson(responseData['board']);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Failed to create board';
          throw Exception(errorMessage);
        } catch (jsonError) {
          // If response body is not valid JSON, throw a generic error
          throw Exception(
            'Failed to create board. Server returned status ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      rethrow;
    }
  }
}

class BoardUserInput {
  final String id;
  final String role; // "member" or "viewer"

  BoardUserInput({required this.id, required this.role});

  Map<String, dynamic> toJson() {
    return {'id': id, 'role': role};
  }

  factory BoardUserInput.fromJson(Map<String, dynamic> json) {
    return BoardUserInput(
      id: json['id'] as String,
      role: json['role'] as String,
    );
  }
}
