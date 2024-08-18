import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget flexibleSpaceBackground;
  final VoidCallback onAddPressed; // Doğrudan çağırılabilecek bir fonksiyon
  final Object bloc;

  CustomSliverAppBar({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.flexibleSpaceBackground,
    required this.onAddPressed,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: flexibleSpaceBackground,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 5),
          child: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 59, 150, 223),
            onPressed: onAddPressed,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
