import 'package:frontend/services/websocket/commands/websocket_command.dart';

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

/// Rename a column in the board
class RenameColumnCommand implements WebSocketCommand {
  @override
  final String type = 'column.rename';
  final String columnId;
  final String newTitle;

  RenameColumnCommand({required this.columnId, required this.newTitle});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {'id': columnId, 'title': newTitle},
  };
}

/// Delete a column in the board
class DeleteColumnCommand implements WebSocketCommand {
  @override
  final String type = 'column.delete';
  final String columnId;

  DeleteColumnCommand({required this.columnId});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {'id': columnId},
  };
}

/// Move a column to a new position in the board
class MoveColumnCommand implements WebSocketCommand {
  @override
  final String type = 'column.move';
  final String columnId;
  final String? newPos; // null means move to the end

  MoveColumnCommand({required this.columnId, required this.newPos});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {'id': columnId, 'newPos': newPos},
  };
}
