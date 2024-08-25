import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:truthordare/component/button.dart';
import 'package:truthordare/component/text.dart';
import 'package:truthordare/pages/home.dart';
import 'package:truthordare/struct/challenge.dart';
import 'package:truthordare/struct/client.dart';
import 'package:truthordare/struct/gender.dart';
import 'package:truthordare/struct/player.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.client,
    required this.players,
    required this.category,
  });

  final Client client;
  final List<Player> players;
  final String category;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int currentPlayerIndex = 0;
  Player currentPlayer = Player.getEmptyPlayer();
  bool loaded = false;
  Challenge? currentChallenge;
  int currentTimer = 0;
  Timer? timer;

  Player? otherPlayer;
  Player? manOtherPlayer;
  Player? womanOtherPlayer;

  late Client client;
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
            colors: currentChallenge == null
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
          child: Column(
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
                                        const Duration(seconds: 1), (timer) {
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

                                    if (currentPlayerIndex == players.length) {
                                      currentPlayerIndex = 0;
                                    }

                                    currentPlayer = players[currentPlayerIndex];
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
    int manCount = 0;
    int allCount = otherPlayers.length;

    for (Player player in otherPlayers) {
      if (player.gender == Gender.male) {
        manCount++;
      } else if (player.gender == Gender.female) {
        womanCount++;
      }
    }

    Challenge? challenge;
    Queue<Challenge> notSuitableChallenges = Queue();
    while (challenge == null && challenges.isNotEmpty) {
      challenge = challenges.removeFirst();

      if (!challenge.suitableForMan && currentPlayer.gender == Gender.male) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (!challenge.suitableForWoman &&
          currentPlayer.gender == Gender.female) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (!challenge.suitableForOther && currentPlayer.gender == Gender.other) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (challenge.manPlayersNeeded > manCount) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (challenge.womanPlayersNeeded > womanCount) {
        notSuitableChallenges.add(challenge);
        challenge = null;
        continue;
      }

      if (challenge.otherPlayersNeeded > allCount) {
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

          // TODO: Add a message to the user that no suitable challenge was found
        });
      }
      return;
    }

    setState(() {
      currentChallenge = challenge;

      if (challenge?.timer != 0) {
        currentTimer = challenge?.timer ?? 0;
      }

      if (challenge?.manPlayersNeeded != 0) {
        manOtherPlayer = otherPlayers
            .firstWhere(((Player player) => player.gender == Gender.male));

        otherPlayers.remove(manOtherPlayer);
      }

      if (challenge?.womanPlayersNeeded != 0) {
        womanOtherPlayer = otherPlayers
            .firstWhere(((Player player) => player.gender == Gender.female));

        otherPlayers.remove(womanOtherPlayer);
      }

      if (challenge?.otherPlayersNeeded != 0) {
        otherPlayer = otherPlayers.first;
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
}
