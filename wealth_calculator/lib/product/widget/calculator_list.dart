import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_bloc.dart';
import 'package:wealth_calculator/feature/calculator/viewmodel/calculator_event.dart';
import 'package:wealth_calculator/product/init/language/locale_keys.g.dart';

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
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                const Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context
                .read<CalculatorBloc>()
                .add(DeleteCalculatorWealth(wealth.id));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha(25),
                  Colors.white.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withAlpha(25),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocaleKeys.amount
                                  .tr(args: [wealth.amount.toString()]),
                              style: TextStyle(
                                color: Colors.white.withAlpha(204),
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
                              if (wealth.amount > 0) {
                                context.read<CalculatorBloc>().add(
                                      AddOrUpdateCalculatorWealth(
                                          wealth, wealth.amount - 1),
                                    );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildControlButton(
                            context,
                            Icons.add,
                            () {
                              context.read<CalculatorBloc>().add(
                                    AddOrUpdateCalculatorWealth(
                                        wealth, wealth.amount + 1),
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
        );
      },
    );
  }

  Widget _buildControlButton(
      BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
