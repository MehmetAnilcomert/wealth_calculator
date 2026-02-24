part of '../prices_view.dart';

/// A reusable card widget that displays a highlighted price at the top of each
/// tab section. Accepts dynamic data so it can show Gram Altın, USD, BIST 100,
/// Gümüş, etc. depending on the active tab.
///
/// Includes animated change indicator with pulsing glow and bounce effects.
class TopPriceCard extends StatefulWidget {
  const TopPriceCard({
    required this.price,
    required this.iconLabel,
    required this.iconColor,
  });

  final WealthPrice price;
  final String iconLabel;
  final Color iconColor;

  @override
  State<TopPriceCard> createState() => _TopPriceCardState();
}

class _TopPriceCardState extends State<TopPriceCard>
    with TickerProviderStateMixin, TopPriceCardMixin {
  @override
  void initState() {
    super.initState();
    initAnimations(this);
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final isNegativeChange = widget.price.change.startsWith('-');
    final changeColor =
        isNegativeChange ? colorScheme.error : colorScheme.tertiary;
    final changeIcon =
        isNegativeChange ? Icons.trending_down : Icons.trending_up;
    final price = widget.price.currentPrice ?? widget.price.buyingPrice;

    return Container(
      padding: const ProductPadding.allMedium(),
      decoration: _BoxDecoration(colorScheme),
      child: Row(
        children: [
          // Left section: icon, title, price, details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge + title section
                Row(
                  children: [
                    IconBadge(
                        iconLabel: widget.iconLabel,
                        iconColor: widget.iconColor),
                    const SizedBox(width: ProductSizes.small),
                    _expandedTitleText(colorScheme),
                  ],
                ),
                const SizedBox(
                    height: ProductSizes.small + ProductSizes.extraSmall),

                // "Current Price" label
                _currentPrice(colorScheme),
                const SizedBox(height: ProductSizes.extraSmall),

                // Large price value
                LargePriceValue(price: price),
                const SizedBox(
                    height: ProductSizes.small + ProductSizes.extraSmall),

                // Lowest / Highest / Time row
                _bottomRow(context),
              ],
            ),
          ),
          // Right section: animated change indicator
          Expanded(
            flex: 1,
            child: buildAnimatedChangeIndicator(changeColor, changeIcon),
          ),
        ],
      ),
    );
  }

  /// Returns a [BoxDecoration] widget for the card's decoration.
  BoxDecoration _BoxDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: colorScheme.blackOverlay10.withAlpha(20),
          blurRadius: ProductSizes.medium,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Returns a [Row] widget containing the lowest, highest, and time details.
  Row _bottomRow(BuildContext context) {
    return Row(
      children: [
        buildDetailItem(
          context,
          LocaleKeys.lowest.tr(),
          widget.price.sellingPrice,
        ),
        const SizedBox(width: ProductSizes.medium),
        buildDetailItem(
          context,
          LocaleKeys.highest.tr(),
          widget.price.buyingPrice,
        ),
        const SizedBox(width: ProductSizes.medium),
        buildDetailItem(
          context,
          LocaleKeys.time.tr(),
          widget.price.time,
        ),
      ],
    );
  }

  /// Returns an [Expanded] widget containing the title text to show price``s title.
  Expanded _expandedTitleText(ColorScheme colorScheme) {
    return Expanded(
      child: Text(
        widget.price.title,
        style: TextStyle(
          fontSize: ProductSizes.medium,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Returns a [Text] widget for the "Current Price" label.
  Text _currentPrice(ColorScheme colorScheme) {
    return Text(
      LocaleKeys.currentPrice.tr(),
      style: TextStyle(
        fontSize: ProductSizes.small + ProductSizes.extraSmall,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
