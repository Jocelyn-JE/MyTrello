import 'package:flutter/material.dart';
import 'package:frontend/models/websocket/server_types.dart';

class UpdateUsernameSection extends StatelessWidget {
  final TrelloUser currentUser;
  final bool isLoading;
  final Function(String) onUpdate;

  const UpdateUsernameSection({
    super.key,
    required this.currentUser,
    required this.isLoading,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController(
      text: currentUser.username,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Username',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'New Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => onUpdate(usernameController.text),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Username'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
