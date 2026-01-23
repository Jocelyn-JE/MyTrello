import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/websocket/models/server_types.dart';
import 'package:frontend/services/board_service.dart';
import 'package:frontend/widgets/user_search_dialog.dart';
import 'package:frontend/utils/snackbar.dart';

class BoardCreationScreen extends StatefulWidget {
  const BoardCreationScreen({super.key});

  @override
  State<BoardCreationScreen> createState() => _BoardCreationScreenState();
}

class _BoardCreationScreenState extends State<BoardCreationScreen> {
  final TextEditingController titleController = TextEditingController();
  final List<BoardUserInput> usersInput = [];
  final List<TrelloUser> users = [];
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
        showSnackBarSuccess(context, 'Board created successfully!');
      }

      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackBarError(context, 'Failed to create board: ${e.toString()}');
      }
      return false;
    }
  }

  Future<void> _verifyParameters() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      showSnackBarWarning(context, 'Please enter a board title');
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
        title: Text(user.username),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
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
                                final newUser = await showDialog<TrelloUser>(
                                  context: context,
                                  builder: (context) => UserSearchDialog(
                                    excludedUserIds: [
                                      ...users.map((u) => u.id),
                                      if (AuthService.userId != null)
                                        AuthService.userId!,
                                    ],
                                    searchMode: UserSearchMode.allUsers,
                                  ),
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
