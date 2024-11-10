import 'dart:convert';

class Challenge {
  Challenge({
    required this.id,
    required this.descriptions,
    required this.category,
    required this.type,
    required this.timer,
    required this.suitableFor,
    required this.interestedBy,
    required this.isSexual,
  });

  final int id;
  final Map<String, String> descriptions;
  final String category;
  final String type;
  final int timer;
  final List<int> suitableFor;
  final List<int> interestedBy;
  final bool isSexual;

  int otherPlayersNeeded = 0;
  int manPlayersNeeded = 0;
  int womanPlayersNeeded = 0;

  static Map<String, String> _dynamicMapToMap(
      Map<dynamic, dynamic> dynamicMap) {
    Map<String, String> map = {};
    dynamicMap.forEach((key, value) {
      map[key.toString()] = value.toString();
    });
    return map;
  }

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as int,
        descriptions: _dynamicMapToMap(json['descriptions']),
        category: json['category'] as String,
        type: json['type'] as String,
        timer: json['timer'] as int,
        suitableFor: ((json['suitableFor'] ?? []) as List<dynamic>)
            .map((e) => e as int)
            .toList(),
        interestedBy: ((json['interestedBy'] ?? []) as List<dynamic>)
            .map((e) => e as int)
            .toList(),
        isSexual: (json['isSexual'] ?? false) as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'descriptions': descriptions,
        'category': category,
        'type': type,
        'timer': timer,
        'suitableFor': suitableFor,
        'interestedBy': interestedBy,
        'isSexual': isSexual,
      };

  static Map<num, Challenge> fromJsonList(String challengesJson) {
    Map<num, Challenge> challenges = {};
    List<dynamic> challengesList = jsonDecode(challengesJson);

    for (var challenge in challengesList) {
      var value = Challenge.fromJson(challenge);
      value.resolveMinPlayers();
      challenges[challenge['id']] = value;
    }

    return challenges;
  }

  void resolveMinPlayers() {
    String description = descriptions["en"] ?? "";

    if ("{OO}".allMatches(description).isNotEmpty) {
      otherPlayersNeeded = 1;
    }

    if ("{OM}".allMatches(description).isNotEmpty) {
      manPlayersNeeded = 1;
    }

    if ("{OF}".allMatches(description).isNotEmpty) {
      womanPlayersNeeded = 1;
    }
  }

  static getEmptyChallenge() {
    return Challenge(
      id: 0,
      descriptions: {},
      category: "",
      type: "",
      timer: 0,
      suitableFor: [],
      interestedBy: [],
      isSexual: false,
    );
  }
}
