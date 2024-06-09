import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/Wealths.dart';
import 'package:wealth_calculator/services/Wealthsdao.dart';

class WealthList extends StatelessWidget {
  final Map<SavedWealths, int> selectedItems;
  final Function onDelete;
  final Function onEdit;

  WealthList({
    required this.selectedItems,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: selectedItems.entries.map((entry) {
        return ListTile(
          title: Text(entry.key.type),
          subtitle: Text('Miktar: ${entry.value}'),
          tileColor: const Color.fromARGB(255, 35, 143, 41),
          onTap: () => onEdit(entry),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            iconSize: 35,
            onPressed: () => onDelete(entry.key.id),
          ),
        );
      }).toList(),
    );
  }
}
