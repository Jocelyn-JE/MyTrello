import 'package:frontend/websocket/models/server_types.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/config.dart';

class SearchParameters {
  String? username;
  String? email;
  String? order; // 'asc' or 'desc'
  int? count;
  String? boardId;
  bool? member;
  bool? viewer;
  String? cardId;
  bool? assigned;

  SearchParameters({
    this.username,
    this.email,
    this.order,
    this.count,
    this.boardId,
    this.member,
    this.viewer,
    this.cardId,
    this.assigned,
  });
}

class UserService {
  static Future<List<TrelloUser>> getUsers() async {
    final response = await http.get(
      Uri.parse('${AppConfig.backendUrl}/api/users'),
    );
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return (jsonData as List)
          .map((user) => TrelloUser.fromJson(user))
          .toList();
    } else {
      throw Exception(
        'Failed to load users: ${jsonData['error'] ?? 'Unknown error'}',
      );
    }
  }

  static Future<List<TrelloUser>> getBoardMembers(String boardId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.backendUrl}/api/users/$boardId/members'),
    );
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return (jsonData as List)
          .map((user) => TrelloUser.fromJson(user))
          .toList();
    } else {
      throw Exception(
        'Failed to load board members: ${jsonData['error'] ?? 'Unknown error'}',
      );
    }
  }

  static Future<List<TrelloUser>> getBoardViewers(String boardId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.backendUrl}/api/users/$boardId/viewers'),
    );
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return (jsonData as List)
          .map((user) => TrelloUser.fromJson(user))
          .toList();
    } else {
      throw Exception(
        'Failed to load board viewers: ${jsonData['error'] ?? 'Unknown error'}',
      );
    }
  }

  static Future<List<TrelloUser>> searchUsers(SearchParameters params) async {
    final queryParameters = <String, String>{};
    if (params.username != null) queryParameters['username'] = params.username!;
    if (params.email != null) queryParameters['email'] = params.email!;
    if (params.order != null) queryParameters['order'] = params.order!;
    if (params.count != null) {
      queryParameters['count'] = params.count!.toString();
    }
    if (params.boardId != null) queryParameters['boardId'] = params.boardId!;
    if (params.member != null) {
      queryParameters['member'] = params.member!.toString();
    }
    if (params.viewer != null) {
      queryParameters['viewer'] = params.viewer!.toString();
    }
    if (params.cardId != null) queryParameters['cardId'] = params.cardId!;
    if (params.assigned != null) {
      queryParameters['assigned'] = params.assigned!.toString();
    }
    final response = await http.get(
      Uri.parse(
        '${AppConfig.backendUrl}/api/users/search?${Uri(queryParameters: queryParameters).query}',
      ),
    );
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return (jsonData as List)
          .map((user) => TrelloUser.fromJson(user))
          .toList();
    } else {
      throw Exception(
        'Failed to load users: ${jsonData['error'] ?? 'Unknown error'}',
      );
    }
  }
}
