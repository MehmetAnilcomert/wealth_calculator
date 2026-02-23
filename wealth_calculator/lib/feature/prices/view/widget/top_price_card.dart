part of '../prices_view.dart';

/// A reusable card widget that displays a highlighted price at the top of each
/// tab section. Accepts dynamic data so it can show Gram Altın, USD, BIST 100,
/// Gümüş, etc. depending on the active tab.
///
/// Includes animated change indicator with pulsing glow and bounce effects.
class _TopPriceCard extends StatefulWidget {
  const _TopPriceCard({
    required this.price,
    required this.iconLabel,
    required this.iconColor,
  });

  final WealthPrice price;
  final String iconLabel;
  final Color iconColor;

  @override
  State<_TopPriceCard> createState() => _TopPriceCardState();
}

class _TopPriceCardState extends State<_TopPriceCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _bounceController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _arrowSlide;

  @override
  void initState() {
    super.initState();

    // Pulsing glow ring — repeats forever
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bounce-in for the badge + arrow slide
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _arrowSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
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

    return Container(
      padding: const ProductPadding.allMedium(),
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
                // Icon badge + title
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.iconLabel,
                        style: TextStyle(
                          color: widget.iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.iconLabel.length > 2 ? 10 : 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.price.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                // Large price value
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.price.currentPrice ?? widget.price.buyingPrice,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      widget.price.sellingPrice,
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      context,
                      LocaleKeys.highest.tr(),
                      widget.price.buyingPrice,
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      context,
                      LocaleKeys.time.tr(),
                      widget.price.time,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right section: animated change indicator
          Expanded(
            flex: 1,
            child: _buildAnimatedChangeIndicator(changeColor, changeIcon),
          ),
        ],
      ),
    );
  }

  /// Animated change indicator with:
  /// - Pulsing glow ring around the circle
  /// - Bouncing arrow icon
  /// - Scale-in percentage badge
  Widget _buildAnimatedChangeIndicator(Color changeColor, IconData changeIcon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing glow ring + trend icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: changeColor
                        .withAlpha((40 * _pulseAnimation.value).toInt()),
                    blurRadius: 12 + (8 * _pulseAnimation.value),
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: changeColor.withAlpha(30),
                  border: Border.all(
                    color: changeColor.withAlpha(
                      (60 * _pulseAnimation.value).toInt() + 20,
                    ),
                    width: 1.5,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _arrowSlide,
                  builder: (context, child) {
                    final isNeg = widget.price.change.startsWith('-');
                    final slideOffset = isNeg
                        ? Offset(0, 0.15 * (1 - _arrowSlide.value))
                        : Offset(0, -0.15 * (1 - _arrowSlide.value));
                    return FractionalTranslation(
                      translation: slideOffset,
                      child: child,
                    );
                  },
                  child: Icon(
                    changeIcon,
                    color: changeColor,
                    size: 28,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        // Bounce-in percentage badge
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: Opacity(
                opacity: _bounceAnimation.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  changeColor.withAlpha(35),
                  changeColor.withAlpha(20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: changeColor.withAlpha(50),
                width: 0.5,
              ),
            ),
            child: Text(
              widget.price.change,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: changeColor,
              ),
            ),
          ),
        ),
        // Change amount if available
        if (widget.price.changeAmount != null) ...[
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _bounceAnimation.value.clamp(0.0, 1.0),
                child: child,
              );
            },
            child: Text(
              widget.price.changeAmount!,
              style: TextStyle(
                fontSize: 11,
                color: changeColor,
              ),
            ),
          ),
        ],
      ],
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
