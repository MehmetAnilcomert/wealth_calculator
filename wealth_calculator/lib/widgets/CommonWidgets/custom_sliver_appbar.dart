import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget flexibleSpaceBackground;
  final VoidCallback onAddPressed; // Doğrudan çağırılabilecek bir fonksiyon
  final Object bloc;

  const CustomSliverAppBar({
    super.key,
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
    );
  }
}
