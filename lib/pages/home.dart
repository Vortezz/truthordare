import 'package:flutter/material.dart';
import 'package:flutter_vortezz_base/components/text.dart';
import 'package:truthordare/pages/about.dart';
import 'package:truthordare/pages/custom_challenge.dart';
import 'package:truthordare/pages/player_selection.dart';
import 'package:truthordare/pages/settings.dart';
import 'package:truthordare/struct/challenge.dart';
import 'package:truthordare/struct/hexcolor.dart';
import 'package:truthordare/struct/tord_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.client});

  final TordClient client;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TordClient client;

  @override
  void initState() {
    super.initState();

    client = widget.client;

    client.on("reloadSettings", (state) {
      setState(() {});
    });

    client.on("loaded", (state) {
      setState(() {});
    });

    client.on("reloadCustomChallenges", (state) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.question_mark_rounded,
                color: Colors.white,
              ),
              tooltip: client.translate("about.title"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AboutPage(
                      client: client,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return SettingsPage(
                    client: client,
                  );
                }),
              );

              setState(() {});
            },
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
              Color(0xff979aff),
              Color(0xff0615ff),
            ],
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                text: client.translate("home.title"),
                client: client,
                textType: TextType.title,
                color: Colors.white,
              ),
              CustomText(
                text: client.translate("home.subtitle"),
                client: client,
                textType: TextType.text,
                color: Colors.white,
              ),
              Expanded(
                child: client.loaded
                    ? Container(
                        margin: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                          right: 20,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(0),
                          itemCount: client.categories.length,
                          itemBuilder: (context, index) {
                            String categoryId = client.categories[index].id;
                            List<Challenge> challenges =
                                client.getChallengesInCategory(categoryId);

                            if (categoryId == "custom") {
                              challenges.add(Challenge.getEmptyChallenge());
                            }

                            bool isEmpty = challenges.isEmpty;
                            return Card(
                              color: isEmpty
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.white,
                              margin: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              child: ListTile(
                                titleAlignment: ListTileTitleAlignment.center,
                                isThreeLine: true,
                                leading: Container(
                                  width: 76,
                                  height: 76,
                                  child: Center(
                                    child: Text(
                                      client.categories[index].icon,
                                      style: const TextStyle(
                                        fontSize: 36,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    CustomText(
                                      text: client.translate(
                                          "category.${categoryId}.name"),
                                      client: client,
                                      textType: TextType.emphasis,
                                      color: HexColor(
                                          client.categories[index].color),
                                      textAlign: TextAlign.left,
                                    ),
                                    if (isEmpty)
                                      SizedBox(
                                        width: 10,
                                      ),
                                    if (isEmpty)
                                      CustomText(
                                        text: client.translate("SOON"),
                                        client: client,
                                        textType: TextType.emphasis,
                                        color: Colors.red,
                                        textAlign: TextAlign.left,
                                      ),
                                  ],
                                ),
                                subtitle: CustomText(
                                  text: client.translate(
                                      "category.${categoryId}.description"),
                                  client: client,
                                  textType: TextType.text,
                                  color: Colors.black,
                                  textAlign: TextAlign.left,
                                ),
                                onTap: isEmpty
                                    ? null
                                    : () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                index ==
                                                        client.categories
                                                                .length -
                                                            1
                                                    ? CustomChallengePage(
                                                        client: client,
                                                      )
                                                    : PlayerSelectionPage(
                                                        client: client,
                                                        category: categoryId,
                                                      ),
                                          ),
                                        );

                                        setState(() {});
                                      },
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
