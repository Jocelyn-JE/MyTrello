import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utils/app_config.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/models/api/user_preferences.dart';

class PreferencesService {
  /// Get user preferences
  static Future<UserPreferences> getPreferences() async {
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No authentication token found');

      final response = await http
          .get(
            Uri.parse('${AppConfig.backendUrl}/api/preferences'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(milliseconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserPreferences.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Preferences not found');
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error'] ?? 'Failed to fetch preferences';
          throw Exception(errorMessage);
        } catch (jsonError) {
          throw Exception(
            'Failed to fetch preferences. Server returned status ${response.statusCode}',
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

  /// Update user preferences
  /// At least one of [localization], [theme], or [showAssignedCardsInHomepage] must be provided
  static Future<UserPreferences> updatePreferences({
    String? localization,
    String? theme,
    bool? showAssignedCardsInHomepage,
  }) async {
    try {
      final token = AuthService.token;
      if (token == null) throw Exception('No authentication token found');

      // Build the request body with only provided fields
      final Map<String, dynamic> requestBody = {};
      if (localization != null) requestBody['localization'] = localization;
      if (theme != null) requestBody['theme'] = theme;
      if (showAssignedCardsInHomepage != null) {
        requestBody['showAssignedCardsInHomepage'] =
            showAssignedCardsInHomepage;
      }

      // Validate that at least one field is provided
      if (requestBody.isEmpty) {
        throw Exception('At least one field must be provided');
      }

      final response = await http
          .patch(
            Uri.parse('${AppConfig.backendUrl}/api/preferences'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(Duration(milliseconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserPreferences.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 400) {
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error'] ?? 'Invalid preferences format';
          throw Exception(errorMessage);
        } catch (jsonError) {
          throw Exception('Invalid preferences format');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['error'] ?? 'Failed to update preferences';
          throw Exception(errorMessage);
        } catch (jsonError) {
          throw Exception(
            'Failed to update preferences. Server returned status ${response.statusCode}',
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
