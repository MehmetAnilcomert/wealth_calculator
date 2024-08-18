import 'package:flutter/material.dart';
import 'package:wealth_calculator/views/inventory_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InventoryScreen(),
                ),
              );
            },
            child: Text("Varlık Hesap Makinesi"))
      ],
    );
  }
}
