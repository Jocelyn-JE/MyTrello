import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'board_service.dart';
import 'user_search_dialog.dart';

class BoardCreationScreen extends StatefulWidget {
  const BoardCreationScreen({super.key});

  @override
  State<BoardCreationScreen> createState() => _BoardCreationScreenState();
}

class _BoardCreationScreenState extends State<BoardCreationScreen> {
  final TextEditingController titleController = TextEditingController();
  final List<BoardUserInput> usersInput = [];
  final List<User> users = [];
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<bool> _createBoard(String title, List<BoardUserInput> users) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await BoardService.createBoard(title: title, users: users);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Board created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create board: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _verifyParameters() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a board title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final success = await _createBoard(title, usersInput);
    // Only pop and signal success when the board creation succeeded.
    if (success && mounted) Navigator.pop(context, true);
  }

  Widget _buildUserItem(int index) {
    final user = users[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text('User: ${user.username}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Email: ${user.email}'),
            Text('User ID: ${user.id}'),
            DropdownButton<String>(
              value: usersInput[index].role,
              items: const [
                DropdownMenuItem(value: 'member', child: Text('Member')),
                DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
              ],
              onChanged: (String? newRole) {
                if (newRole != null) {
                  setState(() {
                    usersInput[index] = BoardUserInput(
                      id: usersInput[index].id,
                      role: newRole,
                    );
                  });
                }
              },
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              users.removeAt(index);
              usersInput.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Board'),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Board Title'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length + 1, // +1 for the add button
                itemBuilder: (context, index) {
                  if (index == users.length) {
                    // This is the last item - show the add button
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final newUser = await showDialog<User>(
                                  context: context,
                                  builder: (context) => UserSearchDialog(),
                                );
                                if (newUser != null) {
                                  setState(() {
                                    users.add(newUser);
                                    usersInput.add(
                                      BoardUserInput(
                                        id: newUser.id,
                                        role: 'member',
                                      ),
                                    );
                                  });
                                }
                              },
                        icon: const Icon(Icons.add),
                        label: const Text('Add User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.blue.shade700,
                        ),
                      ),
                    );
                  } else {
                    // Show existing user item
                    return _buildUserItem(index);
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyParameters,
              child: const Text('Create Board'),
            ),
          ],
        ),
      ),
    );
  }
}
