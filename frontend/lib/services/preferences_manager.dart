import 'package:flutter/material.dart';
import 'package:frontend/services/api/preferences_service.dart';
import 'package:frontend/utils/print_to_console.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager extends ChangeNotifier {
  static PreferencesManager? _instance;

  PreferencesManager._internal();

  factory PreferencesManager() {
    _instance ??= PreferencesManager._internal();
    return _instance!;
  }

  static const String _localizationKey = 'localization';
  static const String _themeKey = 'theme';
  static const String _showAssignedCardsKey = 'showAssignedCardsInHomepage';

  Locale _locale = const Locale('en', 'US');
  String _theme = 'system';
  bool _showAssignedCardsInHomepage = true;
  bool _isInitialized = false;

  Locale get locale => _locale;
  String get theme => _theme;
  bool get showAssignedCardsInHomepage => _showAssignedCardsInHomepage;
  bool get isInitialized => _isInitialized;

  /// Initialize preferences from local storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load localization
      final localizationCode = prefs.getString(_localizationKey) ?? 'en';
      _locale = _getLocaleFromCode(localizationCode);

      // Load theme
      _theme = prefs.getString(_themeKey) ?? 'system';

      // Load show assigned cards
      _showAssignedCardsInHomepage =
          prefs.getBool(_showAssignedCardsKey) ?? true;

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      printToConsole('Error initializing preferences: $e');
      _isInitialized = true;
    }
  }

  /// Update localization and persist to local storage
  Future<void> setLocalization(String localizationCode) async {
    final newLocale = _getLocaleFromCode(localizationCode);
    if (_locale == newLocale) return;

    _locale = newLocale;

    try {
      await _saveToLocalStorage(_localizationKey, localizationCode);
    } catch (e) {
      printToConsole('Error saving localization preference: $e');
    }

    notifyListeners();
  }

  /// Update theme and persist to local storage
  Future<void> setTheme(String theme) async {
    if (_theme == theme) return;

    _theme = theme;

    try {
      await _saveToLocalStorage(_themeKey, theme);
    } catch (e) {
      printToConsole('Error saving theme preference: $e');
    }

    notifyListeners();
  }

  /// Update show assigned cards and persist to local storage
  Future<void> setShowAssignedCardsInHomepage(bool show) async {
    if (_showAssignedCardsInHomepage == show) return;

    _showAssignedCardsInHomepage = show;

    try {
      await _saveToLocalStorage(_showAssignedCardsKey, show);
    } catch (e) {
      printToConsole('Error saving show assigned cards preference: $e');
    }

    notifyListeners();
  }

  /// Sync preferences from API response
  void update({
    String? localization,
    String? theme,
    bool? showAssignedCardsInHomepage,
  }) {
    bool hasChanges = false;

    if (localization != null && _getLocaleFromCode(localization) != _locale) {
      _locale = _getLocaleFromCode(localization);
      _saveToLocalStorage(_localizationKey, localization);
      hasChanges = true;
    }

    if (theme != null && theme != _theme) {
      _theme = theme;
      _saveToLocalStorage(_themeKey, theme);
      hasChanges = true;
    }

    if (showAssignedCardsInHomepage != null &&
        showAssignedCardsInHomepage != _showAssignedCardsInHomepage) {
      _showAssignedCardsInHomepage = showAssignedCardsInHomepage;
      _saveToLocalStorage(_showAssignedCardsKey, showAssignedCardsInHomepage);
      hasChanges = true;
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<void> _saveToLocalStorage(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      }
    } catch (e) {
      printToConsole('Error saving $key to local storage: $e');
    }
  }

  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case 'fr':
        return const Locale('fr', 'FR');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  Future<void> updateFromApi() async {
    final apiPreferences = await PreferencesService.getPreferences();
    update(
      localization: apiPreferences.localization,
      theme: apiPreferences.theme,
      showAssignedCardsInHomepage: apiPreferences.showAssignedCardsInHomepage,
    );
  }
}
