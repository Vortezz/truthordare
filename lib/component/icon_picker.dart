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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 105,
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          // physics: const NeverScrollableScrollPhysics(),
          // Optional: disable internal scrolling if ListView is nested
          scrollDirection: Axis.horizontal,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(
                left: index != 0 ? 10 : 0,
                right: index != data.length - 1 ? 10 : 0,
              ),
              child: Center(
                child: ElevatedButton(
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
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: value == index
                              ? Colors.white
                              : Colors.transparent,
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
                        textType:
                            value == index ? TextType.emphasis : TextType.text,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
