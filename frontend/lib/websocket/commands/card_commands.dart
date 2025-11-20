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
