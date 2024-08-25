import 'package:flutter/material.dart';
import 'package:truthordare/component/button.dart';
import 'package:truthordare/component/text.dart';
import 'package:truthordare/pages/add_player.dart';
import 'package:truthordare/pages/game.dart';
import 'package:truthordare/struct/client.dart';
import 'package:truthordare/struct/player.dart';

class PlayerSelectionPage extends StatefulWidget {
  const PlayerSelectionPage({
    super.key,
    required this.client,
    required this.category,
  });

  final Client client;
  final String category;

  @override
  State<PlayerSelectionPage> createState() => _PlayerSelectionPageState();
}

class _PlayerSelectionPageState extends State<PlayerSelectionPage> {
  late Client client;
  late String category;

  ScrollController _scrollController = ScrollController();
  List<Player> players = [];

  @override
  void initState() {
    client = widget.client;
    category = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    text: client.translate("player_selection.title"),
                    client: client,
                    textType: TextType.title,
                    color: Colors.white,
                  ),
                  players.isEmpty
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
                                text: client
                                    .translate("player_selection.no_player"),
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
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: players.length,
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              Player player = players[index];

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        player.gender.icon,
                                        style: TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                          left: 16,
                                        ),
                                        child: CustomText(
                                          text: player.name,
                                          client: client,
                                          textType: TextType.subtitle,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        players.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ],
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
                      text: client.translate("player_selection.add_player"),
                      onPressed: () {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPlayerPage(
                                client: client,
                                onAddPlayer: (Player player) {
                                  if (players.map((e) => e.name).contains(player.name)) {
                                    return false;
                                  }

                                  setState(() {
                                    players.add(player);
                                  });

                                  if (_scrollController.hasClients) {
                                    _scrollController.animateTo(
                                      _scrollController
                                              .position.maxScrollExtent +
                                          50,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  }

                                  return true;
                                },
                              ),
                            ),
                          );
                        });
                      },
                      client: client,
                      isBlack: false,
                    ),
                    Button(
                      text: client.translate("player_selection.start_game"),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => GamePage(
                              players: players,
                              category: category,
                              client: client,
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      client: client,
                      isDisabled: players.length < 2,
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
