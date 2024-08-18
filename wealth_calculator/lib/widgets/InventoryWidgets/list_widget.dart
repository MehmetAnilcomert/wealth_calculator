import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/bloc/Bloc/InventoryBloc/InventoryBloc.dart';
import 'package:wealth_calculator/bloc/Bloc/InventoryBloc/InventoryEvent.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/widgets/InventoryWidgets/ItemDialogs.dart';

class InventorySliverList extends StatelessWidget {
  final List<SavedWealths> savedWealths;

  InventorySliverList({required this.savedWealths});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: savedWealths.length,
      itemBuilder: (context, index) {
        final wealth = savedWealths[index];
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
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                border: Border.all(color: Colors.black, width: 0.6),
              ),
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
