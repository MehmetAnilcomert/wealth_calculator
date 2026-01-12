import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_event.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';
import 'package:wealth_calculator/product/theme/custom_colors.dart';
import 'package:wealth_calculator/product/widget/InventoryWidgets/item_dialogs.dart';
import 'package:wealth_calculator/product/utility/wealth_amount_utils.dart';

class CalculatorListWidget extends StatelessWidget {
  final List<SavedWealths> savedWealths;
  final List<Color> colors;

  const CalculatorListWidget({
    super.key,
    required this.savedWealths,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.general.colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedWealths.length,
      itemBuilder: (context, index) {
        final wealth = savedWealths[index];
        final color = colors[index];

        return Dismissible(
          key: Key(wealth.id.toString()),
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.deleteBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete_outline,
                color: colorScheme.onError, size: 28),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context
                .read<CalculatorBloc>()
                .add(DeleteCalculatorWealth(wealth.id));
          },
          child: GestureDetector(
            onTap: () {
              ItemDialogs.showEditItemDialog(
                context,
                MapEntry(wealth, wealth.amount),
                (wealth, amount) {
                  context
                      .read<CalculatorBloc>()
                      .add(AddOrUpdateCalculatorWealth(wealth, amount));
                },
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.whiteOverlay10,
                    colorScheme.whiteOverlay10.withAlpha(13),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: colorScheme.whiteOverlay10,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withAlpha(75),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wealth.type,
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${LocaleKeys.amount_inventory.tr()}: ${wealth.amount}',
                                style: TextStyle(
                                  color: colorScheme.whiteOverlay80,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildControlButton(
                              context,
                              Icons.remove,
                              () {
                                final newAmount = WealthAmountUtils.calculateDecrementedAmount(wealth.amount);
                                
                                if (newAmount != null) {
                                  context.read<CalculatorBloc>().add(
                                        AddOrUpdateCalculatorWealth(wealth, newAmount),
                                      );
                                }
                                // Calculator'da 0 olunca silmiyoruz, sadece görüntülemeye devam
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildControlButton(
                              context,
                              Icons.add,
                              () {
                                final newAmount = WealthAmountUtils.incrementAmount(wealth.amount);
                                context.read<CalculatorBloc>().add(
                                      AddOrUpdateCalculatorWealth(wealth, newAmount),
                                    );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton(
      BuildContext context, IconData icon, VoidCallback onPressed) {
    final colorScheme = context.general.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.whiteOverlay10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: colorScheme.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
