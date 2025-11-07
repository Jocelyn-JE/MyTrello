import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:frontend/protected_routes.dart';
import 'websocket_service.dart';

const List<String> list = ['message', 'column.list', 'column.create'];

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
  String dropdownValue = list.first;
  static final List<DropdownMenuEntry<String>> menuEntries =
      UnmodifiableListView<DropdownMenuEntry<String>>(
        list.map<DropdownMenuEntry<String>>(
          (String name) => DropdownMenuEntry<String>(value: name, label: name),
        ),
      );

  String get _boardId =>
      widget.boardId ??
      ModalRoute.of(context)?.settings.name?.split('/').last ??
      '';

  @override
  void initState() {
    super.initState();
    // Connect when the screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_boardId.isEmpty) return;
      _connectToBoard();
    });
  }

  @override
  void dispose() {
    // Clean up: cancel subscription and close the socket
    _sub?.cancel();
    WebsocketService.close();
    super.dispose();
  }

  void _connectToBoard() async {
    if (_boardId.isEmpty) return;
    try {
      await WebsocketService.connectToBoard(_boardId);
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
          WebsocketService.close();
          setState(() => _connected = false);
        },
      );
    } catch (e) {
      _disconnectFromBoard();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
      }
    }
  }

  void _disconnectFromBoard() {
    _sub?.cancel();
    WebsocketService.close();
    setState(() => _connected = false);
  }

  void _send(Map<String, dynamic> payload) {
    if (!_connected) return;
    try {
      WebsocketService.send(payload);
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedId = _boardId.isNotEmpty ? _boardId : 'unknown';
    return Scaffold(
      appBar: AppBar(
        title: Text('Board Details'),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
        actions: [
          IconButton(
            icon: Icon(
              _connected ? Icons.link : Icons.link_off,
              color: _connected ? Colors.black : Colors.red,
            ),
            onPressed: _connected ? _disconnectFromBoard : _connectToBoard,
          ),
          const SizedBox(width: 16),
        ],
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
            DropdownMenu<String>(
              initialSelection: dropdownValue,
              dropdownMenuEntries: menuEntries,
              onSelected: (String? value) {
                debugPrint('Selected action: $value');
                setState(() {
                  dropdownValue = value ?? dropdownValue;
                });
              },
            ),
            const SizedBox(height: 8),
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
                      _send({'type': dropdownValue, 'data': message});
                      _messageController.clear();
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
