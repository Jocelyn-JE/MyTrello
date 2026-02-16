import 'package:flutter/material.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/services/api/users_service.dart';
import 'package:frontend/services/api/board_service.dart';
import 'package:frontend/l10n/app_localizations.dart';

enum UserSearchMode {
  /// Show all users (for board creation)
  allUsers,

  /// Show users not in the board (for adding members/viewers after creation)
  usersNotInBoard,

  /// Show board members not assigned to a card (for card assignment)
  boardMembersNotAssignedToCard,
}

class UserSearchDialog extends StatefulWidget {
  final List<String> excludedUserIds;
  final UserSearchMode searchMode;
  final String? boardId;
  final String? cardId;

  const UserSearchDialog({
    super.key,
    this.excludedUserIds = const [],
    this.searchMode = UserSearchMode.allUsers,
    this.boardId,
    this.cardId,
  });

  @override
  State<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<TrelloUser> _searchResults = [];
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadInitialUsers();
  }

  Future<void> _loadInitialUsers() async {
    setState(() => _loading = true);
    try {
      List<TrelloUser> users;

      switch (widget.searchMode) {
        case UserSearchMode.allUsers:
          // For board creation - show all users
          users = await UserService.getUsers();
          break;

        case UserSearchMode.usersNotInBoard:
          // For adding members/viewers - show users not in the board
          if (widget.boardId == null) {
            throw Exception('boardId required for usersNotInBoard mode');
          }
          // Search for users who are NOT members or viewers of the board
          users = await UserService.searchUsers(
            SearchParameters(
              boardId: widget.boardId,
              member: true,
              viewer: true,
              count: 100,
            ),
          );
          // Get all users and filter out those already in the board
          final allUsers = await UserService.getUsers();
          final boardUserIds = users.map((u) => u.id).toSet();
          users = allUsers
              .where((user) => !boardUserIds.contains(user.id))
              .toList();
          break;

        case UserSearchMode.boardMembersNotAssignedToCard:
          // For card assignment - show board members not assigned to the card
          if (widget.boardId == null || widget.cardId == null) {
            throw Exception(
              'boardId and cardId required for boardMembersNotAssignedToCard mode',
            );
          }
          users = await UserService.searchUsers(
            SearchParameters(
              boardId: widget.boardId,
              member: true,
              cardId: widget.cardId,
              assigned: false,
              count: 100,
            ),
          );
          break;
      }

      if (!mounted) return;
      setState(() {
        _searchResults = users
            .where((user) => !widget.excludedUserIds.contains(user.id))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.failedToLoadUsers(e.toString());
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      // Reload initial users if search is cleared
      _loadInitialUsers();
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _searchResults = [];
    });

    try {
      List<TrelloUser> results;

      switch (widget.searchMode) {
        case UserSearchMode.allUsers:
          // Search all users by username
          results = await UserService.searchUsers(
            SearchParameters(username: searchText, count: 100),
          );
          break;

        case UserSearchMode.usersNotInBoard:
          // Search users not in the board
          if (widget.boardId == null) {
            throw Exception('boardId required for usersNotInBoard mode');
          }
          // Get all users matching search
          final searchResults = await UserService.searchUsers(
            SearchParameters(username: searchText, count: 100),
          );
          // Get board members/viewers
          final boardUsers = await UserService.searchUsers(
            SearchParameters(
              boardId: widget.boardId,
              member: true,
              viewer: true,
              count: 100,
            ),
          );
          final boardUserIds = boardUsers.map((u) => u.id).toSet();
          results = searchResults
              .where((user) => !boardUserIds.contains(user.id))
              .toList();
          break;

        case UserSearchMode.boardMembersNotAssignedToCard:
          // Search board members not assigned to the card
          if (widget.boardId == null || widget.cardId == null) {
            throw Exception(
              'boardId and cardId required for boardMembersNotAssignedToCard mode',
            );
          }
          results = await UserService.searchUsers(
            SearchParameters(
              username: searchText,
              boardId: widget.boardId,
              member: true,
              cardId: widget.cardId,
              assigned: false,
              count: 100,
            ),
          );
          break;
      }

      if (!mounted) return;
      setState(() {
        _searchResults = results
            .where((user) => !widget.excludedUserIds.contains(user.id))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.searchFailed(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildUserItem(TrelloUser user) {
    return ListTile(
      title: Text(user.username),
      subtitle: Text(user.email),
      onTap: () {
        Navigator.of(context).pop(user);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: l10n.username),
              onSubmitted: (_) => _doSearch(),
            ),
            const SizedBox(height: 12),
            if (_loading) const CircularProgressIndicator(),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              ),
            if (!_loading)
              Expanded(
                child: _searchResults.isEmpty
                    ? Center(child: Text(l10n.noUsersFound))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return _buildUserItem(user);
                        },
                      ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _doSearch,
                    child: Text(l10n.search),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Unused helper function to show the dialog
Future<BoardUserInput?> showUserSearchDialog(
  BuildContext context, {
  required Future<List<BoardUserInput>> Function(String query) onSearch,
}) {
  return showDialog<BoardUserInput?>(
    context: context,
    builder: (context) => UserSearchDialog(),
  );
}
