import 'package:truthordare/struct/gender.dart';

class Player {
  Player({
    required this.name,
    required this.gender,
    required this.interestedBy,
  });

  final String name;
  final List<int> interestedBy;
  Gender gender;

  static Player getEmptyPlayer() {
    return Player(name: "", gender: Gender.other, interestedBy: []);
  }
}
