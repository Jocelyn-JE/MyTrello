import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:frontend/websocket/websocket.dart';
import 'package:frontend/services/auth_service.dart';

class WebsocketService {
  static WebSocketChannel? _channel;
  // Cached broadcast wrapper around the channel's stream so multiple listeners are allowed.
  static Stream<dynamic>? _broadcastStream;

  /// Whether a channel is currently open
  static bool get isConnected => _channel != null;

  /// Expose incoming message stream (null if not connected)
  static Stream<dynamic>? get stream => _broadcastStream;

  /// Connect to a board room on the backend and immediately send the token handshake.
  /// host can be overridden (default should be replaced with the real host).
  static Future<TrelloBoard?> connectToBoard(
    String boardId, {
    String host = 'localhost:3000',
  }) async {
    if (isConnected) return null;

    if (!AuthService.isLoggedIn) throw Exception('User is not authenticated');

    final token = AuthService.token!;
    final uri = Uri.parse('ws://$host/ws/boards/$boardId');

    _channel = WebSocketChannel.connect(uri);

    // Create and cache a broadcast stream wrapper so multiple listeners can subscribe.
    _broadcastStream = _channel!.stream.asBroadcastStream();

    // Send initial handshake expected by server: { token: "<token>" }
    _channel!.sink.add(jsonEncode({'token': token}));

    // Wait for server to confirm connection or close it
    final completer = Completer<TrelloBoard?>();
    late StreamSubscription sub;
    sub = _broadcastStream!.listen(
      (event) {
        final data = jsonDecode(event);
        if (data['type'] == 'connection_ack') {
          final board = TrelloBoard.fromJson(data['board']);
          completer.complete(board);
          sub.cancel();
        } else if (data['type'] == 'error') {
          completer.completeError(data['message'] ?? 'Connection error');
          sub.cancel();
        }
      },
      onError: (err) {
        if (!completer.isCompleted) completer.completeError(err);
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError('Connection closed by server');
        }
      },
    );
    final result = await completer.future;
    if (result == null) throw Exception('Failed to connect to board');
    return result;
  }

  /// Send a WebSocket command to the server.
  static void _sendCommand(WebSocketCommand command) {
    _send(command.toJson());
  }

  /// Send a JSON-serializable payload to the server.
  static void _send(Map<String, dynamic> payload) {
    if (AuthService.isLoggedIn == false) {
      close();
      throw Exception('User is not authenticated');
    }
    if (!isConnected) throw Exception('WebSocket is not connected');
    _channel!.sink.add(jsonEncode(payload));
  }

  /// Close the connection (optional code and reason).
  static Future<void> close([int? code, String? reason]) async {
    if (!isConnected) return;
    await _channel!.sink.close(code, reason);
    _channel = null;
    _broadcastStream = null;
  }

  /// Test helper to reset internal state.
  static void resetForTesting() {
    _channel = null;
    _broadcastStream = null;
  }

  /// Ask the server to fetch the list of columns for the current board
  static void fetchColumns() {
    _sendCommand(ListColumnsCommand());
  }

  /// Ask the server to fetch the list of cards for a specific column
  static void fetchCards(String columnId) {
    _sendCommand(ListCardsCommand(columnId: columnId));
  }

  /// Ask the server to create a new column with the given title
  static void createColumn(String title) {
    _sendCommand(CreateColumnCommand(title: title));
  }

  /// Ask the server to create a new card
  static void createCard({
    required String columnId,
    required String title,
    required String content,
    String? tagId,
    DateTime? startDate,
    DateTime? dueDate,
  }) {
    _sendCommand(
      CreateCardCommand(
        columnId: columnId,
        title: title,
        content: content,
        tagId: tagId,
        startDate: startDate,
        dueDate: dueDate,
      ),
    );
  }

  /// Ask the server to update a card
  static void updateCard({
    required String cardId,
    String? columnId,
    String? title,
    String? content,
    String? tagId,
    String? newPos,
    DateTime? startDate,
    DateTime? dueDate,
    List<String>? assignees,
  }) {
    _sendCommand(
      UpdateCardCommand(
        id: cardId,
        columnId: columnId,
        title: title,
        content: content,
        tagId: tagId,
        newPos: newPos,
        startDate: startDate,
        dueDate: dueDate,
        assignees: assignees,
      ),
    );
  }

  /// Ask the server to delete a card by its ID
  static void deleteCard(String cardId) {
    _sendCommand(DeleteCardCommand(id: cardId));
  }

  /// Ask the server to rename a column
  static void renameColumn(String columnId, String newTitle) {
    _sendCommand(RenameColumnCommand(columnId: columnId, newTitle: newTitle));
  }

  /// Ask the server to delete a column
  static void deleteColumn(String columnId) {
    _sendCommand(DeleteColumnCommand(columnId: columnId));
  }

  /// Ask the server to move a column to a new position
  static void moveColumn(String columnId, String? newPos) {
    _sendCommand(MoveColumnCommand(columnId: columnId, newPos: newPos));
  }

  /// Ask the server for the list of assignees for a specific card
  static void fetchAssignees(String cardId) {
    _sendCommand(ListAssigneesCommand(cardId: cardId));
  }

  /// Ask the server to assign a user to a card
  static void assignUserToCard(String cardId, String userId) {
    _sendCommand(AssignCommand(cardId: cardId, userId: userId));
  }

  /// Ask the server to unassign a user from a card
  static void unassignUserFromCard(String cardId, String userId) {
    _sendCommand(UnassignCommand(cardId: cardId, userId: userId));
  }

  /// Ask the server to send a message in the board chat
  static void sendChatMessage(String message) {
    _sendCommand(SendChatMessageCommand(message: message));
  }

  /// Ask the server to list chat messages in the board
  static void listChatMessages() {
    _sendCommand(ListChatMessagesCommand());
  }
}
