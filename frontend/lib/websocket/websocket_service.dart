import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'websocket.dart';
import '../auth_service.dart';

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
    );
    // Wait for either the connection acknowledgment or an error
    return await completer.future;
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
}
