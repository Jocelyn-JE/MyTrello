import 'websocket_command.dart';

/// Create a new column in the board
class CreateColumnCommand implements WebSocketCommand {
  @override
  final String type = 'column.create';

  final String title;

  CreateColumnCommand({required this.title});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {'title': title},
  };
}

/// List all columns in the board
class ListColumnsCommand implements WebSocketCommand {
  @override
  final String type = 'column.list';

  ListColumnsCommand();

  @override
  Map<String, dynamic> toJson() => {'type': type, 'data': null};
}
