import 'package:flutter/material.dart';
import 'package:truthordare/component/text.dart';
import 'package:truthordare/struct/client.dart';

class GenderButton extends StatelessWidget {
  const GenderButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.client,
    this.isSelected = false,
  }) : super(key: key);

  final String text;
  final String icon;
  final Function() onPressed;
  final Client client;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
      ).copyWith(
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        elevation: MaterialStateProperty.all(0),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 36,
            ),
          ),
          CustomText(
            text: text,
            client: client,
            textType: isSelected ? TextType.emphasis : TextType.text,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
