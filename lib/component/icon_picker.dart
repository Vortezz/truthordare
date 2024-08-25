import 'package:flutter/material.dart';
import 'package:truthordare/component/text.dart';
import 'package:truthordare/struct/client.dart';

class IconPickerData {
  final String icon;
  final String text;

  IconPickerData({required this.icon, required this.text});
}

class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.client,
    required this.data,
    required this.onPressed,
    required this.value,
  });

  final Client client;
  final List<IconPickerData> data;
  final Function(int) onPressed;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: data.map((e) {
          int index = data.indexOf(e);
          return ElevatedButton(
            onPressed: () {
              onPressed(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              elevation: 0,
              padding: EdgeInsets.zero,
            ).copyWith(
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value == index ? Colors.white : Colors.transparent,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    data[index].icon,
                    style: const TextStyle(
                      fontSize: 36,
                    ),
                  ),
                ),
                CustomText(
                  text: data[index].text,
                  client: client,
                  textType: value == index ? TextType.emphasis : TextType.text,
                  color: Colors.white,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
