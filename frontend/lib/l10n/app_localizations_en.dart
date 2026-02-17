// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get loginTitle => 'MyTrello - Login';

  @override
  String get registerTitle => 'MyTrello - Register';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get loginSuccessful => 'Login successful!';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get registrationSuccessful => 'Registration successful!';

  @override
  String registrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get home => 'Home';

  @override
  String get createBoard => 'Create Board';

  @override
  String get boardTitle => 'Board Title';

  @override
  String get title => 'Title';

  @override
  String get usersAndPermissions => 'Users & Permissions';

  @override
  String get addUser => 'Add User';

  @override
  String get noUsersAddedYet => 'No users added yet';

  @override
  String get member => 'Member';

  @override
  String get viewer => 'Viewer';

  @override
  String get owner => 'Owner';

  @override
  String get boardCreatedSuccessfully => 'Board created successfully!';

  @override
  String failedToCreateBoard(String error) {
    return 'Failed to create board: $error';
  }

  @override
  String get pleaseEnterBoardTitle => 'Please enter a board title';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get logout => 'Logout';

  @override
  String get boardSettings => 'Board Settings';

  @override
  String get deleteBoard => 'Delete Board';

  @override
  String get areYouSureDeleteBoard =>
      'Are you sure you want to delete this board?';

  @override
  String get card => 'Card';

  @override
  String get column => 'Column';

  @override
  String get dueDate => 'Due Date';

  @override
  String get startDate => 'Start Date';

  @override
  String get description => 'Description';

  @override
  String get addCard => 'Add Card';

  @override
  String get userSettings => 'User Settings';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get appearanceSettings => 'Appearance Settings';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get showAssignedCards => 'Show Assigned Cards';

  @override
  String get showAssignedCardsInHomepageDescription =>
      'Display assigned cards on the home screen';

  @override
  String get preferencesUpdatedSuccessfully =>
      'Preferences updated successfully';

  @override
  String failedToUpdatePreferences(String error) {
    return 'Failed to update preferences: $error';
  }

  @override
  String failedToLoadPreferences(String error) {
    return 'Failed to load preferences: $error';
  }

  @override
  String get accountInformation => 'Account Information';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get boardTitleCannotBeEmpty => 'Board title cannot be empty';

  @override
  String get boardUpdatedSuccessfully => 'Board updated successfully!';

  @override
  String failedToUpdateBoard(String error) {
    return 'Failed to update board: $error';
  }

  @override
  String areYouSureDeleteBoardWithName(String boardName) {
    return 'Are you sure you want to delete \"$boardName\"? This action cannot be undone.';
  }

  @override
  String get boardDeletedSuccessfully => 'Board deleted successfully';

  @override
  String failedToDeleteBoard(String error) {
    return 'Failed to delete board: $error';
  }

  @override
  String get boardOwner => 'Board Owner';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get usernameCannotBeEmpty => 'Username cannot be empty';

  @override
  String get newUsernameMustBeDifferent =>
      'New username must be different from current username';

  @override
  String get usernameUpdatedSuccessfully => 'Username updated successfully';

  @override
  String get allFieldsRequired => 'All fields are required';

  @override
  String get newEmailMustBeDifferent =>
      'New email must be different from current email';

  @override
  String get emailUpdatedSuccessfully => 'Email updated successfully';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match';

  @override
  String get newPasswordMustBeDifferent =>
      'New password must be different from current password';

  @override
  String get passwordUpdatedSuccessfully => 'Password updated successfully';

  @override
  String get homeTitle => 'MyTrello - Home';

  @override
  String get createNewBoard => 'Create New Board';

  @override
  String get errorLoadingBoards => 'Error loading boards';

  @override
  String get backendServerMayBeDown =>
      'The backend server may be down or unreachable.';

  @override
  String get retry => 'Retry';

  @override
  String get noBoardsYet => 'No boards yet';

  @override
  String get createFirstBoard => 'Create your first board to get started!';

  @override
  String get searchCards => 'Search cards...';

  @override
  String get updateUsername => 'Update Username';

  @override
  String get newUsername => 'New Username';

  @override
  String get updateEmail => 'Update Email';

  @override
  String get newEmail => 'New Email';

  @override
  String get updatePassword => 'Update Password';

  @override
  String failedToLoadBoardSettings(String error) {
    return 'Failed to load board settings: $error';
  }

  @override
  String get deleteCard => 'Delete Card';

  @override
  String deleteCardConfirmation(String cardTitle) {
    return 'Are you sure you want to delete \"$cardTitle\"?';
  }

  @override
  String deleteColumnConfirmation(String columnTitle) {
    return 'Are you sure you want to delete the column \"$columnTitle\"? All cards in this column will be deleted.';
  }

  @override
  String get deleteCardTooltip => 'Delete card';

  @override
  String get assignUsersTooltip => 'Assign users';

  @override
  String get setDeadlinesTooltip => 'Set deadlines';

  @override
  String get cardTitle => 'Card title';

  @override
  String get cardDescription => 'Card description';

  @override
  String get assignedToYou => 'Assigned to You';

  @override
  String get yourBoards => 'Your Boards';

  @override
  String membersViewersCount(int members, int viewers) {
    return '$members members, $viewers viewers';
  }

  @override
  String get columnTitle => 'Column title';

  @override
  String get dropHere => 'Drop here';

  @override
  String get noCards => 'No cards';

  @override
  String get deleteColumn => 'Delete column';

  @override
  String cardsCount(int count) {
    return '$count cards';
  }

  @override
  String get newColumn => 'New Column';

  @override
  String get unassignUser => 'Unassign User';

  @override
  String removeUserFromCard(String username) {
    return 'Remove $username from this card?';
  }

  @override
  String get unassign => 'Unassign';

  @override
  String get addCardDialog => 'Add Card';

  @override
  String get boardChat => 'Board Chat';

  @override
  String get typeMessage => 'Type a message';

  @override
  String get send => 'Send';

  @override
  String get setDeadlines => 'Set Deadlines';

  @override
  String get selectDate => 'Select Date';

  @override
  String get clearStartDate => 'Clear start date';

  @override
  String get clearDueDate => 'Clear due date';

  @override
  String durationDays(int days) {
    return 'Duration: $days days';
  }

  @override
  String get selectStartDate => 'Select Start Date';

  @override
  String get selectDueDate => 'Select Due Date';

  @override
  String failedToLoadUsers(String error) {
    return 'Failed to load users: $error';
  }

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get noUsersFound => 'No users found.';
}
