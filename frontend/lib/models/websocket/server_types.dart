class TrelloBoard {
  String id;
  String ownerId;
  String title;
  DateTime createdAt;
  DateTime updatedAt;

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
  String id;
  String boardId;
  int index;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  List<TrelloCard> cards;

  TrelloColumn({
    required this.id,
    required this.boardId,
    required this.index,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.cards = const [],
  });

  factory TrelloColumn.fromJson(Map<String, dynamic> json) {
    return TrelloColumn(
      id: json['id'] as String,
      boardId: json['boardId'] as String,
      index: json['index'] as int,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cards: [],
    );
  }

  /// Updates the properties of this column
  void update({
    String? id,
    String? boardId,
    int? index,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TrelloCard>? cards,
  }) {
    this.id = id ?? this.id;
    this.boardId = boardId ?? this.boardId;
    this.index = index ?? this.index;
    this.title = title ?? this.title;
    this.createdAt = createdAt ?? this.createdAt;
    this.updatedAt = updatedAt ?? this.updatedAt;
    this.cards = cards ?? this.cards;
  }

  /// Removes a card by its ID
  void removeCard(String cardId) {
    cards.removeWhere((card) => card.id == cardId);
  }

  /// Adds a card to this column
  void addCard(TrelloCard card) {
    cards.insert(card.index, card);
  }

  /// Replaces an existing card with updated data
  void updateCard(TrelloCard updatedCard) {
    cards[updatedCard.index] = updatedCard;
  }
}

class TrelloCard {
  String id;
  String columnId;
  String? tagId;
  int index;
  String title;
  String content;
  DateTime? startDate;
  DateTime? dueDate;
  DateTime createdAt;
  DateTime updatedAt;
  List<TrelloUser> assignedUsers = [];

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

  void update({
    String? id,
    String? columnId,
    String? tagId,
    int? index,
    String? title,
    String? content,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TrelloUser>? assignedUsers,
  }) {
    this.id = id ?? this.id;
    this.columnId = columnId ?? this.columnId;
    this.tagId = tagId ?? this.tagId;
    this.index = index ?? this.index;
    this.title = title ?? this.title;
    this.content = content ?? this.content;
    this.startDate = startDate ?? this.startDate;
    this.dueDate = dueDate ?? this.dueDate;
    this.createdAt = createdAt ?? this.createdAt;
    this.updatedAt = updatedAt ?? this.updatedAt;
    this.assignedUsers = assignedUsers ?? this.assignedUsers;
  }

  void addAssignee(TrelloUser user) {
    assignedUsers.add(user);
  }

  void removeAssignee(String userId) {
    assignedUsers.removeWhere((user) => user.id == userId);
  }
}

class TrelloTag {
  String id;
  String boardId;
  String name;
  String color;
  DateTime createdAt;
  DateTime updatedAt;

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
  String id;
  String email;
  String username;
  DateTime createdAt;
  DateTime updatedAt;

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

class MinimalUser {
  final String id;
  final String username;
  final String email;

  MinimalUser({required this.id, required this.username, required this.email});

  factory MinimalUser.fromJson(Map<String, dynamic> json) {
    return MinimalUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

class TrelloChatMessage {
  String id;
  String content;
  DateTime createdAt;
  TrelloUser user;

  TrelloChatMessage({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.user,
  });

  factory TrelloChatMessage.fromJson(Map<String, dynamic> json) {
    return TrelloChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: TrelloUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
