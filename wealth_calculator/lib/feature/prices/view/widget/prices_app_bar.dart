part of '../prices_view.dart';

/// Custom AppBar header for the Prices screen.
///
/// Renders a gradient blue header with rounded bottom corners, the app logo,
/// tab title, subtitle, drawer menu button, and an overlapping search bar
/// at the bottom edge — matching the reference design.
class _PricesAppBar extends StatelessWidget {
  const _PricesAppBar({
    required this.currentTabIndex,
    required this.onSearchChanged,
    required this.showSearchBar,
  });

  /// Current tab index to determine the title.
  final int currentTabIndex;

  /// Callback when the search query changes.
  final ValueChanged<String> onSearchChanged;

  /// Whether to show the search bar (hidden on Portfolio tab).
  final bool showSearchBar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    // Total header height: status bar + toolbar + optional search overlap
    final headerHeight = topPadding + kToolbarHeight + (showSearchBar ? 28 : 0);

    return SizedBox(
      height: headerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blue gradient background with rounded bottom
          Container(
            height: headerHeight - (showSearchBar ? 20 : 0),
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
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // App logo
                    _buildLogo(colorScheme),
                    const SizedBox(width: 12),
                    // Title + subtitle
                    Expanded(child: _buildTitle(colorScheme)),
                    // Drawer menu / loading indicator
                    _buildMenuButton(context, colorScheme),
                  ],
                ),
              ),
            ),
          ),
          // Overlapping search bar
          if (showSearchBar)
            Positioned(
              left: 24,
              right: 24,
              bottom: 0,
              child: _buildSearchBar(colorScheme),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 40,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          LocaleKeys.marketData.tr(),
          style: TextStyle(
            color: colorScheme.onPrimaryContainer.withAlpha(179),
            fontSize: 12,
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
}
