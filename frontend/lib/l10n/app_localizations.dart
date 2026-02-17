import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Label for login action
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Label for registration action
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for username input field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label for password confirmation input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Title for the login screen
  ///
  /// In en, this message translates to:
  /// **'MyTrello - Login'**
  String get loginTitle;

  /// Title for the registration screen
  ///
  /// In en, this message translates to:
  /// **'MyTrello - Register'**
  String get registerTitle;

  /// Text for login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Text for register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// Validation message when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Validation message when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Validation message when username field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// Validation message when password field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Validation message when password and confirmation don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Success message after successful login
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// Success message after successful registration
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// Error message when registration fails
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailed(String error);

  /// Label for home screen or home button
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Action to create a new board
  ///
  /// In en, this message translates to:
  /// **'Create Board'**
  String get createBoard;

  /// Label for board title section
  ///
  /// In en, this message translates to:
  /// **'Board Title'**
  String get boardTitle;

  /// Generic title label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Section title for managing users and their permissions
  ///
  /// In en, this message translates to:
  /// **'Users & Permissions'**
  String get usersAndPermissions;

  /// Action to add a user to a board
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// Message shown when no users have been added to a board
  ///
  /// In en, this message translates to:
  /// **'No users added yet'**
  String get noUsersAddedYet;

  /// User role with read and write permissions
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// User role with read-only permissions
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get viewer;

  /// User role with full permissions including delete
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// Success message after creating a board
  ///
  /// In en, this message translates to:
  /// **'Board created successfully!'**
  String get boardCreatedSuccessfully;

  /// Error message when board creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create board: {error}'**
  String failedToCreateBoard(String error);

  /// Validation message when board title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a board title'**
  String get pleaseEnterBoardTitle;

  /// Action to save changes
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Action to cancel an operation
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Action to delete an item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Action to add an item
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Action to remove an item
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Action to confirm an operation
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Action or label for search functionality
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Message shown while content is loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Action to logout from the application
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Label for board settings screen
  ///
  /// In en, this message translates to:
  /// **'Board Settings'**
  String get boardSettings;

  /// Action to delete a board
  ///
  /// In en, this message translates to:
  /// **'Delete Board'**
  String get deleteBoard;

  /// Confirmation message before deleting a board
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this board?'**
  String get areYouSureDeleteBoard;

  /// Label for a card item
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// Label for a column in a board
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get column;

  /// Label for card due date
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// Label for card start date
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Action to add a new card
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// Label for user settings screen
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettings;

  /// Label for account settings section
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Label for preferences screen
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Label for app preferences section
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// Label for appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance Settings'**
  String get appearanceSettings;

  /// Label for display settings section
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displaySettings;

  /// Label for theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Label for language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Label for light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Label for system theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Label for show assigned cards toggle
  ///
  /// In en, this message translates to:
  /// **'Show Assigned Cards'**
  String get showAssignedCards;

  /// Description for show assigned cards toggle
  ///
  /// In en, this message translates to:
  /// **'Display assigned cards on the home screen'**
  String get showAssignedCardsInHomepageDescription;

  /// Success message after updating preferences
  ///
  /// In en, this message translates to:
  /// **'Preferences updated successfully'**
  String get preferencesUpdatedSuccessfully;

  /// Error message for failed preferences update
  ///
  /// In en, this message translates to:
  /// **'Failed to update preferences: {error}'**
  String failedToUpdatePreferences(String error);

  /// Error message for failed preferences load
  ///
  /// In en, this message translates to:
  /// **'Failed to load preferences: {error}'**
  String failedToLoadPreferences(String error);

  /// Label for account information section in user settings
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// Label for current password field
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Label for new password field
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Label for new password confirmation field
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// Validation message when board title is empty
  ///
  /// In en, this message translates to:
  /// **'Board title cannot be empty'**
  String get boardTitleCannotBeEmpty;

  /// Success message after updating a board
  ///
  /// In en, this message translates to:
  /// **'Board updated successfully!'**
  String get boardUpdatedSuccessfully;

  /// Error message when board update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update board: {error}'**
  String failedToUpdateBoard(String error);

  /// Confirmation message before deleting a specific board
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{boardName}\"? This action cannot be undone.'**
  String areYouSureDeleteBoardWithName(String boardName);

  /// Success message after deleting a board
  ///
  /// In en, this message translates to:
  /// **'Board deleted successfully'**
  String get boardDeletedSuccessfully;

  /// Error message when board deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete board: {error}'**
  String failedToDeleteBoard(String error);

  /// Label indicating the owner of a board
  ///
  /// In en, this message translates to:
  /// **'Board Owner'**
  String get boardOwner;

  /// Action to save changes
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Validation message when username is empty
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameCannotBeEmpty;

  /// Validation message when new username is same as current
  ///
  /// In en, this message translates to:
  /// **'New username must be different from current username'**
  String get newUsernameMustBeDifferent;

  /// Success message after updating username
  ///
  /// In en, this message translates to:
  /// **'Username updated successfully'**
  String get usernameUpdatedSuccessfully;

  /// Validation message when required fields are empty
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get allFieldsRequired;

  /// Validation message when new email is same as current
  ///
  /// In en, this message translates to:
  /// **'New email must be different from current email'**
  String get newEmailMustBeDifferent;

  /// Success message after updating email
  ///
  /// In en, this message translates to:
  /// **'Email updated successfully'**
  String get emailUpdatedSuccessfully;

  /// Validation message when new password and confirmation don't match
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// Validation message when new password is same as current
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordMustBeDifferent;

  /// Success message after updating password
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// Title for the home screen
  ///
  /// In en, this message translates to:
  /// **'MyTrello - Home'**
  String get homeTitle;

  /// Tooltip for create board button
  ///
  /// In en, this message translates to:
  /// **'Create New Board'**
  String get createNewBoard;

  /// Error message when boards fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading boards'**
  String get errorLoadingBoards;

  /// Error explanation when server is unreachable
  ///
  /// In en, this message translates to:
  /// **'The backend server may be down or unreachable.'**
  String get backendServerMayBeDown;

  /// Action to retry an operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message when user has no boards
  ///
  /// In en, this message translates to:
  /// **'No boards yet'**
  String get noBoardsYet;

  /// Hint message to create first board
  ///
  /// In en, this message translates to:
  /// **'Create your first board to get started!'**
  String get createFirstBoard;

  /// Placeholder for card search field
  ///
  /// In en, this message translates to:
  /// **'Search cards...'**
  String get searchCards;

  /// Label for update username section and button
  ///
  /// In en, this message translates to:
  /// **'Update Username'**
  String get updateUsername;

  /// Label for new username input field
  ///
  /// In en, this message translates to:
  /// **'New Username'**
  String get newUsername;

  /// Label for update email section and button
  ///
  /// In en, this message translates to:
  /// **'Update Email'**
  String get updateEmail;

  /// Label for new email input field
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// Label for update password section and button
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// Error message when board settings fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load board settings: {error}'**
  String failedToLoadBoardSettings(String error);

  /// Title for delete card dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// Confirmation message for deleting a card
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{cardTitle}\"?'**
  String deleteCardConfirmation(String cardTitle);

  /// Confirmation message for deleting a column
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the column \"{columnTitle}\"? All cards in this column will be deleted.'**
  String deleteColumnConfirmation(String columnTitle);

  /// Tooltip for delete card button
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteCardTooltip;

  /// Tooltip for assign users button
  ///
  /// In en, this message translates to:
  /// **'Assign users'**
  String get assignUsersTooltip;

  /// Tooltip for set deadlines button
  ///
  /// In en, this message translates to:
  /// **'Set deadlines'**
  String get setDeadlinesTooltip;

  /// Placeholder for card title field
  ///
  /// In en, this message translates to:
  /// **'Card title'**
  String get cardTitle;

  /// Placeholder for card description field
  ///
  /// In en, this message translates to:
  /// **'Card description'**
  String get cardDescription;

  /// Section title for cards assigned to the user
  ///
  /// In en, this message translates to:
  /// **'Assigned to You'**
  String get assignedToYou;

  /// Section title for user's boards
  ///
  /// In en, this message translates to:
  /// **'Your Boards'**
  String get yourBoards;

  /// Display count of members and viewers on a board
  ///
  /// In en, this message translates to:
  /// **'{members} members, {viewers} viewers'**
  String membersViewersCount(int members, int viewers);

  /// Placeholder for column title field
  ///
  /// In en, this message translates to:
  /// **'Column title'**
  String get columnTitle;

  /// Message shown when dragging item over drop zone
  ///
  /// In en, this message translates to:
  /// **'Drop here'**
  String get dropHere;

  /// Message shown when column has no cards
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get noCards;

  /// Tooltip for delete column button
  ///
  /// In en, this message translates to:
  /// **'Delete column'**
  String get deleteColumn;

  /// Display count of cards
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardsCount(int count);

  /// Default name for new column
  ///
  /// In en, this message translates to:
  /// **'New Column'**
  String get newColumn;

  /// Title for unassign user dialog
  ///
  /// In en, this message translates to:
  /// **'Unassign User'**
  String get unassignUser;

  /// Confirmation message to remove user from card
  ///
  /// In en, this message translates to:
  /// **'Remove {username} from this card?'**
  String removeUserFromCard(String username);

  /// Action to unassign user from card
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get unassign;

  /// Title for add card dialog
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardDialog;

  /// Title for board chat drawer
  ///
  /// In en, this message translates to:
  /// **'Board Chat'**
  String get boardChat;

  /// Placeholder for chat message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// Action to send a message
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Title for set deadlines dialog
  ///
  /// In en, this message translates to:
  /// **'Set Deadlines'**
  String get setDeadlines;

  /// Button text to select a date
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Tooltip to clear start date
  ///
  /// In en, this message translates to:
  /// **'Clear start date'**
  String get clearStartDate;

  /// Tooltip to clear due date
  ///
  /// In en, this message translates to:
  /// **'Clear due date'**
  String get clearDueDate;

  /// Display duration in days between dates
  ///
  /// In en, this message translates to:
  /// **'Duration: {days} days'**
  String durationDays(int days);

  /// Help text for start date picker
  ///
  /// In en, this message translates to:
  /// **'Select Start Date'**
  String get selectStartDate;

  /// Help text for due date picker
  ///
  /// In en, this message translates to:
  /// **'Select Due Date'**
  String get selectDueDate;

  /// Error message when loading users fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load users: {error}'**
  String failedToLoadUsers(String error);

  /// Error message when search fails
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailed(String error);

  /// Message when no users match search criteria
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
