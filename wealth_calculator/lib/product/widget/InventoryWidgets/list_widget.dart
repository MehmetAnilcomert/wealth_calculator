import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_bloc.dart';
import 'package:wealth_calculator/feature/inventory/viewmodel/inventory_event.dart';
import 'package:wealth_calculator/l10n/app_localizations.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/product/widget/InventoryWidgets/ItemDialogs.dart';

class InventoryListWidget extends StatelessWidget {
  final List<SavedWealths> savedWealths;
  final List<Color> colors;

  InventoryListWidget({required this.colors, required this.savedWealths});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: savedWealths.length,
      itemBuilder: (context, index) {
        final wealth = savedWealths[index];
        final color = colors[index];
        return Dismissible(
          key: Key(wealth.id.toString()),
          background: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            BlocProvider.of<InventoryBloc>(context)
                .add(DeleteWealth(wealth.id));
          },
          child: GestureDetector(
            onTap: () {
              ItemDialogs.showEditItemDialog(
                context,
                MapEntry(wealth, wealth.amount),
                (wealth, amount) {
                  context
                      .read<InventoryBloc>()
                      .add(AddOrUpdateWealth(wealth, amount));
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: EdgeInsets.all(16),
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
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wealth.type,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${l10n.amount}: ${wealth.amount}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
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
                                  context.read<InventoryBloc>().add(
                                        AddOrUpdateWealth(
                                            wealth, wealth.amount - 1),
                                      );
                                } else if (wealth.amount == 0) {
                                  BlocProvider.of<InventoryBloc>(context)
                                      .add(DeleteWealth(wealth.id));
                                }
                              },
                            ),
                            SizedBox(width: 8),
                            _buildControlButton(
                              context,
                              Icons.add,
                              () {
                                context.read<InventoryBloc>().add(
                                      AddOrUpdateWealth(
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
          ),
        );
      },
    );
  }

  Widget _buildControlButton(
      BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(8),
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
