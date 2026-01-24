import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/websocket/server_types.dart';
import 'package:frontend/screens/board_detail/widgets/board_chat_drawer.dart';
import 'package:frontend/screens/board_detail/widgets/board_column_list.dart';
import 'package:frontend/services/api/auth_service.dart';
import 'package:frontend/services/board_permissions_service.dart';
import 'package:frontend/services/api/board_service.dart';
import 'package:frontend/screens/board_settings_screen.dart';
import 'package:frontend/services/websocket/websocket_service.dart';
import 'package:frontend/utils/app_config.dart';
import 'package:frontend/models/api/board.dart';
import 'package:frontend/utils/print_to_console.dart';
import 'package:frontend/utils/protected_routes.dart';
import 'package:frontend/utils/snackbar.dart';

class BoardDetailScreen extends StatefulWidget {
  final String boardId;
  const BoardDetailScreen({super.key, required this.boardId});

  /// Helper to create a route from a route name like '/board/:id'
  static Route<dynamic> routeFromSettings(
    RouteSettings settings,
    String boardId,
  ) {
    return MaterialPageRoute(
      builder: (_) =>
          ProtectedRoute(child: BoardDetailScreen(boardId: boardId)),
      settings: settings,
    );
  }

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  StreamSubscription? _sub; // Subscription to WebSocket stream
  String? _boardTitle;
  late List<TrelloColumn> _columns = [];
  late List<TrelloChatMessage> _chatMessages =
      []; // Messages stored from most recent to oldest
  bool _newMessage = false;
  bool _isChatDrawerOpen = false;
  final ScrollController _scrollController =
      ScrollController(); // For horizontal scrolling
  String _searchQuery = '';

  String get _boardId => widget.boardId; // Shortcut to access boardId

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

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false, // Remove all previous routes
    );
  }

  void _connectToBoard() async {
    printToConsole('Connecting to board $_boardId');
    if (_boardId.isEmpty) return;
    try {
      TrelloBoard? result = await WebsocketService.connectToBoard(
        _boardId,
        host: AppConfig.backendHost,
      );
      if (result == null) return; // already connected
      printToConsole('Connected to board: ${result.title}');

      // Fetch full board info to get members and viewers
      try {
        Board fullBoard = await BoardService.getBoard(_boardId);
        BoardPermissionsService.setCurrentBoard(fullBoard);
      } catch (e) {
        printToConsole('Error fetching full board info: $e');
      }

      setState(() {
        _boardTitle = result.title;
      });
      _sub = WebsocketService.stream?.listen(
        (event) {
          // Handle incoming actions
          try {
            final data = jsonDecode(event);
            final sender = MinimalUser.fromJson(data['sender']);
            handleIncomingAction(data['type'], data['data'], sender);
            printToConsole('Received WebSocket message: $data');
          } catch (e) {
            printToConsole('Error processing WebSocket message: $e');
          }
        },
        onError: (err) {
          printToConsole('WebSocket stream error: $err');
        },
        onDone: () {
          printToConsole('WebSocket stream closed');
          WebsocketService.close();
          BoardPermissionsService.clearCurrentBoard();
          if (mounted) {
            _goHome();
          }
        },
      );
      // Initial data fetches
      WebsocketService.fetchColumns();
      WebsocketService.fetchChatMessages();
    } catch (e) {
      printToConsole('Error connecting to board: $e');
      _disconnectFromBoard();
      if (mounted) {
        _goHome();
      }
    }
  }

  void _disconnectFromBoard() {
    printToConsole('Disconnecting from board');
    _sub?.cancel();
    WebsocketService.close();
    BoardPermissionsService.clearCurrentBoard();
  }

  Future<void> _openBoardSettings() async {
    Board boardInfo;
    try {
      boardInfo = await BoardService.getBoard(_boardId);
    } catch (e) {
      if (mounted) {
        showSnackBarError(
          context,
          'Failed to load board settings: ${e.toString()}',
        );
        _disconnectFromBoard();
        _goHome();
      }
      return;
    }
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoardSettingsScreen(board: boardInfo),
      ),
    );

    // If board was deleted, navigate back to home
    if (result == 'deleted') {
      if (mounted) {
        _goHome();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _boardTitle ?? 'Loading...';
    return Scaffold(
      onEndDrawerChanged: (isOpened) {
        setState(() {
          _isChatDrawerOpen = isOpened;
          if (isOpened) {
            _newMessage = false;
          }
        });
      },
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.lightGreen,
        shadowColor: Colors.grey,
        actions: [
          if (BoardPermissionsService.canEdit) ...[
            // Chat button
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                    setState(() {
                      _newMessage = false;
                      _isChatDrawerOpen = true;
                    });
                  },
                  icon: Icon(
                    _newMessage ? Icons.mark_unread_chat_alt : Icons.chat,
                  ),
                );
              },
            ),
            // Settings button
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openBoardSettings,
              tooltip: 'Board Settings',
            ),
          ],
        ],
        automaticallyImplyLeading: false,
        // Home button
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            _disconnectFromBoard();
            _goHome();
          },
          tooltip: 'Home',
        ),
      ),
      // Chat drawer
      endDrawer: BoardChatDrawer(chatMessages: _chatMessages),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search cards...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            // Column list
            Expanded(
              child: BoardColumnList(
                columns: _columns,
                searchQuery: _searchQuery,
                boardId: _boardId,
              ),
            ),
          ],
        ),
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
    'column.move': (dynamic payload, MinimalUser sender) {
      TrelloColumn movedColumn = TrelloColumn.fromJson(payload);
      setState(() {
        // Find and preserve the existing column with its cards
        final oldIndex = _columns.indexWhere((col) => col.id == movedColumn.id);
        if (oldIndex != -1) {
          final existingColumn = _columns.removeAt(oldIndex);
          // Update the index on the existing column (preserves cards)
          existingColumn.update(index: movedColumn.index);
          // Insert at new position based on index
          final newIndex = movedColumn.index.clamp(0, _columns.length);
          _columns.insert(newIndex, existingColumn);
        }
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
    'chat.history': (dynamic payload, MinimalUser sender) {
      if (sender.id != AuthService.userId) return;
      List<TrelloChatMessage> messages = (payload as List)
          .map((msg) => TrelloChatMessage.fromJson(msg))
          .toList();
      setState(() {
        _chatMessages = messages.reversed.toList();
      });
    },
    'chat.send': (dynamic payload, MinimalUser sender) {
      TrelloChatMessage newMessage = TrelloChatMessage.fromJson(payload);
      setState(() {
        _chatMessages.insert(0, newMessage);
        if (!_isChatDrawerOpen) {
          _newMessage = true;
        }
      });
    },
  };

  void handleIncomingAction(String type, dynamic payload, MinimalUser sender) {
    final action = actionMap[type];
    if (action != null) {
      action(payload, sender);
    } else {
      printToConsole('Unknown action type: $type');
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
