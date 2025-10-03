import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'regex.dart';
import 'password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
        Uri.parse('${AppConfig.backendUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showSnackBar('Login successful!', color: Colors.green);
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      } else {
        if (mounted) {
          _showSnackBar(
            'Invalid email or password',
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
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
