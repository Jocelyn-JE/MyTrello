import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'auth_service.dart';

class WebsocketService {
  static WebSocketChannel? _channel;

  /// Whether a channel is currently open
  static bool get isConnected => _channel != null;

  /// Expose incoming message stream (null if not connected)
  static Stream<dynamic>? get stream => _channel?.stream;

  /// Connect to a board room on the backend and immediately send the token handshake.
  /// host can be overridden for testing (default should be replaced with your real host).
  static Future<void> connectToBoard(
    String boardId, {
    String host = 'localhost:3000',
  }) async {
    if (isConnected) return;

    if (!AuthService.isLoggedIn || AuthService.token == null) {
      throw Exception('User is not authenticated');
    }

    final token = AuthService.token!;
    final uri = Uri.parse('ws://$host/ws/boards/$boardId');

    _channel = WebSocketChannel.connect(uri);

    // Send initial handshake expected by server: { token: "<token>" }
    _channel!.sink.add(jsonEncode({'token': token}));
  }

  /// Send a JSON-serializable payload to the server.
  static void send(dynamic payload) {
    if (!isConnected) throw Exception('WebSocket is not connected');
    try {
      _channel!.sink.add(jsonEncode(payload));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Close the connection (optional code and reason).
  static Future<void> close([int? code, String? reason]) async {
    if (!isConnected) return;
    await _channel!.sink.close(code, reason);
    _channel = null;
  }

  /// Test helper to reset internal state.
  static void resetForTesting() {
    _channel = null;
  }
}
