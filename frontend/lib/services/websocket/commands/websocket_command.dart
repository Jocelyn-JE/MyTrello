/// Base class for all WebSocket commands sent to the server
abstract class WebSocketCommand {
  /// The event type identifier (e.g., "column.create", "message")
  String get type;

  /// Convert the command to a JSON payload for transmission
  Map<String, dynamic> toJson();
}
