import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/utility/padding/product_sizes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isPortfolioActive;
  final Function(int) onTabSelected;
  final VoidCallback onPortfolioSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.isPortfolioActive,
    required this.onTabSelected,
    required this.onPortfolioSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: 85 + MediaQuery.of(context).padding.bottom,
      width: size.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Background Shape (Notch)
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size:
                  Size(size.width, 65 + MediaQuery.of(context).padding.bottom),
              painter: BNBCustomPainter(
                color: colorScheme.surface,
                borderColor: colorScheme.primary.withAlpha(80),
              ),
            ),
          ),
          // 2. Navigation Items (Row)
          Container(
            width: size.width,
            height: 65,
            margin:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.monetization_on_outlined,
                    LocaleKeys.gold.tr(), 0, colorScheme),
                _buildNavItem(Icons.currency_exchange, LocaleKeys.currency.tr(),
                    1, colorScheme),
                const SizedBox(width: 85), // Space for FAB
                _buildNavItem(
                    Icons.show_chart, LocaleKeys.stocks.tr(), 2, colorScheme),
                _buildNavItem(Icons.diamond_outlined,
                    LocaleKeys.commodities.tr(), 3, colorScheme),
              ],
            ),
          ),
          // 3. Floating Action Button (Portföy)
          Positioned(
            top: 5, // Slightly down from top of 85 height stack
            child: SizedBox(
              width: 68,
              height: 68,
              child: FloatingActionButton(
                backgroundColor: isPortfolioActive
                    ? colorScheme.primary
                    : colorScheme.surface,
                elevation: ProductSizes.small,
                onPressed: onPortfolioSelected,
                shape: const CircleBorder(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: isPortfolioActive
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocaleKeys.portfolio.tr(),
                      style: TextStyle(
                        color: isPortfolioActive
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, ColorScheme colorScheme) {
    final isSelected = currentIndex == index && !isPortfolioActive;
    final color =
        isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          children: [
            // Top indicator line
            Container(
              height: 3,
              width: 35,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final Color color;
  final Color? borderColor;

  BNBCustomPainter({required this.color, this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..color = borderColor ?? Colors.grey.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    Path path = Path();
    path.moveTo(0, 15); // Start with corner
    path.quadraticBezierTo(0, 0, 15, 0);
    path.lineTo(size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: const Radius.circular(22.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.lineTo(size.width - 15, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 15);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
