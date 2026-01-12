import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';

final class CustomNavigationButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget targetScreen;
  final Color? iconColor;

  const CustomNavigationButton({
    super.key,
    required this.text,
    required this.icon,
    required this.targetScreen,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final stylishText = TextStyle(
      fontSize: 20.0,
      color: colorScheme.onSurface,
      letterSpacing: 0.4,
      wordSpacing: 1.0,
      fontFamily: 'Arial',
    );
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
        side: BorderSide(color: colorScheme.outline),
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
              color: iconColor ?? colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
