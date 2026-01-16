import 'package:frontend/websocket/models/server_types.dart';

class ConnectionAckMessage {
  final String type;
  final TrelloBoard board;

  ConnectionAckMessage({required this.type, required this.board});

  factory ConnectionAckMessage.fromJson(Map<String, dynamic> json) {
    return ConnectionAckMessage(
      type: json['type'] as String,
      board: TrelloBoard.fromJson(json['board']),
    );
  }
}

/// Error message sent by server
class ErrorMessage {
  final String type; // "error"
  final String message;

  ErrorMessage({required this.type, required this.message});

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      type: json['type'] as String,
      message: json['message'] as String,
    );
  }
}

/// Broadcast message from server (forwarded from another client)
class BroadcastMessage {
  final String type; // event type (e.g., "card.create", "card.update")
  final Map<String, dynamic> data;
  final SenderInfo sender;

  BroadcastMessage({
    required this.type,
    required this.data,
    required this.sender,
  });

  factory BroadcastMessage.fromJson(Map<String, dynamic> json) {
    return BroadcastMessage(
      type: json['type'] as String,
      data: json['data'],
      sender: SenderInfo.fromJson(json['sender']),
    );
  }
}

/// Sender information included in broadcast messages
class SenderInfo {
  final String username;
  final String email;

  SenderInfo({required this.username, required this.email});

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}
