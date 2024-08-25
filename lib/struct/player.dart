import 'package:truthordare/struct/gender.dart';

class Player {
  Player({
    required this.name,
    required this.gender,
  });

  final String name;
  Gender gender;

  static Player getEmptyPlayer() {
    return Player(
      name: "",
      gender: Gender.other,
    );
  }
}
