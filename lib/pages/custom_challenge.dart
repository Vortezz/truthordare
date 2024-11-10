import 'package:flutter/material.dart';
import 'package:flutter_vortezz_base/components/button.dart';
import 'package:flutter_vortezz_base/components/text.dart';
import 'package:truthordare/pages/add_challenge.dart';
import 'package:truthordare/struct/challenge.dart';
import 'package:truthordare/struct/challenge_category.dart';
import 'package:truthordare/struct/tord_client.dart';

class CustomChallengePage extends StatefulWidget {
  const CustomChallengePage({
    super.key,
    required this.client,
  });

  final TordClient client;

  @override
  State<CustomChallengePage> createState() => _CustomChallengePageState();
}

class _CustomChallengePageState extends State<CustomChallengePage> {
  late TordClient client;
  final ScrollController _scrollController = ScrollController();

  bool longPressedModeEnabled = false;
  List<int> selectedChallenges = [];

  @override
  void initState() {
    client = widget.client;
    super.initState();

    client.on("reloadCustomChallenges", (state) {
      print("here");
      setState(() {
        longPressedModeEnabled = false;
        selectedChallenges = [];
      });
    });

    client.on("success", (message) {
      setState(() {
        longPressedModeEnabled = false;
        selectedChallenges = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: message as String,
            client: client,
            textType: TextType.text,
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        ),
      );
    });

    client.on("error", (message) {
      setState(() {
        longPressedModeEnabled = false;
        selectedChallenges = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: message as String,
            client: client,
            textType: TextType.text,
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        ),
      );
    });

    client.on("import_warning", (func) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: CustomText(
                client: client,
                text: client.translate("custom_challenge.import_warning.title"),
                textType: TextType.subtitle,
              ),
              content: CustomText(
                client: client,
                text:
                    client.translate("custom_challenge.import_warning.content"),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: CustomText(
                    client: client,
                    text: client
                        .translate("custom_challenge.import_warning.cancel"),
                    textType: TextType.emphasis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    (func as Function)();
                    Navigator.pop(context);
                  },
                  child: CustomText(
                    client: client,
                    text: client
                        .translate("custom_challenge.import_warning.replace"),
                    textType: TextType.emphasis,
                  ),
                ),
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: longPressedModeEnabled ? Colors.black : Colors.white,
        ),
        backgroundColor:
            longPressedModeEnabled ? Colors.white : Colors.transparent,
        elevation: 0,
        actions: longPressedModeEnabled
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: CustomText(
                          client: client,
                          text: client.translate(
                            "custom_challenge.delete.title",
                          ),
                          textType: TextType.subtitle,
                        ),
                        content: CustomText(
                          client: client,
                          text: client.translate(
                            "custom_challenge.delete.content",
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: CustomText(
                              client: client,
                              text: client.translate(
                                "custom_challenge.delete.cancel",
                              ),
                              textType: TextType.emphasis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              client.removeCustomChallenges(selectedChallenges);

                              setState(() {
                                longPressedModeEnabled = false;
                                selectedChallenges = [];
                              });

                              Navigator.pop(context, 'Delete');
                            },
                            child: CustomText(
                              client: client,
                              text: client.translate(
                                "custom_challenge.delete.delete",
                              ),
                              color: Colors.red,
                              textType: TextType.emphasis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      longPressedModeEnabled = false;
                      selectedChallenges = [];
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ]
            : [
                PopupMenuButton<int>(
                  onSelected: (int item) {
                    if (item == 0) {
                      client.importCustomChallenges();
                    } else if (item == 1) {
                      client.exportCustomChallenges();
                    }
                  },
                  color: Colors.white,
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.download,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          CustomText(
                            client: client,
                            text: client
                                .translate("custom_challenge.popup.import"),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.upload,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          CustomText(
                            client: client,
                            text: client
                                .translate("custom_challenge.popup.export"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.only(
          top: AppBar().preferredSize.height +
              MediaQuery.of(context).viewPadding.top,
          left: 10,
          right: 10,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xffc597ff),
              Color(0xff9e06ff),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: client.translate("custom_challenges.title"),
                    client: client,
                    textType: TextType.title,
                    color: Colors.white,
                  ),
                  client.customChallenges.isEmpty
                      ? Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                            bottom: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  right: 16,
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                              ),
                              CustomText(
                                text: client.translate(
                                    "custom_challenges.no_challenge"),
                                client: client,
                                textType: TextType.text,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.only(
                            top: 20,
                            bottom: 20,
                          ),
                          // preferredSize.appBarHeight +
                          height: MediaQuery.of(context).size.height -
                              AppBar().preferredSize.height -
                              MediaQuery.of(context).viewPadding.top -
                              51 -
                              110 -
                              40,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: client.customChallenges.length,
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              Challenge challenge =
                                  client.customChallenges[index];
                              ChallengeCategory category = client
                                  .challengeCategories[challenge.category]!;

                              return ElevatedButton(
                                onPressed: () async {
                                  if (longPressedModeEnabled) {
                                    setState(() {
                                      if (selectedChallenges
                                          .contains(challenge.id)) {
                                        selectedChallenges.remove(challenge.id);

                                        if (selectedChallenges.isEmpty) {
                                          longPressedModeEnabled = false;
                                        }
                                      } else {
                                        selectedChallenges.add(challenge.id);
                                      }
                                    });
                                  } else {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddChallengePage(
                                            client: client,
                                            challenge: challenge,
                                          );
                                        },
                                      ),
                                    );

                                    setState(() {});
                                  }
                                },
                                onLongPress: () {
                                  if (!longPressedModeEnabled) {
                                    setState(() {
                                      longPressedModeEnabled = true;
                                      selectedChallenges.add(challenge.id);
                                    });
                                  } else {
                                    setState(() {
                                      selectedChallenges.add(challenge.id);
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ).copyWith(
                                  overlayColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                    selectedChallenges.contains(challenge.id)
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.transparent,
                                  ),
                                  elevation: MaterialStateProperty.all(0),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          category.icon,
                                          style: const TextStyle(
                                            fontSize: 36,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                    0.8 -
                                                50,
                                        child: CustomText(
                                          text: challenge
                                                  .descriptions["custom"] ??
                                              "",
                                          client: client,
                                          color: Colors.white,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Button(
                      text: client.translate("custom_challenges.add_challenge"),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return AddChallengePage(
                              client: client,
                            );
                          },
                        ));
                      },
                      client: client,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
