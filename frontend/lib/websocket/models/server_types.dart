class TrelloBoard {
  final String id;
  final String ownerId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrelloBoard({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrelloBoard.fromJson(Map<String, dynamic> json) {
    return TrelloBoard(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class TrelloColumn {
  final String id;
  final String boardId;
  final int index;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrelloColumn({
    required this.id,
    required this.boardId,
    required this.index,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrelloColumn.fromJson(Map<String, dynamic> json) {
    return TrelloColumn(
      id: json['id'] as String,
      boardId: json['boardId'] as String,
      index: json['index'] as int,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class TrelloCard {
  final String id;
  final String columnId;
  final String? tagId;
  final int index;
  final String title;
  final String content;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrelloCard({
    required this.id,
    required this.columnId,
    this.tagId,
    required this.index,
    required this.title,
    required this.content,
    this.startDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrelloCard.fromJson(Map<String, dynamic> json) {
    return TrelloCard(
      id: json['id'] as String,
      columnId: json['columnId'] as String,
      tagId: json['tagId'] as String?,
      index: json['index'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class TrelloTag {
  final String id;
  final String boardId;
  final String name;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrelloTag({
    required this.id,
    required this.boardId,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrelloTag.fromJson(Map<String, dynamic> json) {
    return TrelloTag(
      id: json['id'] as String,
      boardId: json['boardId'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class TrelloUser {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;

  TrelloUser({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrelloUser.fromJson(Map<String, dynamic> json) {
    return TrelloUser(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
