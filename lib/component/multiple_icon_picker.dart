import 'package:flutter/material.dart';
import 'package:truthordare/component/text.dart';
import 'package:truthordare/struct/client.dart';

class MultipleIconPickerData {
  final String icon;
  final String text;

  MultipleIconPickerData({required this.icon, required this.text});
}

class MultipleIconPicker extends StatelessWidget {
  const MultipleIconPicker({
    super.key,
    required this.client,
    required this.data,
    required this.onPressed,
    required this.value,
  });

  final Client client;
  final List<MultipleIconPickerData> data;
  final Function(List<int>) onPressed;
  final List<int> value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 105, // Ensure consistent height
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
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
                    if (value.contains(index)) {
                      value.remove(index);
                    } else {
                      value.add(index);
                    }
                    onPressed(List.from(
                        value)); // Pass a copy to avoid mutation issues
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
                          color: value.contains(index)
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
                        textType: value.contains(index)
                            ? TextType.emphasis
                            : TextType.text,
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
