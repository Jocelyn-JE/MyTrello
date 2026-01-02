import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth_service.dart';
import 'package:frontend/board_permissions_service.dart';
import 'package:frontend/board_service.dart';
import 'package:frontend/board_settings_screen.dart';
import 'package:frontend/config.dart';
import 'package:frontend/models/board.dart';
import 'package:frontend/protected_routes.dart';
import 'package:frontend/websocket/websocket.dart';
import 'package:frontend/widgets/trello_column_widget.dart';

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
    BoardPermissionsService.clearCurrentBoard();
    super.dispose();
  }

  void _connectToBoard() async {
    debugPrint('Connecting to board $_boardId');
    if (_boardId.isEmpty) return;
    try {
      TrelloBoard? result = await WebsocketService.connectToBoard(
        _boardId,
        host: AppConfig.backendHost,
      );
      if (result == null) return; // already connected
      debugPrint('Connected to board: ${result.title}');

      // Fetch full board info to get members and viewers
      try {
        Board fullBoard = await BoardService.getBoard(_boardId);
        BoardPermissionsService.setCurrentBoard(fullBoard);
      } catch (e) {
        debugPrint('Error fetching full board info: $e');
      }

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
            final sender = MinimalUser.fromJson(data['sender']);
            handleIncomingAction(type, payload, sender);
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
    BoardPermissionsService.clearCurrentBoard();
  }

  Future<void> _openBoardSettings() async {
    Board? boardInfo = await BoardService.getBoard(_boardId);
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoardSettingsScreen(board: boardInfo),
      ),
    );

    // If board was deleted or modified, navigate back to home
    if (result == 'deleted') {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } else if (result == true) {
      // Board was updated, reconnect to get fresh data
      _disconnectFromBoard();
      _connectToBoard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _boardTitle ?? 'Board Details';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
        actions: [
          if (BoardPermissionsService.canEdit)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openBoardSettings,
              tooltip: 'Board Settings',
            ),
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
        itemCount: _columns.length + (BoardPermissionsService.canEdit ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _columns.length && BoardPermissionsService.canEdit) {
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
          return TrelloColumnWidget(
            column: column,
            onAddCard: () => _showAddCardDialog(column.id),
          );
        },
      ),
    );
  }

  /*
   * Show dialog to add a new card
   */
  void _showAddCardDialog(String columnId) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isNotEmpty && content.isNotEmpty) {
                WebsocketService.createCard(
                  columnId: columnId,
                  title: title,
                  content: content,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  late final actionMap = {
    'column.list': (dynamic payload, MinimalUser sender) {
      if (sender.id != AuthService.userId) return;
      List<TrelloColumn> columns = (payload as List)
          .map((col) => TrelloColumn.fromJson(col))
          .toList();
      setState(() {
        _columns = columns;
      });
      // Fetch cards for each column
      for (var column in columns) {
        WebsocketService.fetchCards(column.id);
      }
    },
    'column.rename': (dynamic payload, MinimalUser sender) {
      TrelloColumn renamedColumn = TrelloColumn.fromJson(payload);
      int index = _columns.indexWhere((col) => col.id == renamedColumn.id);
      if (index != -1) {
        setState(() {
          _columns[index] = _columns[index].update(title: renamedColumn.title);
        });
      }
    },
    'column.delete': (dynamic payload, MinimalUser sender) {
      TrelloColumn deletedColumn = TrelloColumn.fromJson(payload);
      setState(() {
        _columns.removeWhere((col) => col.id == deletedColumn.id);
      });
    },
    'column.create': (dynamic payload, MinimalUser sender) {
      TrelloColumn newColumn = TrelloColumn.fromJson(payload);
      setState(() {
        _columns.add(newColumn);
      });
    },
    'card.list': (dynamic payload, MinimalUser sender) {
      if (sender.id != AuthService.userId) return;
      List<TrelloCard> cards = (payload as List)
          .map((card) => TrelloCard.fromJson(card))
          .toList();

      // Get columnId from the first card
      final columnId = cards.first.columnId;
      setState(() {
        final index = _columns.indexWhere((col) => col.id == columnId);
        if (index != -1) {
          _columns[index] = _columns[index].update(cards: cards);
        }
      });
      for (var card in cards) {
        WebsocketService.fetchAssignees(card.id);
      }
    },
    'card.create': (dynamic payload, MinimalUser sender) {
      TrelloCard newCard = TrelloCard.fromJson(payload);
      setState(() {
        final index = _columns.indexWhere((col) => col.id == newCard.columnId);
        if (index != -1) {
          final updatedCards = [..._columns[index].cards, newCard]
            ..sort((a, b) => a.index.compareTo(b.index));
          _columns[index] = _columns[index].update(cards: updatedCards);
        }
      });
    },
    'card.update': (dynamic payload, MinimalUser sender) {
      TrelloCard updatedCard = TrelloCard.fromJson(payload);
      setState(() {
        // First, remove the card from its old column (wherever it is)
        for (int i = 0; i < _columns.length; i++) {
          final hasCard = _columns[i].cards.any((c) => c.id == updatedCard.id);
          if (hasCard) {
            final updatedCards = _columns[i].cards
                .where((card) => card.id != updatedCard.id)
                .toList();
            _columns[i] = _columns[i].update(cards: updatedCards);
            break;
          }
        }

        // Then, add it to the new column
        final newColumnIndex = _columns.indexWhere(
          (col) => col.id == updatedCard.columnId,
        );
        if (newColumnIndex != -1) {
          final updatedCards = [..._columns[newColumnIndex].cards, updatedCard]
            ..sort((a, b) => a.index.compareTo(b.index));
          _columns[newColumnIndex] = _columns[newColumnIndex].update(
            cards: updatedCards,
          );
        }
      });
    },
    'card.delete': (dynamic payload, MinimalUser sender) {
      TrelloCard deletedCard = TrelloCard.fromJson(payload);
      setState(() {
        final index = _columns.indexWhere(
          (col) => col.id == deletedCard.columnId,
        );
        if (index != -1) {
          final updatedCards = _columns[index].cards
              .where((card) => card.id != deletedCard.id)
              .toList();
          _columns[index] = _columns[index].update(cards: updatedCards);
        }
      });
    },
    'assignee.list': (dynamic payload, MinimalUser sender) {
      if (sender.id != AuthService.userId) return;
      List<TrelloUser> assignees = (payload['assignees'] as List)
          .map((user) => TrelloUser.fromJson(user))
          .toList();
      String cardId = payload['cardId'];
      // Update the relevant card with its assignees
      setState(() {
        for (int i = 0; i < _columns.length; i++) {
          final cardIndex = _columns[i].cards.indexWhere(
            (card) => card.id == cardId,
          );
          if (cardIndex != -1) {
            final updatedCard = _columns[i].cards[cardIndex].update(
              assignedUsers: assignees,
            );
            final updatedCards = [..._columns[i].cards];
            updatedCards[cardIndex] = updatedCard;
            _columns[i] = _columns[i].update(cards: updatedCards);
            break;
          }
        }
      });
    },
  };

  void handleIncomingAction(String type, dynamic payload, MinimalUser sender) {
    final action = actionMap[type];
    if (action != null) {
      action(payload, sender);
    } else {
      debugPrint('Unknown action type: $type');
    }
  }
}
