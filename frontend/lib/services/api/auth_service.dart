import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utils/app_config.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static String? _token;
  static String? _userId;
  static bool _isInitialized = false;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get token => _token;
  static String? get userId => _userId;

  // Initialize the auth service by loading saved data
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
    _isLoggedIn = _token != null && _token!.isNotEmpty;
    _isInitialized = true;
  }

  static Future<void> login(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    _isLoggedIn = true;
    _token = token;
    _userId = userId;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    _isLoggedIn = false;
    _token = null;
    _userId = null;
  }

  // Test-only method to reset the initialization state
  static void resetForTesting() {
    _isInitialized = false;
    _isLoggedIn = false;
    _token = null;
    _userId = null;
  }

  // API Methods
  static Future<void> loginWithCredentials(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(Duration(milliseconds: AppConfig.apiTimeout));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'] ?? '';
        final userId = responseData['user']['id'] ?? '';

        if (token.toString().isEmpty || userId.toString().isEmpty) {
          throw Exception('Invalid response: missing token or user ID');
        }

        // Set the authentication state
        await login(token, userId);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Unknown error';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      rethrow;
    }
  }

  static Future<void> register(
    String email,
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.backendUrl}/api/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'username': username,
              'password': password,
            }),
          )
          .timeout(Duration(milliseconds: AppConfig.apiTimeout));

      if (response.statusCode == 201) {
        // Registration successful
        return;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Unknown error';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      rethrow;
    }
  }
}
