import 'package:frontend/websocket/commands/websocket_command.dart';

/// List all assignees for a card
class ListAssigneesCommand implements WebSocketCommand {
  @override
  final String type = 'assignee.list';
  final String cardId;

  ListAssigneesCommand({required this.cardId});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'cardId': cardId},
    };
  }
}

/// Assign a user to a card
class AssignCommand implements WebSocketCommand {
  @override
  final String type = 'assignee.assign';
  final String cardId;
  final String userId;

  AssignCommand({required this.cardId, required this.userId});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'cardId': cardId, 'userId': userId},
    };
  }
}

/// Unassign a user from a card
class UnassignCommand implements WebSocketCommand {
  @override
  final String type = 'assignee.unassign';
  final String cardId;
  final String userId;

  UnassignCommand({required this.cardId, required this.userId});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': {'cardId': cardId, 'userId': userId},
    };
  }
}
