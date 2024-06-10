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
          title: Text(
            entry.key.type,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Miktar: ${entry.value}',
            style: TextStyle(color: Colors.white),
          ),
          tileColor: Colors.blueGrey,
          onTap: () => onEdit(entry),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.black87,
            ),
            iconSize: 35,
            onPressed: () => onDelete(entry.key.id),
          ),
        );
      }).toList(),
    );
  }
}
