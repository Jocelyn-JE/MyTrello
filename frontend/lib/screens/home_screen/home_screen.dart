import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen/widgets/home_layout_widget.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/services/api/board_service.dart';
import 'package:frontend/services/api/card_service.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/models/api/assigned_card.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTrello - Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Handle logout
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(onRefresh: _refreshData, child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/createBoard');
          if (result == true) _refreshData();
        },
        tooltip: 'Create New Board',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
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
              'Error loading boards',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'The backend server may be down or unreachable.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_boards.isEmpty && _assignedCards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No boards yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Create your first board to get started!'),
          ],
        ),
      );
    }

    return HomeLayoutWidget(boards: _boards, assignedCards: _assignedCards);
  }
}
