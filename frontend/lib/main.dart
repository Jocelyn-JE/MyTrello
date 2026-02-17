import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/services/preferences_manager.dart';
import 'package:frontend/utils/app_config.dart';
import 'package:frontend/utils/app_routes.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/print_to_console.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.themeModeFromString(PreferencesManager().theme),
      locale: PreferencesManager().locale,
      initialRoute: AuthService.isLoggedIn ? AppRoutes.home : AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
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
}
