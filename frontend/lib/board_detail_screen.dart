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
      setState(() {
        _getColumnById(renamedColumn.id).update(title: renamedColumn.title);
      });
    },
    'column.delete': (dynamic payload, MinimalUser sender) {
      TrelloColumn deletedColumn = TrelloColumn.fromJson(payload);
      setState(() {
        _removeColumnById(deletedColumn.id);
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
        _getColumnById(columnId).cards = cards;
      });

      for (var card in cards) {
        WebsocketService.fetchAssignees(card.id);
      }
    },
    'card.create': (dynamic payload, MinimalUser sender) {
      TrelloCard newCard = TrelloCard.fromJson(payload);
      setState(() {
        _getColumnById(newCard.columnId).addCard(newCard);
      });
    },
    'card.update': (dynamic payload, MinimalUser sender) {
      TrelloCard updatedCard = TrelloCard.fromJson(payload);
      setState(() {
        updatedCard.update(
          assignedUsers: _getCardById(updatedCard.id).assignedUsers,
        );
        setState(() {
          _removeCardById(updatedCard.id);
          _getColumnById(updatedCard.columnId).addCard(updatedCard);
        });
      });
    },
    'card.delete': (dynamic payload, MinimalUser sender) {
      TrelloCard deletedCard = TrelloCard.fromJson(payload);
      setState(() {
        _removeCardById(deletedCard.id);
      });
    },
    'assignee.list': (dynamic payload, MinimalUser sender) {
      if (sender.id != AuthService.userId) return;
      List<TrelloUser> assignees = (payload['assignees'] as List)
          .map((user) => TrelloUser.fromJson(user))
          .toList();
      String cardId = payload['cardId'];
      setState(() {
        _getCardById(cardId).update(assignedUsers: assignees);
      });
    },
    'assignee.assign': (dynamic payload, MinimalUser sender) {
      String cardId = payload['cardId'];
      TrelloUser newAssignee = TrelloUser.fromJson(payload['user']);
      setState(() {
        _getCardById(cardId).addAssignee(newAssignee);
      });
    },
    'assignee.unassign': (dynamic payload, MinimalUser sender) {
      String cardId = payload['cardId'];
      String userId = payload['userId'];
      setState(() {
        _getCardById(cardId).removeAssignee(userId);
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

  /// Find the index of the column containing the card with the given ID
  int _findColumnIndexByCardId(String cardId) {
    for (var i = 0; i < _columns.length; i++) {
      if (_columns[i].cards.any((card) => card.id == cardId)) {
        return i;
      }
    }
    return -1; // Not found
  }

  /// Check if a card is already in a specific column
  bool _cardInColumn(String cardId, String columnId) {
    final columnIndex = _findColumnIndexByCardId(cardId);
    if (columnIndex == -1) return false;
    return _columns[columnIndex].id == columnId;
  }

  /// Retrieves a card by its ID
  TrelloCard _getCardById(String cardId) {
    for (var column in _columns) {
      for (var card in column.cards) {
        if (card.id == cardId) {
          return card;
        }
      }
    }
    throw Exception('Card with ID $cardId not found');
  }

  /// Retrieves a column by its ID
  TrelloColumn _getColumnById(String columnId) {
    for (var column in _columns) {
      if (column.id == columnId) {
        return column;
      }
    }
    throw Exception('Column with ID $columnId not found');
  }

  /// Remove a column by its ID
  void _removeColumnById(String columnId) {
    setState(() {
      _columns.removeWhere((col) => col.id == columnId);
    });
  }

  /// Remove a card by its ID
  void _removeCardById(String cardId) {
    final columnIndex = _findColumnIndexByCardId(cardId);
    if (columnIndex != -1) {
      setState(() {
        _columns[columnIndex].removeCard(cardId);
      });
      return;
    }
    throw Exception('Card with ID $cardId not found');
  }
}
