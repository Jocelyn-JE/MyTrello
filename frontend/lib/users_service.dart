import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'models/user.dart';

class SearchParameters {
  String? username;
  String? email;
  String? order; // 'asc' or 'desc'
  int? count;

  SearchParameters({this.username, this.email, this.order, this.count});
}

class UserService {
  static Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('${AppConfig.backendUrl}/api/users'),
    );
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return (jsonData as List).map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception(
        'Failed to load users: ${jsonData['error'] ?? 'Unknown error'}',
      );
    }
  }

  static Future<List<User>> searchUsers(SearchParameters params) async {
    final queryParameters = <String, String>{};
    if (params.username != null) queryParameters['username'] = params.username!;
    if (params.email != null) queryParameters['email'] = params.email!;
    if (params.order != null) queryParameters['order'] = params.order!;
    if (params.count != null) {
      queryParameters['count'] = params.count!.toString();
    }
    final response = await http.get(
      Uri.parse(
        '${AppConfig.backendUrl}/api/users/search?${Uri(queryParameters: queryParameters).query}',
      ),
    );
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return (jsonData as List).map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception(
        'Failed to load users: ${jsonData['error'] ?? 'Unknown error'}',
      );
    }
  }
}
