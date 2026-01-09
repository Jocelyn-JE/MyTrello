import 'websocket_command.dart';

/// List all cards in a column
class ListCardsCommand implements WebSocketCommand {
  @override
  final String type = 'card.list';

  final String columnId;

  ListCardsCommand({required this.columnId});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {'columnId': columnId},
  };
}

/// Create a new card in a column
class CreateCardCommand implements WebSocketCommand {
  @override
  final String type = 'card.create';

  final String columnId;
  final String title;
  final String? content;
  final String? tagId;
  final DateTime? startDate;
  final DateTime? dueDate;

  CreateCardCommand({
    required this.columnId,
    required this.title,
    required this.content,
    this.tagId,
    this.startDate,
    this.dueDate,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {
      'columnId': columnId,
      'title': title,
      'content': content,
      if (tagId != null) 'tagId': tagId,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    },
  };
}

/// Delete a card by its ID
class DeleteCardCommand implements WebSocketCommand {
  @override
  final String type = 'card.delete';

  final String id;

  DeleteCardCommand({required this.id});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {'id': id},
  };
}

/// Update a card by its ID
class UpdateCardCommand implements WebSocketCommand {
  @override
  final String type = 'card.update';
  final String id;
  final String? columnId;
  final String? title;
  final String? content;
  final String? tagId;
  final String? newPos;
  final DateTime? startDate;
  final DateTime? dueDate;
  final List<String>? assignees;

  UpdateCardCommand({
    required this.id,
    this.columnId,
    this.title,
    this.content,
    this.tagId,
    this.newPos,
    this.startDate,
    this.dueDate,
    this.assignees,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'data': {
      'id': id,
      if (columnId != null) 'columnId': columnId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (tagId != null) 'tagId': tagId,
      if (newPos != null) 'newPos': newPos,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (assignees != null) 'assignees': assignees,
    },
  };
}
