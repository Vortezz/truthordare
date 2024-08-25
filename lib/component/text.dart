import 'package:flutter/material.dart';
import 'package:truthordare/struct/client.dart';

enum TextType { button, title, subtitle, text, emphasis, bottomText }

class CustomText extends StatelessWidget {
  const CustomText({
    Key? key,
    required this.text,
    this.textType,
    this.color,
    required this.client,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  final Client client;

  final String text;
  final TextType? textType;
  final Color? color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontWeight: getFontWeight(),
        fontSize: getFontSize(),
        color: color ?? Colors.black,
        fontFamily: client.isDyslexicFont ? "OpenDyslexic" : "OpenSans",
      ),
    );
  }

  double getFontSize() {
    switch (textType ?? TextType.text) {
      case TextType.button:
        return 20 * client.getTextScale();
      case TextType.title:
        return 36;
      case TextType.subtitle:
        return 24 * client.getTextScale();
      case TextType.text:
        return 18 * client.getTextScale();
      case TextType.emphasis:
        return 20 * client.getTextScale();
      case TextType.bottomText:
        return 16 * client.getTextScale();
    }
  }

  FontWeight getFontWeight() {
    switch (textType ?? TextType.text) {
      case TextType.button:
        return FontWeight.w800;
      case TextType.title:
        return FontWeight.w800;
      case TextType.subtitle:
        return FontWeight.w800;
      case TextType.text:
        return FontWeight.w300;
      case TextType.emphasis:
        return FontWeight.w800;
      case TextType.bottomText:
        return FontWeight.w600;
    }
  }
}
