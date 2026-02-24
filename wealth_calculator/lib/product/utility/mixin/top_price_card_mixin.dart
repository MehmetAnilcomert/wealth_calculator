import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/prices.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';

mixin TopPriceCardMixin on State<TopPriceCard> {
  late final AnimationController _pulseController;
  late final AnimationController _bounceController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _arrowSlide;

  void initAnimations(TickerProvider vsync) {
    // Pulsing glow ring — repeats forever
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: vsync,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bounce-in for the badge + arrow slide
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
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

  void disposeAnimations() {
    _pulseController.dispose();
    _bounceController.dispose();
  }

  /// Animated change indicator with:
  /// - Pulsing glow ring around the circle
  /// - Bouncing arrow icon
  /// - Scale-in percentage badge
  Widget buildAnimatedChangeIndicator(Color changeColor, IconData changeIcon) {
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

  Widget buildDetailItem(BuildContext context, String label, String value) {
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
