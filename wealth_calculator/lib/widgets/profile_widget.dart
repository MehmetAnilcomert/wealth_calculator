import 'package:flutter/material.dart';

class CustomNavigationButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget targetScreen;
  final Color? iconColor;

  CustomNavigationButton({
    required this.text,
    required this.icon,
    required this.targetScreen,
    this.iconColor,
  });

  final TextStyle stylishText = TextStyle(
    fontSize: 20.0,
    color: Colors.black,
    letterSpacing: 0.4,
    wordSpacing: 1.0,
    fontFamily: 'Arial', // Font ailesi
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(color: Colors.black),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => targetScreen,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: stylishText),
            Icon(
              icon,
              color: iconColor ?? Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
