part of '../prices_view.dart';

/// A card widget that displays the highlighted "Gram Altın" price at the top
/// of the gold prices section. Receives a [WealthPrice] from the parent and
/// shows the current price, lowest, highest, time and a percentage change
/// indicator (instead of a chart).
class _TopPriceCard extends StatelessWidget {
  const _TopPriceCard({required this.gramGoldPrice});

  final WealthPrice gramGoldPrice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final isNegativeChange = gramGoldPrice.change.startsWith('-');
    final changeColor =
        isNegativeChange ? colorScheme.error : colorScheme.tertiary;
    final changeIcon =
        isNegativeChange ? Icons.trending_down : Icons.trending_up;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay10.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left section: icon, title, price, details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gold icon badge + title
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.gold.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Au',
                        style: TextStyle(
                          color: colorScheme.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gramGoldPrice.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'TL/GR',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // "Current Price" label
                Text(
                  LocaleKeys.currentPrice.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                // Large price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      gramGoldPrice.buyingPrice,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        LocaleKeys.tl.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Lowest / Highest / Time row
                Row(
                  children: [
                    _buildDetailItem(
                      context,
                      LocaleKeys.lowest.tr(),
                      gramGoldPrice.sellingPrice,
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      context,
                      LocaleKeys.highest.tr(),
                      gramGoldPrice.buyingPrice,
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      context,
                      LocaleKeys.time.tr(),
                      gramGoldPrice.time,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right section: change percentage indicator (replaces chart)
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Change icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: changeColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    changeIcon,
                    color: changeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                // Change percentage
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gramGoldPrice.change,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                ),
                // Change amount if available
                if (gramGoldPrice.changeAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    gramGoldPrice.changeAmount!,
                    style: TextStyle(
                      fontSize: 11,
                      color: changeColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    final colorScheme = context.general.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
