import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/protected_routes.dart';
import 'websocket_service.dart';

class BoardDetailScreen extends StatefulWidget {
  final String? boardId;
  const BoardDetailScreen({super.key, this.boardId});

  /// Helper to create a route from a route name like '/board/:id'
  static Route<dynamic> routeFromSettings(RouteSettings settings) {
    final name = settings.name ?? '';
    final id = name.split('/').isNotEmpty ? name.split('/').last : null;
    return MaterialPageRoute(
      builder: (_) => ProtectedRoute(child: BoardDetailScreen(boardId: id)),
      settings: settings,
    );
  }

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  StreamSubscription? _sub;
  final List<String> _messages = [];
  bool _connected = false;
  final _messageController = TextEditingController();

  String get _boardId =>
      widget.boardId ??
      ModalRoute.of(context)?.settings.name?.split('/').last ??
      '';

  @override
  void initState() {
    super.initState();
    // Connect when the screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_boardId.isEmpty) return;
      WebsocketService.connectToBoard(_boardId)
          .then((_) {
            setState(() => _connected = true);
            _sub = WebsocketService.stream?.listen(
              (event) {
                // server sends JSON-serialized payloads; keep raw string for demo
                setState(() {
                  _messages.add(event.toString());
                });
              },
              onError: (err) {
                debugPrint('WebSocket stream error: $err');
              },
              onDone: () {
                debugPrint('WebSocket stream closed');
                setState(() => _connected = false);
              },
            );
          })
          .catchError((err) {
            debugPrint('Failed to connect to board websocket: $err');
          });
    });
  }

  @override
  void dispose() {
    // Clean up: cancel subscription and close the socket
    _sub?.cancel();
    WebsocketService.close();
    super.dispose();
  }

  void _send(Map<String, dynamic> payload) {
    if (!_connected) return;
    WebsocketService.send(payload);
  }

  @override
  Widget build(BuildContext context) {
    final displayedId = _boardId.isNotEmpty ? _boardId : 'unknown';
    return Scaffold(
      appBar: AppBar(
        title: Text('Board Details'),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message to send',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _connected
                  ? () {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        _send({'type': 'message', 'content': message});
                        _messageController.clear();
                      }
                    }
                  : null,
              icon: const Icon(Icons.send),
              label: const Text('Send test message'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Incoming messages:'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (_, i) =>
                    ListTile(dense: true, title: Text(_messages[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
