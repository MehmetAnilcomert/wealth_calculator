import 'package:flutter/material.dart';

class TextWithImage extends StatelessWidget {
  final String text;
  final String imageUrl;
  final double imageSize;

  const TextWithImage({
    Key? key,
    required this.text,
    required this.imageUrl,
    this.imageSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        SizedBox(
          width: 5,
          child: Image.asset(
            imageUrl,
          ),
        ),
      ],
    );
  }
}
