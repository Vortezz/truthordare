import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthordare/struct/challenge.dart';
import 'package:truthordare/struct/challenge_category.dart';
import 'package:truthordare/struct/event_emitter.dart';
import 'package:truthordare/struct/language.dart';

class Client with EventEmitter {
  Map<String, ChallengeCategory> challengeCategories = {};
  Map<num, Challenge> challenges = {};
  Map<String, Map<String, String>> translations = {};
  List<Challenge> customChallenges = [];

  bool _loaded = false;
  String _systemLanguage = "en";
  Language _language = Language.system;

  bool _dyslexicFont = false;
  bool _biggerText = false;
  bool _onlyCustomChallenges = false;

  Client() {
    load();
  }

  late SharedPreferences preferences;

  get categories => challengeCategories.values.toList();

  Language get language => _language;

  set language(Language language) {
    _language = language;
    preferences.setString(
        "truthordare.language", language.toString().split(".")[1]);
  }

  bool get isDyslexicFont => _dyslexicFont;

  set isDyslexicFont(bool isDyslexicFont) {
    _dyslexicFont = isDyslexicFont;
    preferences.setBool("truthordare.dyslexic_font", isDyslexicFont);
  }

  bool get isBiggerText => _biggerText;

  set isBiggerText(bool isBiggerText) {
    _biggerText = isBiggerText;
    preferences.setBool("truthordare.bigger_text", isBiggerText);
  }

  bool get isOnlyCustomChallenges => _onlyCustomChallenges;

  set isOnlyCustomChallenges(bool onlyCustomChallenges) {
    _onlyCustomChallenges = onlyCustomChallenges;
    preferences.setBool(
        "truthordare.only_custom_challenges", onlyCustomChallenges);
  }

  Future<void> load() async {
    for (String lang in ["en", "fr", "de"]) {
      String translationJson =
          await rootBundle.loadString("assets/lang/$lang.json");

      Map<String, dynamic> json = jsonDecode(translationJson);

      Map<String, String> translation = {};

      for (MapEntry entry in json.entries) {
        translation[entry.key] = entry.value as String;
      }

      translations[lang] = translation;
    }

    preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey("truthordare.dyslexic_font")) {
      preferences.setBool("truthordare.dyslexic_font", false);
    }

    _dyslexicFont = preferences.getBool("truthordare.dyslexic_font") ?? false;

    if (!preferences.containsKey("truthordare.bigger_text")) {
      preferences.setBool("truthordare.bigger_text", false);
    }

    _biggerText = preferences.getBool("truthordare.bigger_text") ?? false;

    if (!preferences.containsKey("truthordare.only_custom_challenges")) {
      preferences.setBool("truthordare.only_custom_challenges", false);
    }

    _onlyCustomChallenges =
        preferences.getBool("truthordare.only_custom_challenges") ?? false;

    if (!preferences.containsKey("truthordare.language")) {
      preferences.setString("truthordare.language", "system");
    }

    switch (preferences.getString("truthordare.language")) {
      case "system":
        language = Language.system;
        _systemLanguage = SchedulerBinding.instance.window.locale.languageCode;

        if (!translations.containsKey(_systemLanguage)) {
          _systemLanguage = "en";
        }
        break;
      case "en":
        language = Language.en;
        break;
      case "fr":
        language = Language.fr;
        break;
      case "de":
        language = Language.de;
        break;
      default:
        language = Language.system;
        _systemLanguage = SchedulerBinding.instance.window.locale.languageCode;

        if (!translations.containsKey(_systemLanguage)) {
          _systemLanguage = "en";
        }
        preferences.setString("truthordare.language", "system");
        break;
    }

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

    _loaded = true;

    emit("loaded");
  }

  bool get loaded => _loaded;

  String getLanguage() {
    switch (language) {
      case Language.en:
        return "en";
      case Language.fr:
        return "fr";
      case Language.de:
        return "de";
      default:
        return _systemLanguage;
    }
  }

  String translate(String key, [Map<String, String>? replacements]) {
    replacements ??= Map.identity();

    String text = key;
    if (translations[getLanguage()] != null &&
        translations[getLanguage()]!.containsKey(key)) {
      text = translations[getLanguage()]![key] ?? key;
    }

    for (MapEntry entry in replacements.entries) {
      text = text.replaceAll("{${entry.key}}", entry.value);
    }

    return text;
  }

  double getTextScale() {
    return isBiggerText ? 1.2 : 1;
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
