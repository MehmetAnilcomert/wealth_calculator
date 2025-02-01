import 'package:flutter/material.dart';

PopupMenuItem<String> buildPopupMenuItem(
    String value, String text, IconData icon) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 20, color: Color.fromARGB(255, 106, 196, 255)),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
