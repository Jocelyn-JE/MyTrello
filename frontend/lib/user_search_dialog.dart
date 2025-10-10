import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/users_service.dart';
import 'board_service.dart';

class UserSearchDialog extends StatefulWidget {
  const UserSearchDialog({super.key});

  @override
  State<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
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
      final users = await UserService.getUsers();
      if (!mounted) return;
      setState(() {
        _searchResults = users;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load users';
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
    final SearchParameters query = SearchParameters(
      username: _searchController.text.trim(),
      count: 100,
    );
    if (query.username == null) return;
    setState(() {
      _loading = true;
      _error = '';
      _searchResults = [];
    });
    try {
      final results = await UserService.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Search failed';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildUserItem(User user) {
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
              decoration: const InputDecoration(labelText: 'Username'),
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
                    ? const Center(child: Text('No users found.'))
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
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _doSearch,
                    child: const Text('Search'),
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

Future<BoardUserInput?> showUserSearchDialog(
  BuildContext context, {
  required Future<List<BoardUserInput>> Function(String query) onSearch,
}) {
  return showDialog<BoardUserInput?>(
    context: context,
    builder: (context) => UserSearchDialog(),
  );
}
