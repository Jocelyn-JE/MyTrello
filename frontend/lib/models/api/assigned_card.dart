class AssignedCard {
  final String id;
  final String title;
  final String content;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String columnId;
  final String columnTitle;
  final String boardId;
  final String boardTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssignedCard({
    required this.id,
    required this.title,
    required this.content,
    this.startDate,
    this.dueDate,
    required this.columnId,
    required this.columnTitle,
    required this.boardId,
    required this.boardTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignedCard.fromJson(Map<String, dynamic> json) {
    return AssignedCard(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      columnId: json['columnId'] as String,
      columnTitle: json['columnTitle'] as String,
      boardId: json['boardId'] as String,
      boardTitle: json['boardTitle'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
