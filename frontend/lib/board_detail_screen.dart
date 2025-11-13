import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/protected_routes.dart';
import 'package:frontend/websocket/websocket.dart';

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
  bool _connected = false;
  late String _boardTitle;
  late List<TrelloColumn> _columns = [];
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    WebsocketService.close();
    super.dispose();
  }

  void _connectToBoard() async {
    if (_boardId.isEmpty) return;
    try {
      TrelloBoard? result = await WebsocketService.connectToBoard(_boardId);
      if (result == null) return; // already connected
      setState(() {
        _connected = true;
        _boardTitle = result.title;
      });
      _sub = WebsocketService.stream?.listen(
        (event) {
          // Handle incoming messages
          // TODO: make a handler function to process different message types
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

  @override
  Widget build(BuildContext context) {
    final displayedId = _boardId.isNotEmpty ? _boardId : 'unknown';
    final title = _connected ? _boardTitle : 'Board Details';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 6.0,
          radius: const Radius.circular(4),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _columnList(),
          ),
        ),
      ),
    );
  }

  Widget _columnList() {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          // Convert vertical scroll to horizontal scroll
          final offset = pointerSignal.scrollDelta.dy;
          _scrollController.jumpTo(
            (_scrollController.offset + offset).clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            ),
          );
        }
      },
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _columns.length + 1,
        itemBuilder: (context, index) {
          if (index == _columns.length) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
              ),
              onPressed: () {
                // TODO: Implement add column functionality
                _columns.add(
                  TrelloColumn(
                    id: 'new_column_${_columns.length}',
                    boardId: _boardId,
                    index: _columns.length,
                    title: 'New Column',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                setState(() {});
              },
              child: const Icon(Icons.add),
            );
          }
          final column = _columns[index];
          return _buildColumn(column);
        },
      ),
    );
  }

  /*
   * Build the column widget that will contain the cards
   */
  Widget _buildColumn(TrelloColumn column) {
    return SizedBox(
      width: 300, // Set the width of each column
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Column: ${column.title}'),
              // Add more widgets to display cards, etc.
            ],
          ),
        ),
      ),
    );
  }
}
