class Board {
  final String id;
  final String title;
  final String ownerId;
  final BoardOwner owner;
  final List<BoardUser> members;
  final List<BoardUser> viewers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Board({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.owner,
    required this.members,
    required this.viewers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as String,
      title: json['title'] as String,
      ownerId: json['ownerId'] as String,
      owner: BoardOwner.fromJson(json['owner'] as Map<String, dynamic>),
      members:
          (json['members'] as List<dynamic>?)
              ?.map(
                (member) => BoardUser.fromJson(member as Map<String, dynamic>),
              )
              .toList() ??
          [],
      viewers:
          (json['viewers'] as List<dynamic>?)
              ?.map(
                (viewer) => BoardUser.fromJson(viewer as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ownerId': ownerId,
      'owner': owner.toJson(),
      'members': members.map((member) => member.toJson()).toList(),
      'viewers': viewers.map((viewer) => viewer.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class BoardUser {
  final String id;
  final String username;
  final String? email;

  BoardUser({required this.id, required this.username, this.email});

  factory BoardUser.fromJson(Map<String, dynamic> json) {
    return BoardUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email};
  }
}

class BoardOwner {
  final String id;
  final String username;

  BoardOwner({required this.id, required this.username});

  factory BoardOwner.fromJson(Map<String, dynamic> json) {
    return BoardOwner(
      id: json['id'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username};
  }
}
