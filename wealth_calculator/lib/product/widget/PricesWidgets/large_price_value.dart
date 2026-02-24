import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/utility/padding/product_padding.dart';
import 'package:wealth_calculator/product/utility/padding/product_sizes.dart';

/// A widget that displays a largely price value with a currency symbol.
class LargePriceValue extends StatelessWidget {
  const LargePriceValue({
    required this.price,
    super.key,
  });

  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            price,
            style: TextStyle(
              fontSize: ProductSizes.large + ProductSizes.extraSmall,
              fontWeight: FontWeight.bold,
              color: context.general.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: ProductSizes.extraSmall),
        Padding(
          padding: const ProductPadding.onlyBottomExtraSmall(),
          child: Text(
            LocaleKeys.tl.tr(),
            style: TextStyle(
              fontSize: ProductSizes.small,
              fontWeight: FontWeight.w500,
              color: context.general.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
    ;
  }
}
