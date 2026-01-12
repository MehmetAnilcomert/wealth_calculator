import 'package:flutter/material.dart';

PopupMenuItem<String> buildPopupMenuItem(
    String value, String text, IconData icon, BuildContext context) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
