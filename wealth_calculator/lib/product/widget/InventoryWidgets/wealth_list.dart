import 'package:flutter/material.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';
import 'package:wealth_calculator/product/utility/extensions/context_extension.dart';

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
    final colorScheme = context.general.colorScheme;
    return ListView(
      children: selectedItems.entries.map((entry) {
        return ListTile(
          title: Text(
            entry.key.type,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            'Miktar: ${entry.value}',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          tileColor: colorScheme.surfaceContainerHigh,
          onTap: () => onEdit(entry),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              color: colorScheme.error,
            ),
            iconSize: 35,
            onPressed: () => onDelete(entry.key.id),
          ),
        );
      }).toList(),
    );
  }
}
