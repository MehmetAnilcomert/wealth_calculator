import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/prices/model/wealth_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';

class WealthPriceCard extends StatefulWidget {
  final WealthPrice equity;
  final Function(WealthPrice) onLongPress;

  const WealthPriceCard({
    super.key,
    required this.equity,
    required this.onLongPress,
  });

  @override
  _WealthPriceCardState createState() => _WealthPriceCardState();
}

class _WealthPriceCardState extends State<WealthPriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    final isNegativeChange = widget.equity.change.startsWith('-');
    final changeColor =
        isNegativeChange ? colorScheme.error : colorScheme.tertiary;
    final icon = isNegativeChange ? Icons.trending_down : Icons.trending_up;

    return GestureDetector(
      onLongPress: () => widget.onLongPress(widget.equity),
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: changeColor.withAlpha(51),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: changeColor.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.equity.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          _buildChangeIndicator(changeColor, icon),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.equity.type == PriceType.equity ||
                          widget.equity.type == PriceType.commodity)
                        _buildMainPriceRow(LocaleKeys.currentPrice.tr(),
                            widget.equity.currentPrice!)
                      else
                        _buildMainPriceRow(LocaleKeys.currentPrice.tr(),
                            widget.equity.buyingPrice),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: [
                            _buildInfoRow(LocaleKeys.highest.tr(),
                                widget.equity.buyingPrice),
                            _buildInfoRow(LocaleKeys.lowest.tr(),
                                widget.equity.sellingPrice),
                            if (widget.equity.volume != null)
                              _buildInfoRow(LocaleKeys.volume.tr(),
                                  widget.equity.volume!),
                          ],
                        ),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.equity.type == PriceType.commodity || widget.equity.type == PriceType.equity ? LocaleKeys.date.tr() : LocaleKeys.time.tr()}: ${widget.equity.time}',
                        style: TextStyle(
                            fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            widget.equity.change,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPriceRow(String label, String value) {
    final colorScheme = context.general.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = context.general.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

Widget buildEquityPricesTab(
    List<dynamic> equities, Function(WealthPrice) onLongPress) {
  List<Row> rows = [];
  for (var i = 0; i < equities.length; i += 2) {
    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          WealthPriceCard(
            equity: equities[i],
            onLongPress: onLongPress,
          ),
          if (i + 1 < equities.length)
            WealthPriceCard(
              equity: equities[i + 1],
              onLongPress: onLongPress,
            ),
        ],
      ),
    );
  }

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      child: Column(
        children: rows,
      ),
    ),
  );
}
