import 'package:flutter/material.dart';
import 'package:frontend/utils/snackbar.dart';
import 'package:frontend/utils/regex.dart';
import 'package:frontend/widgets/password_field_widget.dart';
import 'package:frontend/services/api/auth_service.dart';

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
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();
    String passwordConfirm = _passwordConfirmController.text.trim();

    // Validation checks
    final validations = [
      (email.isEmpty, 'Please enter your email'),
      (!isValidEmail(email), 'Please enter a valid email address'),
      (username.isEmpty, 'Please enter your username'),
      (password.isEmpty, 'Please enter your password'),
      (passwordConfirm != password, 'Passwords do not match'),
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
        showSnackBarSuccess(context, 'Registration successful!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        showSnackBarWarning(context, 'Registration failed: $errorMessage');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTrello - Register'),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
      ),
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
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      autofillHints: const [AutofillHints.newUsername],
                    ),
                    PasswordField(
                      controller: _passwordController,
                      labelText: 'Password',
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    PasswordField(
                      controller: _passwordConfirmController,
                      labelText: 'Confirm Password',
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
                            : const Text('Register'),
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
