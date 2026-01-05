import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

class WealthList extends StatelessWidget {
  final Map<SavedWealths, int> selectedItems;
  final Function onDelete;
  final Function onEdit;

  const WealthList({
    super.key,
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
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Miktar: ${entry.value}',
            style: const TextStyle(color: Colors.white),
          ),
          tileColor: Colors.blueGrey,
          onTap: () => onEdit(entry),
          trailing: IconButton(
            icon: const Icon(
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
