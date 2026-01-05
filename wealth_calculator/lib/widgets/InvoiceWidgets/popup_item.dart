import 'package:flutter/material.dart';

PopupMenuItem<String> buildPopupMenuItem(
    String value, String text, IconData icon) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 20, color: const Color.fromARGB(255, 106, 196, 255)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
