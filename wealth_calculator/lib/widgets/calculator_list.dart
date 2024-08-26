import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/TempCalculatorBloc/tempBloc.dart';
import 'package:wealth_calculator/bloc/TempCalculatorBloc/tempEvent.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/ItemDialogs.dart';

class TempInventoryListWidget extends StatelessWidget {
  final List<SavedWealths> savedWealths;
  final List<Color> colors;

  TempInventoryListWidget({required this.savedWealths, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: savedWealths.length,
      itemBuilder: (context, index) {
        final wealth = savedWealths[index];
        final color = colors[index];
        return Dismissible(
          key: Key(wealth.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            BlocProvider.of<TempInventoryBloc>(context)
                .add(DeleteWealth(wealth.id));
          },
          child: GestureDetector(
            onTap: () {
              ItemDialogs.showEditItemDialog(
                context,
                MapEntry(wealth, wealth.amount),
                (wealth, amount) {
                  context
                      .read<TempInventoryBloc>()
                      .add(AddOrUpdateWealth(wealth, amount));
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                border: Border.all(color: Colors.black, width: 0.6),
              ),
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wealth.type,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        Row(
                          children: [
                            Text(
                              'Miktar:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                            Text(
                              "  ${wealth.amount}",
                              style: TextStyle(
                                  fontSize: 19.0, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      context.read<TempInventoryBloc>().add(
                            AddOrUpdateWealth(
                              wealth,
                              wealth.amount + 1,
                            ),
                          );
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      if (wealth.amount > 0) {
                        context.read<TempInventoryBloc>().add(
                              AddOrUpdateWealth(
                                wealth,
                                wealth.amount - 1,
                              ),
                            );
                      } else if (wealth.amount == 0) {
                        BlocProvider.of<TempInventoryBloc>(context)
                            .add(DeleteWealth(wealth.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
