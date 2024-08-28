import 'package:flutter/material.dart';
import 'package:truthordare/component/text.dart';
import 'package:truthordare/struct/client.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key, required this.client}) : super(key: key);

  final Client client;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late Client client;

  @override
  void initState() {
    client = widget.client;
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
              Color(0xff979aff),
              Color(0xff0615ff),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                text: client.translate("about.title"),
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
                  client: client,
                  text: client.translate("about.description"),
                  color: Colors.white,
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            "https://vortezz.dev/privacy",
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.note_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            "https://github.com/Vortezz/truthordare",
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.code,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            "https://forms.gle/DHB72KrcKcsHJYuT7",
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}
