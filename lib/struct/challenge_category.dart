import 'dart:convert';

class ChallengeCategory {
  ChallengeCategory({
    required this.id,
    required this.suitableForChildren,
    required this.icon,
    required this.color,
  });

  final String id;
  final bool suitableForChildren;
  final String icon;
  final String color;

  factory ChallengeCategory.fromJson(Map<String, dynamic> json) =>
      ChallengeCategory(
        id: json['id'] as String,
        suitableForChildren: json['suitableForChildren'] as bool,
        icon: json['icon'] as String,
        color: json['color'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'suitableForChildren': suitableForChildren,
        'icon': icon,
        'color': color,
      };

  static Map<String, ChallengeCategory> fromJsonList(
      String challengeCategoriesJson) {
    Map<String, ChallengeCategory> challengeCategories = {};
    List<dynamic> challengeCategoriesList = jsonDecode(challengeCategoriesJson);

    for (var challengeCategory in challengeCategoriesList) {
      challengeCategories[challengeCategory['id']] =
          ChallengeCategory.fromJson(challengeCategory);
    }

    return challengeCategories;
  }
}
