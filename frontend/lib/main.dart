import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/protected_routes.dart';
import 'package:frontend/login_screen.dart';
import 'package:frontend/register_screen.dart';
import 'package:frontend/home_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/board_creation_screen.dart';
import 'package:frontend/board_detail_screen.dart';
import 'package:frontend/utils/regex.dart';

void main() async {
  // Ensure that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthService to load saved authentication state
  await AuthService.initialize();

  // Load environment variables (optional)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env file not found or failed to load - use default values
    if (kDebugMode) {
      print('Warning: .env file not found, using default configuration');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTrello',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      initialRoute: AuthService.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const ProtectedRoute(child: HomeScreen()),
        '/createBoard': (context) =>
            const ProtectedRoute(child: BoardCreationScreen()),
      },
      // Handle dynamic routes like '/board/186eca85-c43a-46db-a826-fb4a5b112cde'
      onGenerateRoute: (RouteSettings settings) {
        final route = settings.name ?? '';
        if (_boardRouteIsValid(route)) {
          final boardId = route.substring('/board/'.length);
          return BoardDetailScreen.routeFromSettings(settings, boardId);
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
    );
  }

  bool _boardRouteIsValid(String route) {
    final startsWithBoard = route.startsWith('/board/');
    if (!startsWithBoard) return false;
    final boardId = route.substring('/board/'.length);
    if (boardId.isEmpty || !isValidUUIDv4(boardId)) return false;
    return true;
  }
}
