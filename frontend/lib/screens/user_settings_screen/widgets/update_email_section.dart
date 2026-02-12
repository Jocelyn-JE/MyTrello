import 'package:flutter/material.dart';
import 'package:frontend/models/websocket/server_types.dart';

class UpdateEmailSection extends StatelessWidget {
  final TrelloUser currentUser;
  final bool isLoading;
  final Function(String email, String password) onUpdate;

  const UpdateEmailSection({
    super.key,
    required this.currentUser,
    required this.isLoading,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController(text: currentUser.email);
    final passwordController = TextEditingController();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Email',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => onUpdate(
                        emailController.text,
                        passwordController.text,
                      ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
