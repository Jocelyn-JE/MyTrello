import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/utils/config.dart';
import 'package:frontend/utils/regex.dart';
import 'package:frontend/widgets/password_field.dart';

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

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

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
        _showSnackBar(message, color: Colors.red);
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });
    // Call the backend API
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.backendUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _showSnackBar('Registration successful!', color: Colors.green);
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error'] ?? 'Unknown error';
          _showSnackBar(
            'Registration failed: $errorMessage',
            color: Colors.orangeAccent,
          );
        }
      }
    } catch (e) {
      // Handle network error
      if (mounted) _showSnackBar('Error: $e');
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
