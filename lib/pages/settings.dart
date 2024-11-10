import 'package:flutter/material.dart';
import 'package:flutter_vortezz_base/components/button.dart';
import 'package:flutter_vortezz_base/components/icon_picker.dart';
import 'package:flutter_vortezz_base/components/text.dart';
import 'package:flutter_vortezz_base/struct/language.dart';
import 'package:truthordare/struct/tord_client.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.client});

  final TordClient client;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TordClient client;

  Language language = Language.system;
  bool isDyslexicFont = false;
  bool isBiggerText = false;
  bool isOnlyCustomChallenges = false;

  @override
  void initState() {
    client = widget.client;
    setState(() {
      language = client.language;
      isDyslexicFont = client.isDyslexicFont;
      isBiggerText = client.isBiggerText;
      isOnlyCustomChallenges = client.isOnlyCustomChallenges;
    });

    super.initState();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: client.translate("settings.title"),
                client: client,
                textType: TextType.title,
                color: Colors.white,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 30,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          text: client.translate("settings.language"),
                          client: client,
                          textType: TextType.emphasis,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          text:
                              client.translate("settings.language.description"),
                          client: client,
                          textType: TextType.text,
                          color: Colors.white,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    IconPicker(
                      client: client,
                      data: [
                        IconPickerData(
                          icon: "⚙️",
                          text: client.translate("settings.system"),
                        ),
                        IconPickerData(
                          icon: "🇬🇧",
                          text: client.translate("language.english"),
                        ),
                        IconPickerData(
                          icon: "🇫🇷",
                          text: client.translate("language.french"),
                        ),
                        IconPickerData(
                          icon: "🇩🇪",
                          text: client.translate("language.german"),
                        ),
                      ],
                      onPressed: (index) {
                        setState(() {
                          language = Language.values[index];
                        });
                      },
                      value: language.index,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            text: client.translate("settings.dyslexic_font"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                            textAlign: TextAlign.center,
                          ),
                          Switch(
                            value: isDyslexicFont,
                            onChanged: (value) {
                              setState(() {
                                isDyslexicFont = value;
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            text: client.translate("settings.bigger_text"),
                            client: client,
                            textType: TextType.emphasis,
                            color: Colors.white,
                            textAlign: TextAlign.center,
                          ),
                          Switch(
                            value: isBiggerText,
                            onChanged: (value) {
                              setState(() {
                                isBiggerText = value;
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.only(
                        top: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9 - 70,
                            child: CustomText(
                              text: client
                                  .translate("settings.only_custom_challenges"),
                              client: client,
                              textType: TextType.emphasis,
                              color: Colors.white,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Switch(
                            value: isOnlyCustomChallenges,
                            onChanged: (value) {
                              setState(() {
                                isOnlyCustomChallenges = value;
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
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  bottom: 20,
                ),
                child: Button(
                    client: client,
                    text: client.translate("settings.save"),
                    onPressed: () {
                      client.language = language;
                      client.isDyslexicFont = isDyslexicFont;
                      client.isBiggerText = isBiggerText;
                      client.isOnlyCustomChallenges = isOnlyCustomChallenges;

                      Navigator.pop(context);

                      client.emit("reloadSettings");
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
