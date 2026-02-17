import 'package:flutter/material.dart';
import 'package:frontend/utils/protected_routes.dart';
import 'package:frontend/utils/regex.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/home_screen/home_screen.dart';
import 'package:frontend/screens/board_creation_screen.dart';
import 'package:frontend/screens/board_detail/board_detail_screen.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createBoard = '/createBoard';

  // Named routes
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const ProtectedRoute(child: HomeScreen()),
    createBoard: (context) =>
        const ProtectedRoute(child: BoardCreationScreen()),
  };

  // Handle dynamic routes like '/board/186eca85-c43a-46db-a826-fb4a5b112cde'
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final route = settings.name ?? '';
    if (_isBoardRoute(route)) {
      final boardId = route.substring('/board/'.length);
      return BoardDetailScreen.routeFromSettings(settings, boardId);
    }
    return null;
  }

  // Validate board route format
  static bool _isBoardRoute(String route) {
    if (!route.startsWith('/board/')) return false;
    final boardId = route.substring('/board/'.length);
    return boardId.isNotEmpty && isValidUUIDv4(boardId);
  }
}
