import 'dart:async';
import 'dart:convert';
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
  String? _boardTitle;
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
    debugPrint('Connecting to board $_boardId');
    if (_boardId.isEmpty) return;
    try {
      TrelloBoard? result = await WebsocketService.connectToBoard(_boardId);
      if (result == null) return; // already connected
      debugPrint('Connected to board: ${result.title}');
      setState(() {
        _boardTitle = result.title;
      });
      _sub = WebsocketService.stream?.listen(
        (event) {
          // Handle incoming actions
          try {
            final data = jsonDecode(event);
            final type = data['type'];
            final payload = data['data'];
            handleIncomingAction(type, payload);
            debugPrint('Received WebSocket message: $data');
          } catch (e) {
            debugPrint('Error processing WebSocket message: $e');
          }
        },
        onError: (err) {
          debugPrint('WebSocket stream error: $err');
        },
        onDone: () {
          debugPrint('WebSocket stream closed');
          WebsocketService.close();
        },
      );
      WebsocketService.fetchColumns();
    } catch (e) {
      debugPrint('Error connecting to board: $e');
      _disconnectFromBoard();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false, // Remove all previous routes
        );
      }
    }
  }

  void _disconnectFromBoard() {
    debugPrint('Disconnecting from board');
    _sub?.cancel();
    WebsocketService.close();
  }

  @override
  Widget build(BuildContext context) {
    final title = _boardTitle ?? 'Board Details';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
        actions: [],
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
                WebsocketService.createColumn('New Column');
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
    final TextEditingController titleController = TextEditingController(
      text: column.title,
    );
    return SizedBox(
      width: 300, // Set the width of each column
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Column title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                onSubmitted: (newTitle) {
                  if (newTitle.isNotEmpty && newTitle != column.title) {
                    WebsocketService.renameColumn(column.id, newTitle);
                  }
                },
                onEditingComplete: () {
                  final newTitle = titleController.text;
                  if (newTitle.isNotEmpty && newTitle != column.title) {
                    WebsocketService.renameColumn(column.id, newTitle);
                  }
                  FocusScope.of(context).unfocus();
                },
              ),
              // Add more widgets to display cards, etc.
              const Spacer(),
              IconButton(
                color: Colors.red,
                icon: const Icon(Icons.delete),
                tooltip: 'Delete column',
                onPressed: () {
                  WebsocketService.deleteColumn(column.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  late final actionMap = {
    'column.list': (dynamic payload) {
      List<TrelloColumn> columns = (payload as List)
          .map((col) => TrelloColumn.fromJson(col))
          .toList();
      setState(() {
        _columns = columns;
      });
    },
    'column.rename': (dynamic payload) {
      TrelloColumn renamedColumn = TrelloColumn.fromJson(payload);
      int index = _columns.indexWhere((col) => col.id == renamedColumn.id);
      if (index != -1) {
        setState(() {
          _columns[index] = renamedColumn;
        });
      }
    },
    'column.delete': (dynamic payload) {
      TrelloColumn deletedColumn = TrelloColumn.fromJson(payload);
      setState(() {
        _columns.removeWhere((col) => col.id == deletedColumn.id);
      });
    },
    'column.create': (dynamic payload) {
      TrelloColumn newColumn = TrelloColumn.fromJson(payload);
      setState(() {
        _columns.add(newColumn);
      });
    },
  };

  void handleIncomingAction(String type, dynamic payload) {
    final action = actionMap[type];
    if (action != null) {
      action(payload);
    } else {
      debugPrint('Unknown action type: $type');
    }
  }
}
