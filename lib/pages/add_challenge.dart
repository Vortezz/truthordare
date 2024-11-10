import 'package:flutter/material.dart';
import 'package:flutter_vortezz_base/components/button.dart';
import 'package:flutter_vortezz_base/components/icon_picker.dart';
import 'package:flutter_vortezz_base/components/multiple_icon_picker.dart';
import 'package:flutter_vortezz_base/components/text.dart';
import 'package:truthordare/struct/challenge.dart';
import 'package:truthordare/struct/challenge_category.dart';
import 'package:truthordare/struct/tord_client.dart';
import 'package:truthordare/struct/gender.dart';

class AddChallengePage extends StatefulWidget {
  const AddChallengePage({super.key, required this.client, this.challenge});

  final TordClient client;
  final Challenge? challenge;

  @override
  State<AddChallengePage> createState() => _AddChallengePageState();
}

class _AddChallengePageState extends State<AddChallengePage> {
  final FocusNode _focusNode = FocusNode();
  late TordClient client;
  late TextEditingController _textController;
  late TextEditingController _timerController;

  List<String> quickMenuText = [
    "player",
    "otherman",
    "otherwoman",
    "other",
    "timer"
  ];
  List<String> quickMenuPatterns = ["{P}", "{OM}", "{OF}", "{OO}", "[timer]"];

  String text = "";
  String type = "truth";
  String category = "chill";
  int timer = 0;
  bool isSexual = false;
  List<Gender> suitableFor = [Gender.male, Gender.female, Gender.other];

  @override
  void initState() {
    client = widget.client;
    _textController = TextEditingController();
    _timerController = TextEditingController(text: "0");

    if (widget.challenge != null) {
      Challenge challenge = widget.challenge!;
      text = challenge.descriptions["custom"] ?? "";
      _textController.text = text;
      type = challenge.type;
      category = challenge.category;
      timer = challenge.timer;
      _timerController.text = timer.toString();
      suitableFor = [
        if (challenge.suitableFor.contains(Gender.male.index)) Gender.male,
        if (challenge.suitableFor.contains(Gender.female.index)) Gender.female,
        if (challenge.suitableFor.contains(Gender.other.index)) Gender.other,
      ];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      bottomSheet: !_focusNode.hasPrimaryFocus
          ? null
          : Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              color: Colors.white,
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                      onPressed: () {
                        _textController.text += "${quickMenuPatterns[index]} ";
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: CustomText(
                        text: client.translate(
                            "add_challenge.quick_menu.${quickMenuText[index]}"),
                        client: client,
                        textType: TextType.text,
                        color: Colors.black,
                      ));
                },
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: client.translate("add_challenge.title"),
                  client: client,
                  textType: TextType.title,
                  color: Colors.white,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Container(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: client.translate("add_challenge.text"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _textController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: client.translate("add_challenge.hint"),
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontFamily: client.isDyslexicFont
                                ? "OpenDyslexic"
                                : "OpenSans",
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        onChanged: (value) {
                          setState(() {
                            text = value;
                          });
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text:
                                client.translate("add_challenge.suitable_for"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      MultipleIconPicker(
                        client: client,
                        data: [
                          MultipleIconPickerData(
                              icon: Gender.male.icon,
                              text: client.translate("gender.male")),
                          MultipleIconPickerData(
                              icon: Gender.female.icon,
                              text: client.translate("gender.female")),
                          MultipleIconPickerData(
                              icon: Gender.other.icon,
                              text: client.translate("gender.other")),
                        ],
                        onPressed: (index) {
                          setState(() {
                            suitableFor =
                                index.map((e) => Gender.values[e]).toList();
                          });
                        },
                        value: suitableFor.map((e) => e.index).toList(),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: client.translate("add_challenge.type"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconPicker(
                        client: client,
                        data: [
                          IconPickerData(
                              icon: "❓",
                              text: client.translate("add_challenge.truth")),
                          IconPickerData(
                              icon: "🏃",
                              text: client.translate("add_challenge.dare")),
                        ],
                        onPressed: (index) {
                          setState(() {
                            type = index == 0 ? "truth" : "dare";
                          });
                        },
                        value: type == "truth" ? 0 : 1,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: client.translate("add_challenge.timer"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _timerController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText:
                              client.translate("add_challenge.timer_hint"),
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontFamily: client.isDyslexicFont
                                ? "OpenDyslexic"
                                : "OpenSans",
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        onChanged: (value) {
                          setState(() {
                            String newValue =
                                value.replaceAll(RegExp(r"\D"), "");

                            if (newValue.isEmpty) {
                              newValue = "0";
                            }

                            timer = int.parse(newValue);

                            _timerController.text = timer.toString();
                          });
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: client.translate("add_challenge.category"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconPicker(
                        client: client,
                        data: [
                          for (ChallengeCategory category in client.categories
                              .where((element) => element.id != "custom"))
                            IconPickerData(
                                icon: category.icon,
                                text: client
                                    .translate("category.${category.id}.name")),
                        ],
                        onPressed: (index) {
                          setState(() {
                            category = client.categories
                                .where((element) => element.id != "custom")
                                .elementAt(index)
                                .id;
                          });
                        },
                        value: client.categories
                            .where((element) => element.id != "custom")
                            .toList()
                            .indexWhere((element) => element.id == category),
                      ),
                      Container(
                        height: 20,
                      ),
                      if (category == "extreme")
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomText(
                                text:
                                    client.translate("add_challenge.is_sexual"),
                                client: client,
                                textType: TextType.emphasis,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                              ),
                              Switch(
                                value: isSexual,
                                onChanged: (value) {
                                  setState(() {
                                    isSexual = value;
                                  });
                                },
                                activeColor: Colors.green,
                                activeTrackColor: Colors.white,
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      if (category == "extreme")
                        Container(
                          height: 20,
                        ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: Button(
                    client: client,
                    text: widget.challenge == null
                        ? client.translate("add_challenge.add")
                        : client.translate("add_challenge.update"),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();

                      List<int> isInterested = [];

                      if (text.contains("{OO}")) {
                        isInterested = [0, 1, 2];
                      } else {
                        if (text.contains("{OM}")) {
                          isInterested += [0];
                        }
                        if (text.contains("{OF}")) {
                          isInterested += [1];
                        }
                      }

                      if (isInterested.isEmpty) {
                        isInterested = [0, 1, 2];
                      }

                      Challenge challenge = Challenge(
                        id: widget.challenge?.id ??
                            client.getNextCustomChallengeId(),
                        descriptions: {
                          "custom": text,
                        },
                        type: type,
                        category: category,
                        timer: timer,
                        suitableFor: suitableFor.map((e) => e.index).toList(),
                        interestedBy: isInterested,
                        isSexual: isSexual,
                      );

                      if (widget.challenge != null) {
                        client.replaceCustomChallenge(challenge);
                      } else {
                        client.addCustomChallenge(challenge);
                      }

                      Navigator.pop(context);
                    },
                    isDisabled: _textController.text.isEmpty,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
