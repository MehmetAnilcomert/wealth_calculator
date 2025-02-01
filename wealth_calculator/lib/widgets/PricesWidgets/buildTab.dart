import 'package:flutter/material.dart';

Widget buildTab(IconData icon, String label) {
  return Tab(
    icon: Icon(icon, size: 24),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12),
    ),
  );
}
