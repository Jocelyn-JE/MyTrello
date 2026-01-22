import 'package:frontend/websocket/commands/websocket_command.dart';

/// Send a message in the board chat
class SendChatMessageCommand implements WebSocketCommand {
  @override
  final String type = 'chat.send';

  final String message;

  SendChatMessageCommand({required this.message});

  @override
  Map<String, dynamic> toJson() => {'type': type, 'data': message};
}

/// List chat messages in the board
class ListChatMessagesCommand implements WebSocketCommand {
  @override
  final String type = 'chat.history';

  ListChatMessagesCommand();

  @override
  Map<String, dynamic> toJson() => {'type': type, 'data': null};
}
