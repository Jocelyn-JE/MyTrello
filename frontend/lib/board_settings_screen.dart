import 'package:flutter/material.dart';
import 'package:frontend/auth_service.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/models/board.dart';
import 'board_service.dart';
import 'user_search_dialog.dart';

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
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Board title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Board updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update board: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteBoard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Board'),
        content: Text(
          'Are you sure you want to delete "${widget.board.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await BoardService.deleteBoard(widget.board.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Board deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop twice: once for this screen, once to return to home
        Navigator.pop(context);
        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete board: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addUser() async {
    final excludedIds = [..._userPermissions.map((p) => p.userId)];

    final newUser = await showDialog<User>(
      context: context,
      builder: (context) => UserSearchDialog(
        excludedUserIds: excludedIds,
        ownerId: widget.board.ownerId,
      ),
    );

    if (newUser != null) {
      setState(() {
        _userPermissions.add(
          BoardUserPermission(
            userId: newUser.id,
            username: newUser.username,
            role: 'member',
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
      );
    });
    _markChanged();
  }

  Widget _buildUserPermissionCard(int index) {
    final permission = _userPermissions[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(permission.username),
        subtitle: DropdownButton<String>(
          value: permission.role,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'member', child: Text('Member')),
            DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Settings'),
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
                          const Text(
                            'Board Title',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
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
                          const Text(
                            'Owner',
                            style: TextStyle(
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
                            subtitle: const Text('Board Owner'),
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
                              const Text(
                                'Users & Permissions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_isOwner)
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _isLoading ? null : _addUser,
                                  tooltip: 'Add User',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_userPermissions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: Text('No users added yet')),
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
                      child: const Text('Save Changes'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _deleteBoard,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Delete Board'),
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
  final String role;

  BoardUserPermission({
    required this.userId,
    required this.username,
    required this.role,
  });
}
