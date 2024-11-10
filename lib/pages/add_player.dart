import 'package:flutter/material.dart';
import 'package:flutter_vortezz_base/components/button.dart';
import 'package:flutter_vortezz_base/components/icon_picker.dart';
import 'package:flutter_vortezz_base/components/multiple_icon_picker.dart';
import 'package:flutter_vortezz_base/components/text.dart';
import 'package:truthordare/struct/tord_client.dart';
import 'package:truthordare/struct/gender.dart';
import 'package:truthordare/struct/player.dart';

class AddPlayerPage extends StatefulWidget {
  const AddPlayerPage({
    super.key,
    required this.client,
    required this.onAddPlayer,
    required this.category,
  });

  final TordClient client;
  final String category;
  final Function(Player) onAddPlayer;

  @override
  State<AddPlayerPage> createState() => _AddPlayerPageState();
}

class _AddPlayerPageState extends State<AddPlayerPage> {
  late TordClient client;
  late TextEditingController _controller;
  late String category;

  String name = "";
  Gender gender = Gender.other;
  List<Gender> interestedBy = [Gender.male, Gender.female, Gender.other];

  @override
  void initState() {
    client = widget.client;
    category = widget.category;
    _controller = TextEditingController();
    setState(() {});
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
              CustomText(
                text: client.translate("add_player.title"),
                client: client,
                textType: TextType.title,
                color: Colors.white,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          text: client.translate("add_player.name"),
                          client: client,
                          textType: TextType.emphasis,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: client.translate("add_player.hint"),
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
                            left: 15, right: 15, top: 10, bottom: 10),
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
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
                          text: client.translate("add_player.gender"),
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
                            icon: Gender.male.icon,
                            text: client.translate("gender.male")),
                        IconPickerData(
                            icon: Gender.female.icon,
                            text: client.translate("gender.female")),
                        IconPickerData(
                            icon: Gender.other.icon,
                            text: client.translate("gender.other")),
                      ],
                      onPressed: (index) {
                        setState(() {
                          gender = Gender.values[index];
                        });
                      },
                      value: gender.index,
                    ),
                    if (category == "extreme")
                      Container(
                        margin: const EdgeInsets.only(
                          top: 30,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: client.translate("add_player.interested_by"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (category == "extreme")
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
                            interestedBy =
                                index.map((e) => Gender.values[e]).toList();
                          });
                        },
                        value: interestedBy.map((e) => e.index).toList(),
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
                  text: client.translate("add_player.button"),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();

                    bool success = widget.onAddPlayer(
                      Player(
                        name: _controller.text,
                        gender: gender,
                        interestedBy: interestedBy.map((e) => e.index).toList(),
                      ),
                    );

                    if (success) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: CustomText(
                            text: client.translate("add_player.already_exists"),
                            client: client,
                            textType: TextType.text,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  isDisabled: _controller.text.isEmpty,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
