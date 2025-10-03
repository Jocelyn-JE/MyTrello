import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static String? _token;
  static bool _isInitialized = false;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get token => _token;

  // Initialize the auth service by loading saved data
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isLoggedIn = _token != null && _token!.isNotEmpty;
    _isInitialized = true;
  }

  static Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _isLoggedIn = true;
    _token = token;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _isLoggedIn = false;
    _token = null;
  }

  // Test-only method to reset the initialization state
  static void resetForTesting() {
    _isInitialized = false;
    _isLoggedIn = false;
    _token = null;
  }
}
