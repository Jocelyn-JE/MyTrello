import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen/widgets/home_layout_widget.dart';
import 'package:frontend/screens/user_settings_screen/user_settings_screen.dart';
import 'package:frontend/screens/preferences_screen.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/services/api/board_service.dart';
import 'package:frontend/services/api/card_service.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/models/api/assigned_card.dart';
import 'package:frontend/utils/deterministic_color.dart';
import 'package:frontend/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Board> _boards = [];
  List<AssignedCard> _assignedCards = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final results = await Future.wait([
        BoardService.getBoards(),
        CardService.getAssignedCards(),
      ]);

      if (mounted) {
        setState(() {
          _boards = results[0] as List<Board>;
          _assignedCards = results[1] as List<AssignedCard>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });

        // If authentication failed, redirect to login
        if (e.toString().contains('Authentication failed')) {
          await AuthService.logout();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: PopupMenuButton<String>(
                offset: const Offset(0, kToolbarHeight),
                padding: EdgeInsets.zero,
                onSelected: (value) async {
                  if (value == 'settings') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserSettingsScreen(user: currentUser),
                      ),
                    );
                    // Reload if user data was updated
                    if (result == true) {
                      await AuthService.initialize();
                      setState(() {});
                    }
                  } else if (value == 'preferences') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreferencesScreen(),
                      ),
                    );
                    // Reload if preferences were updated
                    if (result == true) {
                      await _refreshData();
                    }
                  } else if (value == 'logout') {
                    await AuthService.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text(l10n.accountSettings),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'preferences',
                    child: Row(
                      children: [
                        const Icon(Icons.tune),
                        const SizedBox(width: 8),
                        Text(l10n.preferences),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(width: 8),
                        Text(l10n.logout),
                      ],
                    ),
                  ),
                ],
                child: CircleAvatar(
                  backgroundColor: getColorFromId(currentUser.id),
                  child: Text(
                    currentUser.username.isNotEmpty
                        ? currentUser.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else
            IconButton(
              padding: const EdgeInsets.only(right: 8.0),
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              tooltip: l10n.logout,
            ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(onRefresh: _refreshData, child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/createBoard');
          if (result == true) _refreshData();
        },
        tooltip: l10n.createNewBoard,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingBoards,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.backendServerMayBeDown,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    if (_boards.isEmpty && _assignedCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noBoardsYet,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(l10n.createFirstBoard),
          ],
        ),
      );
    }

    return HomeLayoutWidget(boards: _boards, assignedCards: _assignedCards);
  }
}
