import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/protected_routes.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'auth_service.dart';
import 'board_creation_screen.dart';
import 'board_detail_screen.dart';

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
      // Handle dynamic routes like '/board/123'
      onGenerateRoute: (RouteSettings settings) {
        final name = settings.name ?? '';
        if (name.startsWith('/board/')) {
          return BoardDetailScreen.routeFromSettings(settings);
        }
        return null;
      },
    );
  }
}
