import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utils/app_config.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/models/api/assigned_card.dart';

class CardService {
  static Future<List<AssignedCard>> getAssignedCards() async {
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No authentication token found');

      final response = await http
          .get(
            Uri.parse('${AppConfig.backendUrl}/api/cards/assigned'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(milliseconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final cardsJson = responseData['cards'] as List<dynamic>;

        return cardsJson
            .map(
              (cardJson) =>
                  AssignedCard.fromJson(cardJson as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error'] ?? 'Failed to fetch assigned cards';
          throw Exception(errorMessage);
        } catch (jsonError) {
          throw Exception(
            'Failed to fetch assigned cards. Server returned status ${response.statusCode}',
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
