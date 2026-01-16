import 'package:frontend/websocket/commands/websocket_command.dart';

/// Send a message in the board
class SendMessageCommand implements WebSocketCommand {
  @override
  final String type = 'message';

  final String message;

  SendMessageCommand({required this.message});

  @override
  Map<String, dynamic> toJson() => {'type': type, 'data': message};
}
