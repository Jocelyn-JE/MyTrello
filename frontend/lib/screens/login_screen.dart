import 'package:flutter/material.dart';
import 'package:frontend/utils/snackbar.dart';
import 'package:frontend/utils/regex.dart';
import 'package:frontend/widgets/password_field_widget.dart';
import 'package:frontend/services/api/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.isLoggedIn) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false, // Remove all previous routes
        );
      }
    });
  }

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    // Validation checks
    final validations = [
      (email.isEmpty, 'Please enter your email'),
      (!isValidEmail(email), 'Please enter a valid email address'),
      (password.isEmpty, 'Please enter your password'),
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
      await AuthService.loginWithCredentials(email, password);

      if (mounted) {
        showSnackBarSuccess(context, 'Login successful!');
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        showSnackBarWarning(context, 'Login failed: $errorMessage');
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
        title: const Text('MyTrello - Login'),
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
                      autofillHints: const [
                        AutofillHints.email,
                        AutofillHints.username,
                      ],
                    ),
                    PasswordField(
                      controller: _passwordController,
                      labelText: 'Password',
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the registration screen
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text('Register'),
                          ),
                        ),
                      ],
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
    super.dispose();
  }
}
