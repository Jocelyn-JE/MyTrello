import 'package:flutter/material.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/services/api/board_service.dart';
import 'package:frontend/widgets/confirmation_dialog.dart';
import 'package:frontend/widgets/user_search_dialog.dart';
import 'package:frontend/utils/snackbar.dart';
import 'package:frontend/l10n/app_localizations.dart';

class BoardSettingsScreen extends StatefulWidget {
  final Board board;

  const BoardSettingsScreen({super.key, required this.board});

  @override
  State<BoardSettingsScreen> createState() => _BoardSettingsScreenState();
}

class _BoardSettingsScreenState extends State<BoardSettingsScreen> {
  late TextEditingController _titleController;
  late List<BoardUserPermission> _userPermissions;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.board.title);
    _userPermissions = [..._buildUserPermissionsFromBoard()];
  }

  List<BoardUserPermission> _buildUserPermissionsFromBoard() {
    final permissions = <BoardUserPermission>[];

    // Add members
    for (final member in widget.board.members) {
      permissions.add(
        BoardUserPermission(
          userId: member.id,
          username: member.username,
          role: 'member',
          email: member.email,
        ),
      );
    }

    // Add viewers
    for (final viewer in widget.board.viewers) {
      permissions.add(
        BoardUserPermission(
          userId: viewer.id,
          username: viewer.username,
          role: 'viewer',
          email: viewer.email,
        ),
      );
    }

    return permissions;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _isOwner => widget.board.ownerId == AuthService.userId;

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      showSnackBarWarning(context, l10n.boardTitleCannotBeEmpty);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final users = _userPermissions
          .map((perm) => BoardUserInput(id: perm.userId, role: perm.role))
          .toList();

      await BoardService.updateBoard(
        boardId: widget.board.id,
        title: title,
        users: users,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasChanges = false;
        });
        showSnackBarSuccess(context, l10n.boardUpdatedSuccessfully);
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate changes were made
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackBarError(context, l10n.failedToUpdateBoard(e.toString()));
      }
    }
  }

  Future<void> _deleteBoard() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.deleteBoard,
      content: l10n.areYouSureDeleteBoardWithName(widget.board.title),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await BoardService.deleteBoard(widget.board.id);

      if (mounted) {
        showSnackBarSuccess(context, l10n.boardDeletedSuccessfully);
        // Pop twice: once for this screen, once to return to home
        Navigator.pop(context);
        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showSnackBarError(context, l10n.failedToDeleteBoard(e.toString()));
      }
    }
  }

  Future<void> _addUser() async {
    final excludedIds = [..._userPermissions.map((p) => p.userId)];

    final newUser = await showDialog<TrelloUser>(
      context: context,
      builder: (context) => UserSearchDialog(
        excludedUserIds: excludedIds,
        searchMode: UserSearchMode.usersNotInBoard,
        boardId: widget.board.id,
      ),
    );

    if (newUser != null) {
      setState(() {
        _userPermissions.add(
          BoardUserPermission(
            userId: newUser.id,
            username: newUser.username,
            role: 'member',
            email: newUser.email,
          ),
        );
      });
      _markChanged();
    }
  }

  void _removeUser(int index) {
    setState(() {
      _userPermissions.removeAt(index);
    });
    _markChanged();
  }

  void _updateUserRole(int index, String newRole) {
    setState(() {
      _userPermissions[index] = BoardUserPermission(
        userId: _userPermissions[index].userId,
        username: _userPermissions[index].username,
        role: newRole,
        email: _userPermissions[index].email,
      );
    });
    _markChanged();
  }

  Widget _buildUserPermissionCard(int index) {
    final l10n = AppLocalizations.of(context)!;
    final permission = _userPermissions[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text('${permission.username} (${permission.email ?? ''})'),
        subtitle: DropdownButton<String>(
          value: permission.role,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: 'member', child: Text(l10n.member)),
            DropdownMenuItem(value: 'viewer', child: Text(l10n.viewer)),
          ],
          onChanged: _isOwner && !_isLoading
              ? (String? newRole) {
                  if (newRole != null) {
                    _updateUserRole(index, newRole);
                  }
                }
              : null,
        ),
        trailing: _isOwner && !_isLoading
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeUser(index),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.boardSettings),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: l10n.title,
                              border: const OutlineInputBorder(),
                            ),
                            enabled: _isOwner,
                            onChanged: (_) => _markChanged(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Owner Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.owner,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.amber,
                            ),
                            title: Text(widget.board.owner.username),
                            subtitle: Text(l10n.boardOwner),
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
                              if (_isOwner)
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _isLoading ? null : _addUser,
                                  tooltip: l10n.addUser,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_userPermissions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(child: Text(l10n.noUsersAddedYet)),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _userPermissions.length,
                              itemBuilder: (context, index) {
                                return _buildUserPermissionCard(index);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isOwner) ...[
                    ElevatedButton(
                      onPressed: _hasChanges && !_isLoading
                          ? _saveChanges
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.saveChanges),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _deleteBoard,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.deleteBoard),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class BoardUserPermission {
  final String userId;
  final String username;
  final String? email;
  final String role;

  BoardUserPermission({
    required this.userId,
    required this.username,
    this.email,
    required this.role,
  });
}
