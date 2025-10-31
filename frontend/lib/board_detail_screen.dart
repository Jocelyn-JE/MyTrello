import 'package:flutter/material.dart';

/// Simple template / placeholder for a board detail screen.
/// Replace with real implementation (lists, cards, members, etc.).
class BoardDetailScreen extends StatelessWidget {
  final String? boardId;
  const BoardDetailScreen({super.key, this.boardId});

  /// Helper to create a route from a route name like '/board/:id'
  static Route<dynamic> routeFromSettings(RouteSettings settings) {
    final name = settings.name ?? '';
    final id = name.split('/').isNotEmpty ? name.split('/').last : null;
    return MaterialPageRoute(
      builder: (_) => BoardDetailScreen(boardId: id),
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedId =
        boardId ?? ModalRoute.of(context)?.settings.name ?? 'unknown';
    return Scaffold(
      appBar: AppBar(
        title: Text('Board Details'),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.view_kanban_outlined,
                size: 72,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text('Board ID:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                displayedId,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'This is a placeholder for the board detail screen.\nImplement lists, cards and interactions here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
