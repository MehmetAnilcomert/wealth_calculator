import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/Wealths.dart';

class EditItemDialog extends StatelessWidget {
  final MapEntry<SavedWealths, int> entry;
  final Function onSave;

  EditItemDialog({required this.entry, required this.onSave});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(
      text: entry.value.toString(),
    );

    return AlertDialog(
      title: Text('Miktarı Giriniz'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Miktar'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            int amount = int.tryParse(controller.text) ?? 0;
            onSave(entry.key, amount);
            Navigator.of(context).pop();
          },
          child: Text('Kaydet'),
        ),
      ],
    );
  }
}
