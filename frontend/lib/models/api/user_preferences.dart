class UserPreferences {
  final String userId;
  final String localization;
  final String theme;
  final bool showAssignedCardsInHomepage;

  UserPreferences({
    required this.userId,
    required this.localization,
    required this.theme,
    required this.showAssignedCardsInHomepage,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] as String,
      localization: json['localization'] as String,
      theme: json['theme'] as String,
      showAssignedCardsInHomepage: json['showAssignedCardsInHomepage'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'localization': localization,
      'theme': theme,
      'showAssignedCardsInHomepage': showAssignedCardsInHomepage,
    };
  }

  UserPreferences copyWith({
    String? userId,
    String? localization,
    String? theme,
    bool? showAssignedCardsInHomepage,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      localization: localization ?? this.localization,
      theme: theme ?? this.theme,
      showAssignedCardsInHomepage:
          showAssignedCardsInHomepage ?? this.showAssignedCardsInHomepage,
    );
  }
}
