import 'package:flutter/material.dart';

Widget buildTab(IconData icon, String label, BuildContext context) {
  return Tab(
    icon: Icon(icon, size: 24),
    child: Text(
      label,
      style: TextTheme.of(context)
              .labelSmall
              ?.copyWith(fontSize: 10, fontWeight: FontWeight.w500) ??
          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
  );
}
