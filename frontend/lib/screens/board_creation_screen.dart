import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/services/api/board_service.dart';
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
    final l10n = AppLocalizations.of(context)!;
    try {
      setState(() {
        _isLoading = true;
      });

      await BoardService.createBoard(title: title, users: users);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackBarSuccess(context, l10n.boardCreatedSuccessfully);
      }

      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackBarError(context, l10n.failedToCreateBoard(e.toString()));
      }
      return false;
    }
  }

  Future<void> _verifyParameters() async {
    final l10n = AppLocalizations.of(context)!;
    final title = titleController.text.trim();
    if (title.isEmpty) {
      showSnackBarWarning(context, l10n.pleaseEnterBoardTitle);
      return;
    }
    final success = await _createBoard(title, usersInput);
    // Only pop and signal success when the board creation succeeded.
    if (success && mounted) Navigator.pop(context, true);
  }

  Widget _buildUserItem(int index) {
    final l10n = AppLocalizations.of(context)!;
    final user = users[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text('${user.username} (${user.email})'),
        subtitle: DropdownButton<String>(
          value: usersInput[index].role,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: 'member', child: Text(l10n.member)),
            DropdownMenuItem(value: 'viewer', child: Text(l10n.viewer)),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createBoard)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Board Title Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.boardTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n.title,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Users and Permissions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.usersAndPermissions,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
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
                          tooltip: l10n.addUser,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (users.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: Text(l10n.noUsersAddedYet)),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return _buildUserItem(index);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyParameters,
              child: Text(l10n.createBoard),
            ),
          ],
        ),
      ),
    );
  }
}
