import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_vortezz_base/components/button.dart';
import 'package:flutter_vortezz_base/components/text.dart';
import 'package:truthordare/pages/home.dart';
import 'package:truthordare/struct/challenge.dart';
import 'package:truthordare/struct/gender.dart';
import 'package:truthordare/struct/player.dart';
import 'package:truthordare/struct/tord_client.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.client,
    required this.players,
    required this.category,
  });

  final TordClient client;
  final List<Player> players;
  final String category;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int currentPlayerIndex = 0;
  Player currentPlayer = Player.getEmptyPlayer();
  bool loaded = false;
  bool hasSeenConsentWarning = false;
  Challenge? currentChallenge;
  int currentTimer = 0;
  Timer? timer;

  Player? otherPlayer;
  Player? manOtherPlayer;
  Player? womanOtherPlayer;

  late TordClient client;
  late String category;
  late List<Player> players;
  late Queue<Challenge> truths = Queue();
  late Queue<Challenge> dares = Queue();

  @override
  void initState() {
    super.initState();

    client = widget.client;
    category = widget.category;
    players = widget.players;
    currentPlayer = players[currentPlayerIndex];

    addDareToQueue();
    addTruthToQueue();

    loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: CustomText(
                  client: client,
                  text: client.translate(
                    "game.quit.title",
                  ),
                  textType: TextType.subtitle,
                ),
                content: CustomText(
                  client: client,
                  text: client.translate(
                    "game.quit.content",
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: CustomText(
                      client: client,
                      text: client.translate(
                        "game.quit.cancel",
                      ),
                      textType: TextType.emphasis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => HomePage(
                            client: client,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: CustomText(
                      client: client,
                      text: client.translate(
                        "game.quit.leave",
                      ),
                      color: Colors.red,
                      textType: TextType.emphasis,
                    ),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(
            Icons.close,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.only(
          top: AppBar().preferredSize.height +
              MediaQuery.of(context).viewPadding.top,
          left: 10,
          right: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: !hasSeenConsentWarning
                ? <Color>[
                    const Color(0xffffc07b),
                    const Color(0xffff9c00),
                  ]
                : currentChallenge == null
                    ? <Color>[
                        const Color(0xff6ddd78),
                        const Color(0xff0bca19),
                      ]
                    : currentChallenge?.type == "truth"
                        ? <Color>[
                            const Color(0xff00d4ff),
                            const Color(0xff7c74ff),
                          ]
                        : <Color>[
                            const Color(0xffff9494),
                            const Color(0xffff0000),
                          ],
          ),
        ),
        child: Center(
          child: !hasSeenConsentWarning
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: client.translate("game.consent.title"),
                      client: client,
                      textType: TextType.title,
                      color: Colors.white,
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 20,
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: CustomText(
                        text: client.translate("game.consent.description"),
                        client: client,
                        textType: TextType.text,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        bottom: 20,
                      ),
                      child: Button(
                        text: client.translate("game.consent.play"),
                        onPressed: () {
                          setState(() {
                            hasSeenConsentWarning = true;
                          });
                        },
                        client: client,
                        isBlack: false,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(),
                    Text(
                      currentChallenge == null
                          ? currentPlayer.gender.icon
                          : currentChallenge?.type == "truth"
                              ? "❓"
                              : "🏃",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: currentChallenge == null
                          ? CustomText(
                              text: client.translate(
                                "game.title",
                                {
                                  "player": currentPlayer.name,
                                },
                              ),
                              color: Colors.white,
                              textType: TextType.subtitle,
                              client: client,
                            )
                          : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: formatChallenge(),
                              ),
                            ),
                    ),
                    currentChallenge != null
                        ? Column(
                            children: [
                              Button(
                                text: timer == null && currentTimer != 0
                                    ? client.translate("game.text.start_timer")
                                    : client.translate("game.text.next"),
                                onPressed: timer == null && currentTimer != 0
                                    ? () {
                                        setState(() {
                                          timer = Timer.periodic(
                                              const Duration(seconds: 1),
                                              (timer) {
                                            if (currentTimer == 0) {
                                              timer.cancel();
                                            } else {
                                              setState(() {
                                                currentTimer--;
                                              });
                                            }
                                          });
                                        });
                                      }
                                    : () {
                                        setState(() {
                                          currentPlayerIndex++;

                                          if (currentPlayerIndex ==
                                              players.length) {
                                            currentPlayerIndex = 0;
                                          }

                                          currentPlayer =
                                              players[currentPlayerIndex];
                                          currentChallenge = null;
                                          currentTimer = 0;
                                          timer?.cancel();
                                          timer = null;
                                        });
                                      },
                                client: client,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Button(
                                text: client.translate("game.text.truth"),
                                onPressed: () {
                                  if (truths.isEmpty) {
                                    addTruthToQueue();
                                  }

                                  findNewChallenge(truths);
                                },
                                client: client,
                                isBlack: false,
                              ),
                              Button(
                                text: client.translate("game.text.dare"),
                                onPressed: () {
                                  if (dares.isEmpty) {
                                    addDareToQueue();
                                  }

                                  findNewChallenge(dares);
                                },
                                client: client,
                              ),
                            ],
                          ),
                    Container(),
                  ],
                ),
        ),
      ),
    );
  }

  List<TextSpan> formatChallenge() {
    if (currentChallenge == null) {
      return [];
    }

    String text = currentChallenge?.descriptions[client.getLanguage()] ??
        currentChallenge?.descriptions["custom"] ??
        "";

    List<String> patterns = [];
    RegExp regExp = RegExp(
        r'{P}|\[timer\]|{OO}|{OM}|{OF}|\[(P|OO|OM|OF)\?([^:]*):([^:]*):([^\]]*)\]');
    RegExp genderRegExp = RegExp(r'\[(P|OO|OM|OF)\?([^:]*):([^:]*):([^\]]*)\]');
    text.splitMapJoin(regExp, onMatch: (Match match) {
      patterns.add(match.group(0) ?? "");
      return "";
    }, onNonMatch: (String nonMatch) {
      patterns.add(nonMatch);
      return "";
    });

    patterns.removeWhere((String pattern) => pattern.isEmpty);

    List<TextSpan> spans = [];

    for (String pattern in patterns) {
      if (regExp.hasMatch(pattern) && !genderRegExp.hasMatch(pattern)) {
        pattern = pattern.replaceAll("{P}", currentPlayer.name);
        pattern = pattern.replaceAll("{OO}", otherPlayer?.name ?? "");
        pattern = pattern.replaceAll("{OM}", manOtherPlayer?.name ?? "");
        pattern = pattern.replaceAll("{OF}", womanOtherPlayer?.name ?? "");
        pattern = pattern.replaceAll("[timer]", currentTimer.toString());

        spans.add(
          TextSpan(
            text: pattern,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24 * client.getTextScale(),
              fontFamily: client.isDyslexicFont ? "OpenDyslexic" : "OpenSans",
            ),
          ),
        );
      } else if (genderRegExp.hasMatch(pattern)) {
        Match match = genderRegExp.firstMatch(pattern)!;

        String player = match.group(1) ?? "";
        Player concernedPlayer;

        switch (player) {
          case "P":
            concernedPlayer = currentPlayer;
            break;
          case "OO":
            concernedPlayer = otherPlayer!;
            break;
          case "OM":
            concernedPlayer = manOtherPlayer!;
            break;
          case "OF":
            concernedPlayer = womanOtherPlayer!;
            break;
          default:
            concernedPlayer = currentPlayer;
        }

        String manText = match.group(2) ?? "";
        String womanText = match.group(3) ?? "";
        String otherText = match.group(4) ?? "";

        String text;

        if (concernedPlayer.gender == Gender.male) {
          text = manText;
        } else if (concernedPlayer.gender == Gender.female) {
          text = womanText;
        } else {
          text = otherText;
        }

        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 24 * client.getTextScale(),
              fontFamily: client.isDyslexicFont ? "OpenDyslexic" : "OpenSans",
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: pattern,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 24 * client.getTextScale(),
              fontFamily: client.isDyslexicFont ? "OpenDyslexic" : "OpenSans",
            ),
          ),
        );
      }
    }

    return spans;
  }

  void findNewChallenge(Queue<Challenge> challenges, [int iteration = 0]) {
    List<Player> otherPlayers = List.from(players);
    otherPlayers.remove(currentPlayer);
    otherPlayers.shuffle();

    int womanCount = 0;
    int womanInterestedCount = 0;
    int manCount = 0;
    int manInterestedCount = 0;
    int allCount = otherPlayers.length;
    int allInterestedCount = otherPlayers
        .where((player) =>
            player.interestedBy.contains(currentPlayer.gender.index))
        .length;

    for (Player player in otherPlayers) {
      if (player.gender == Gender.male) {
        manCount++;

        if (player.interestedBy.contains(currentPlayer.gender.index))
          manInterestedCount++;
      } else if (player.gender == Gender.female) {
        womanCount++;

        if (player.interestedBy.contains(currentPlayer.gender.index))
          womanCount++;
      }
    }

    Challenge? challenge;
    Queue<Challenge> notSuitableChallenges = Queue();
    while (challenge == null && challenges.isNotEmpty) {
      challenge = challenges.removeFirst();

      if (!challenge.suitableFor.contains(currentPlayer.gender.index) ||
          (challenge.isSexual &&
              intersectList(challenge.interestedBy, currentPlayer.interestedBy)
                  .isEmpty)) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (challenge.manPlayersNeeded > manCount ||
          (challenge.isSexual &&
              challenge.manPlayersNeeded > manInterestedCount)) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (challenge.womanPlayersNeeded > womanCount ||
          (challenge.isSexual &&
              challenge.womanPlayersNeeded > womanInterestedCount)) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (challenge.otherPlayersNeeded > allCount ||
          (challenge.isSexual &&
              challenge.otherPlayersNeeded > allInterestedCount)) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }
    }

    challenges.addAll(notSuitableChallenges);

    if (challenge == null) {
      if (challenges == truths) {
        addTruthToQueue();
      } else {
        addDareToQueue();
      }

      if (iteration == 0) {
        findNewChallenge(challenges, iteration + 1);
      } else {
        setState(() {
          currentChallenge = Challenge.getEmptyChallenge();

          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: CustomText(
                client: client,
                text: client.translate(
                  "game.no_challenge.title",
                ),
                textType: TextType.subtitle,
              ),
              content: CustomText(
                client: client,
                text: client.translate(
                  "game.no_challenge.content",
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => HomePage(
                          client: client,
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: CustomText(
                    client: client,
                    text: client.translate(
                      "game.no_challenge.leave",
                    ),
                    color: Colors.red,
                    textType: TextType.emphasis,
                  ),
                ),
              ],
            ),
          );
        });
      }
      return;
    }

    setState(() {
      currentChallenge = challenge;

      if (challenge == null) {
        return;
      }

      if (challenge.timer != 0) {
        currentTimer = challenge.timer;
      }

      if (challenge.manPlayersNeeded != 0) {
        manOtherPlayer = otherPlayers
            .where((player) =>
                !challenge!.isSexual ||
                player.interestedBy.contains(currentPlayer.gender.index))
            .firstWhere(((Player player) => player.gender == Gender.male));

        otherPlayers.remove(manOtherPlayer);
      }

      if (challenge.womanPlayersNeeded != 0) {
        womanOtherPlayer = otherPlayers
            .where((player) =>
                !challenge!.isSexual ||
                player.interestedBy.contains(currentPlayer.gender.index))
            .firstWhere(((Player player) => player.gender == Gender.female));

        otherPlayers.remove(womanOtherPlayer);
      }

      if (challenge.otherPlayersNeeded != 0) {
        otherPlayer = otherPlayers
            .where((player) =>
                !challenge!.isSexual ||
                player.interestedBy.contains(currentPlayer.gender.index))
            .first;
      }
    });
  }

  void addDareToQueue() {
    List<Challenge> list = client.getChallengesInCategory(category);

    int menCount = players.where((p) => p.gender == Gender.male).length;
    int womenCount = players.where((p) => p.gender == Gender.female).length;
    int otherCount = players.length;

    for (Challenge challenge in list) {
      if (challenge.type == "dare") {
        if (challenge.manPlayersNeeded <= menCount &&
            challenge.womanPlayersNeeded <= womenCount &&
            challenge.otherPlayersNeeded <= otherCount) {
          dares.add(challenge);
        }
      }
    }
  }

  void addTruthToQueue() {
    List<Challenge> list = client.getChallengesInCategory(category);

    int menCount = players.where((p) => p.gender == Gender.male).length;
    int womenCount = players.where((p) => p.gender == Gender.female).length;
    int otherCount = players.length;

    for (Challenge challenge in list) {
      if (challenge.type == "truth") {
        if (challenge.manPlayersNeeded <= menCount &&
            challenge.womanPlayersNeeded <= womenCount &&
            challenge.otherPlayersNeeded <= otherCount) {
          truths.add(challenge);
        }
      }
    }
  }

  List<int> intersectList(List<int> lst1, List<int> lst2) {
    List<int> result = [];

    for (int elem in lst1) {
      if (lst2.contains(elem)) {
        result.add(elem);
      }
    }

    return result;
  }
}
