part of '../prices_view.dart';

/// Custom AppBar header for the Prices screen.
///
/// Renders a tall gradient blue header with rounded bottom corners containing:
/// 1. Toolbar row — app logo, tab title/subtitle, drawer menu button
/// 2. Search bar — pill-shaped, inside the blue area
/// 3. Top price card — stacked below, overlapping the bottom edge
///
/// The card and search bar sit within the blue area, with the card's bottom
/// half protruding below the gradient into the content area.
class _PricesAppBar extends StatelessWidget {
  const _PricesAppBar({
    required this.currentTabIndex,
    required this.onSearchChanged,
    required this.showSearchBar,
    this.highlightedPrice,
    this.iconLabel,
    this.iconColor,
    this.isFromCache = false,
    this.lastUpdatedAt,
  });

  final int currentTabIndex;
  final ValueChanged<String> onSearchChanged;
  final bool showSearchBar;
  final bool isFromCache;
  final DateTime? lastUpdatedAt;

  /// The highlighted price to show in the card. If null, no card is rendered.
  final WealthPrice? highlightedPrice;

  /// Icon badge label for the card (e.g. "Au", "USD").
  final String? iconLabel;

  /// Icon badge color for the card.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final hasCard = highlightedPrice != null && showSearchBar;

    // Blue gradient height — toolbar + search bar area
    // The card will overlap: top half inside gradient, bottom half outside
    final toolbarAndSearchHeight =
        topPadding + kToolbarHeight + 16 + (showSearchBar ? 52 : 0);

    final showBanner = isFromCache && hasCard;
    final bannerHeight = showBanner ? 36.0 : 0.0;
    final cardOverlap = hasCard ? (205.0 + bannerHeight) : 0.0;

    // Total widget height
    final totalHeight = toolbarAndSearchHeight + cardOverlap;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blue gradient background — extends to cover toolbar + search + top of card
          Container(
            height: toolbarAndSearchHeight + (hasCard ? 60 : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.gradientStart,
                  colorScheme.gradientEnd,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
          ),
          // Toolbar row
          Positioned(
            top: topPadding + 4,
            left: const ProductPadding.symmetricHorizontalSmall().left,
            right: const ProductPadding.symmetricHorizontalSmall().right,
            height: kToolbarHeight,
            child: Row(
              children: [
                _buildLogo(colorScheme),
                const SizedBox(width: 12),
                Expanded(child: _buildTitle(colorScheme)),
                _buildMenuButton(context, colorScheme),
              ],
            ),
          ),
          // Search bar
          if (showSearchBar)
            Positioned(
              top: topPadding + kToolbarHeight + 8,
              left: const ProductPadding.symmetricHorizontalNormal().left,
              right: const ProductPadding.symmetricHorizontalNormal().right,
              child: _buildSearchBar(colorScheme),
            ),
          // Top price card — overlapping bottom edge of gradient
          if (hasCard)
            Positioned(
              top: toolbarAndSearchHeight + 4,
              left: const ProductPadding.symmetricHorizontalMedium().left,
              right: const ProductPadding.symmetricHorizontalMedium().right,
              child: Container(
                clipBehavior: showBanner ? Clip.antiAlias : Clip.none,
                decoration: showBanner
                    ? BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Theme.of(context).brightness == Brightness.dark
                            ? Border.all(
                                color: colorScheme.outline.withAlpha(40),
                                width: 1,
                              )
                            : null,
                        boxShadow:
                            Theme.of(context).brightness == Brightness.light
                                ? [
                                    BoxShadow(
                                      color: colorScheme.shadow.withAlpha(20),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                      )
                    : null,
                child: Column(
                  children: [
                    TopPriceCard(
                      price: highlightedPrice!,
                      iconLabel: iconLabel ?? '',
                      iconColor: iconColor ?? colorScheme.primary,
                      isFlatBottom: showBanner,
                    ),
                    if (showBanner) _buildBannerExtension(context, colorScheme),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.whiteOverlay20),
      ),
      child: Assets.images.imgLogoNoBackground.image(
        package: "gen",
      ),
    );
  }

  Widget _buildTitle(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PricesScreenUtils.getAppBarTitle(currentTabIndex),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          LocaleKeys.marketData.tr(),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer.withAlpha(179),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, ColorScheme colorScheme) {
    return BlocBuilder<PricesBloc, PricesState>(
      builder: (context, state) {
        if (state is PricesLoading) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        return IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.whiteOverlay20,
            ),
            child: Icon(Icons.menu, color: colorScheme.onPrimaryContainer),
          ),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        );
      },
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colorScheme.blackOverlay10.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: LocaleKeys.search.tr(),
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBannerExtension(BuildContext context, ColorScheme colorScheme) {
    final lastUpdateStr = lastUpdatedAt != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(lastUpdatedAt!)
        : '--:--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_wifi_off,
              color: colorScheme.onErrorContainer, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              LocaleKeys.offlineWarning.tr(namedArgs: {'time': lastUpdateStr}),
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
