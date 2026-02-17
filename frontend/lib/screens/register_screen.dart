import 'package:flutter/material.dart';
import 'package:frontend/utils/snackbar.dart';
import 'package:frontend/utils/regex.dart';
import 'package:frontend/widgets/password_field_widget.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();
    String passwordConfirm = _passwordConfirmController.text.trim();

    // Validation checks
    final validations = [
      (email.isEmpty, l10n.pleaseEnterEmail),
      (!isValidEmail(email), l10n.pleaseEnterValidEmail),
      (username.isEmpty, l10n.pleaseEnterUsername),
      (password.isEmpty, l10n.pleaseEnterPassword),
      (passwordConfirm != password, l10n.passwordsDoNotMatch),
    ];
    for (final (condition, message) in validations) {
      if (condition) {
        showSnackBarWarning(context, message);
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.register(email, username, password);

      if (mounted) {
        showSnackBarSuccess(context, l10n.registrationSuccessful);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        showSnackBarWarning(context, l10n.registrationFailed(errorMessage));
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: AutofillGroup(
                child: Column(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: l10n.email),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: l10n.username),
                      autofillHints: const [AutofillHints.newUsername],
                    ),
                    PasswordField(
                      controller: _passwordController,
                      labelText: l10n.password,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    PasswordField(
                      controller: _passwordConfirmController,
                      labelText: l10n.confirmPassword,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.registerButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
