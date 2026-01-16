import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false, // Remove all previous routes
        );
      });
      // Show a loading indicator while redirecting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return child;
  }
}
