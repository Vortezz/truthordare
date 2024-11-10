import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vortezz_base/struct/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthordare/struct/challenge.dart';
import 'package:truthordare/struct/challenge_category.dart';

class TordClient extends Client {
  Map<String, ChallengeCategory> challengeCategories = {};
  Map<num, Challenge> challenges = {};
  List<Challenge> customChallenges = [];

  bool _onlyCustomChallenges = false;

  TordClient() : super(appName: "truthordare");

  get categories => challengeCategories.values.toList();

  bool get isOnlyCustomChallenges => _onlyCustomChallenges;

  set isOnlyCustomChallenges(bool onlyCustomChallenges) {
    _onlyCustomChallenges = onlyCustomChallenges;
    preferences.setBool(
        "truthordare.only_custom_challenges", onlyCustomChallenges);
  }

  @override
  Future<void> load() async {
    super.load();

    preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey("truthordare.only_custom_challenges")) {
      preferences.setBool("truthordare.only_custom_challenges", false);
    }

    _onlyCustomChallenges =
        preferences.getBool("truthordare.only_custom_challenges") ?? false;

    // Load custom challenges
    if (!preferences.containsKey("truthordare.custom_challenges")) {
      preferences.setStringList("truthordare.custom_challenges", []);
    }

    List<String> customChallengesJson =
        preferences.getStringList("truthordare.custom_challenges") ?? [];

    for (String customChallengeJson in customChallengesJson) {
      customChallenges.add(Challenge.fromJson(jsonDecode(customChallengeJson)));
    }

    print("Loaded ${customChallenges.length} custom challenges");

    String challengeCategoriesJson = await rootBundle
        .loadString("assets/challenges/challenge_categories.json");
    challengeCategories =
        ChallengeCategory.fromJsonList(challengeCategoriesJson);

    challengeCategories["custom"] = ChallengeCategory(
      id: "custom",
      color: "#000000",
      suitableForChildren: true,
      icon: '🖍️',
    );

    print("Loaded ${challengeCategories.length} challenge categories");

    String challengesJson = utf8.fuse(base64).decode(
        await rootBundle.loadString("assets/challenges/challenges.txt"));
    challenges = Challenge.fromJsonList(challengesJson);

    print("Loaded ${challenges.length} challenges");

    loaded = true;

    emit("loaded");
  }

  int getNextCustomChallengeId() {
    int newId = 0;
    for (Challenge challenge in customChallenges) {
      if (challenge.id >= newId) {
        newId = challenge.id + 1;
      }
    }

    return newId;
  }

  void replaceCustomChallenge(Challenge challenge) {
    int index =
        customChallenges.indexWhere((element) => element.id == challenge.id);
    customChallenges.removeAt(index);
    customChallenges.insert(index, challenge);

    // Write to shared preferences
    preferences.setStringList("truthordare.custom_challenges",
        customChallenges.map((e) => jsonEncode(e.toJson())).toList());

    emit("reloadCustomChallenges");
  }

  void addCustomChallenge(Challenge challenge) {
    customChallenges.add(challenge);

    // Write to shared preferences
    preferences.setStringList("truthordare.custom_challenges",
        customChallenges.map((e) => jsonEncode(e.toJson())).toList());

    emit("reloadCustomChallenges");
  }

  void removeCustomChallenges(List<int> selectedChallenges) {
    customChallenges.removeWhere((element) {
      return selectedChallenges.contains(element.id);
    });

    preferences.setStringList("truthordare.custom_challenges",
        customChallenges.map((e) => jsonEncode(e.toJson())).toList());

    emit("reloadCustomChallenges");
  }

  List<Challenge> getChallengesInCategory(String categoryId) {
    List<Challenge> challengesInCategory = [];

    if (!isOnlyCustomChallenges) {
      for (Challenge challenge in challenges.values) {
        if (challenge.category == categoryId) {
          challengesInCategory.add(challenge);
        }
      }
    }

    for (Challenge challenge in customChallenges) {
      if (challenge.category == categoryId) {
        challengesInCategory.add(challenge);
      }
    }

    challengesInCategory.shuffle();

    return challengesInCategory;
  }

  Future<void> exportCustomChallenges() async {
    String customChallengesJson = jsonEncode(
        customChallenges.map((e) => jsonEncode(e.toJson())).toList());

    final String? directoryPath = await getDirectoryPath();
    if (directoryPath == null) {
      emit("error", translate("custom_challenge.export_error"));
      return;
    }

    final String filePath = '$directoryPath/custom_challenges.json';

    final File file = File(filePath);

    await file.writeAsString(customChallengesJson);

    emit("success", translate("custom_challenge.export_success"));
  }

  Future<void> importCustomChallenges() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'json',
      extensions: <String>['json'],
    );
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) {
      emit("error", translate("custom_challenge.import_error"));
      return;
    }

    String customChallengesJson = await file.readAsString();

    List<Challenge> customChallengesList = [];

    for (String customChallengeJson in jsonDecode(customChallengesJson)) {
      customChallengesList
          .add(Challenge.fromJson(jsonDecode(customChallengeJson)));
    }

    bool idIssue = false;

    for (Challenge challenge in customChallengesList) {
      if (customChallenges
              .indexWhere((element) => element.id == challenge.id) !=
          -1) {
        idIssue = true;
        break;
      }
    }

    if (idIssue) {
      emit("import_warning", () {
        customChallenges.removeWhere((element) {
          return customChallenges.where((e) => e.id == element.id).isNotEmpty;
        });

        customChallenges.addAll(customChallengesList);
        customChallenges.sort((a, b) => a.id.compareTo(b.id));

        preferences.setStringList("truthordare.custom_challenges",
            customChallenges.map((e) => jsonEncode(e.toJson())).toList());

        emit("success", translate("custom_challenge.import_success"));
      });
      return;
    } else {
      customChallenges.addAll(customChallengesList);

      preferences.setStringList("truthordare.custom_challenges",
          customChallenges.map((e) => jsonEncode(e.toJson())).toList());

      emit("success", translate("custom_challenge.import_success"));
    }
  }
}
