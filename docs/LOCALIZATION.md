# Localization Implementation

## Overview

The MyTrello frontend now supports multiple languages through Flutter's l10n system. Currently supported languages:

- English (en/US)
- French (fr/FR)

## Files Structure

### Configuration Files

- **`l10n.yaml`**: Configuration for Flutter's localization generator
- **`pubspec.yaml`**: Updated with `generate: true` to enable l10n generation

### Localization Files

- **`lib/l10n/app_en.arb`**: English translations
- **`lib/l10n/app_fr.arb`**: French translations

Generated files (auto-generated on build):

- **`lib/l10n/app_localizations.dart`**: Main localization class
- **`lib/l10n/app_localizations_en.dart`**: English implementation
- **`lib/l10n/app_localizations_fr.dart`**: French implementation

## Usage

### In Widgets

```dart
import 'package:frontend/l10n/app_localizations.dart';

// In build method:
final l10n = AppLocalizations.of(context)!;

Text(l10n.login)  // Simple string
Text(l10n.loginFailed(errorMessage))  // String with placeholder
```

### Available Translations

- Authentication: login, register, email, password, etc.
- Board management: createBoard, boardTitle, member, viewer, etc.
- General: save, cancel, delete, edit, search, loading, etc.
- Messages: success messages, error messages, warnings

## Adding New Translations

### 1. Add to ARB files

Add the key-value pair to both `app_en.arb` and `app_fr.arb`:

**app_en.arb:**

```json
{
  "myNewKey": "My English Text",
  "@myNewKey": {
    "description": "Description of what this text is for"
  }
}
```

**app_fr.arb:**

```json
{
  "myNewKey": "Mon texte français"
}
```

### 2. For strings with placeholders

**app_en.arb:**

```json
{
  "welcomeUser": "Welcome, {username}!",
  "@welcomeUser": {
    "placeholders": {
      "username": {
        "type": "String"
      }
    }
  }
}
```

**app_fr.arb:**

```json
{
  "welcomeUser": "Bienvenue, {username}!"
}
```

### 3. Regenerate localization files

After adding or modifying translations in the ARB files, you need to regenerate the Dart localization files. Use the Flutter localization generation command:

```bash
flutter gen-l10n
```

This command reads the `l10n.yaml` configuration and ARB files, then generates:

- `lib/l10n/app_localizations.dart` - Main localization class with all translation methods
- `lib/l10n/app_localizations_en.dart` - English implementation
- `lib/l10n/app_localizations_fr.dart` - French implementation

Alternatively, these files are automatically generated when you build or run the app:

```bash
flutter build apk
flutter run
```
