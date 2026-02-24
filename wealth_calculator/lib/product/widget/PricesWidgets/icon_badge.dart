import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/utility/padding/product_sizes.dart';

/// A widget that displays an icon badge with a label and color.
class IconBadge extends StatelessWidget {
  const IconBadge({
    required this.iconLabel,
    required this.iconColor,
    super.key,
  });

  final String iconLabel;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ProductSizes.large,
      height: ProductSizes.large,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        iconLabel,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
          fontSize:
              iconLabel.length > 2 ? ProductSizes.small : ProductSizes.medium,
        ),
      ),
    );
  }
}
