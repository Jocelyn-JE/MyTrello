import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/app_config.dart';
import 'package:frontend/utils/print_to_console.dart';
import 'package:frontend/utils/protected_routes.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/register_screen.dart';
import 'package:frontend/screens/home_screen/home_screen.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/services/preferences_manager.dart';
import 'package:frontend/screens/board_creation_screen.dart';
import 'package:frontend/screens/board_detail/board_detail_screen.dart';
import 'package:frontend/utils/regex.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() async {
  // Ensure that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthService to load saved authentication state
  await AuthService.initialize();

  // Initialize PreferencesManager to load saved preferences
  await PreferencesManager().initialize();

  // Load environment variables (optional)
  try {
    await dotenv.load(fileName: '.env');
    printToConsole('.env file loaded successfully');
    AppConfig.printConfig();
  } catch (e) {
    // .env file not found or failed to load - use default values
    printToConsole('Warning: .env file not found, using default configuration');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to preference changes
    PreferencesManager().addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    PreferencesManager().removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTrello',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      locale: PreferencesManager().locale,
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
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
