import 'package:flutter/material.dart';
import 'package:frontend/services/api/users_service.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/utils/snackbar.dart';
import 'package:frontend/screens/user_settings_screen/widgets/user_info_card.dart';
import 'package:frontend/screens/user_settings_screen/widgets/update_username_section.dart';
import 'package:frontend/screens/user_settings_screen/widgets/update_email_section.dart';
import 'package:frontend/screens/user_settings_screen/widgets/update_password_section.dart';

class UserSettingsScreen extends StatefulWidget {
  final TrelloUser user;

  const UserSettingsScreen({super.key, required this.user});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  late TrelloUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserInfoCard(user: _currentUser),
            const SizedBox(height: 24),
            UpdateUsernameSection(
              currentUser: _currentUser,
              isLoading: _isLoading,
              onUpdate: _updateUsername,
            ),
            const SizedBox(height: 24),
            UpdateEmailSection(
              currentUser: _currentUser,
              isLoading: _isLoading,
              onUpdate: _updateEmail,
            ),
            const SizedBox(height: 24),
            UpdatePasswordSection(
              isLoading: _isLoading,
              onUpdate: _updatePassword,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUsername(String newUsername) async {
    if (newUsername.isEmpty) {
      showSnackBarWarning(context, 'Username cannot be empty');
      return;
    }

    if (newUsername == _currentUser.username) {
      showSnackBarWarning(
        context,
        'New username must be different from current username',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedUser = await UserService.updateUsername(newUsername);
      setState(() {
        _currentUser = updatedUser;
        _isLoading = false;
      });
      // Update the user in AuthService
      await AuthService.login(
        AuthService.token!,
        AuthService.userId!,
        updatedUser,
      );
      if (mounted) {
        showSnackBarSuccess(context, 'Username updated successfully');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showSnackBarWarning(context, e.toString());
      }
    }
  }

  Future<void> _updateEmail(String newEmail, String currentPassword) async {
    if (newEmail.isEmpty || currentPassword.isEmpty) {
      showSnackBarWarning(context, 'All fields are required');
      return;
    }

    if (newEmail == _currentUser.email) {
      showSnackBarWarning(
        context,
        'New email must be different from current email',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedUser = await UserService.updateEmail(
        newEmail,
        currentPassword,
      );
      setState(() {
        _currentUser = updatedUser;
        _isLoading = false;
      });
      // Update the user in AuthService
      await AuthService.login(
        AuthService.token!,
        AuthService.userId!,
        updatedUser,
      );
      if (mounted) {
        showSnackBarSuccess(context, 'Email updated successfully');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showSnackBarWarning(context, e.toString());
      }
    }
  }

  Future<void> _updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showSnackBarWarning(context, 'All fields are required');
      return;
    }

    if (newPassword != confirmPassword) {
      showSnackBarWarning(context, 'New passwords do not match');
      return;
    }

    if (newPassword == currentPassword) {
      showSnackBarWarning(
        context,
        'New password must be different from current password',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await UserService.updatePassword(currentPassword, newPassword);
      setState(() => _isLoading = false);
      if (mounted) {
        showSnackBarSuccess(context, 'Password updated successfully');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showSnackBarWarning(context, e.toString());
      }
    }
  }
}
