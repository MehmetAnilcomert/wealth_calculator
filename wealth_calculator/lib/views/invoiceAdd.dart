import 'package:flutter/material.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

class AddInvoiceScreen extends StatefulWidget {
  final InvoiceModal? invoice;

  AddInvoiceScreen({this.invoice});

  @override
  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late InvoiceModal _invoice;

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _invoice = widget.invoice!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice == null ? 'Fatura Ekle' : 'Fatura Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _invoice.name,
                decoration: InputDecoration(labelText: 'Fatura Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen fatura adını girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  _invoice.name = value;
                },
              ),
              TextFormField(
                initialValue:
                    _invoice.amount != null ? _invoice.amount.toString() : '',
                decoration: InputDecoration(labelText: 'Tutar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen tutarı girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  _invoice.amount = int.tryParse(value!);
                },
              ),
              TextFormField(
                initialValue: _invoice.explanation,
                decoration: InputDecoration(labelText: 'Açıklama'),
                onSaved: (value) {
                  _invoice.explanation = value;
                },
              ),
              ListTile(
                title: Text(
                    "Başlangıç Tarihi: ${_invoice.startDate?.toLocal().toString().split(' ')[0] ?? 'Tarih Seçin'}"),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _invoice.startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    setState(() {
                      _invoice.startDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text(
                    "Son Ödeme Tarihi: ${_invoice.dueDate?.toLocal().toString().split(' ')[0] ?? 'Tarih Seçin'}"),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _invoice.dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    setState(() {
                      _invoice.dueDate = picked;
                    });
                  }
                },
              ),
              DropdownButtonFormField<ImportanceLevel>(
                value: _invoice.priority,
                decoration: InputDecoration(labelText: 'Önem Sırası'),
                items: ImportanceLevel.values.map((ImportanceLevel level) {
                  return DropdownMenuItem<ImportanceLevel>(
                    value: level,
                    child: Text(_importanceLevelToString(level)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _invoice.priority = newValue;
                  });
                },
                onSaved: (value) {
                  _invoice.priority = value;
                },
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _invoice.isPaid ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        _invoice.isPaid = value;
                      });
                    },
                  ),
                  Text('Ödendi'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Burada _invoice nesnesini kaydetmek veya güncellemek için bir yöntem çağır
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _importanceLevelToString(ImportanceLevel level) {
    switch (level) {
      case ImportanceLevel.highPriority:
        return 'Yüksek Önemde';
      case ImportanceLevel.mediumPriority:
        return 'Orta Önemde';
      case ImportanceLevel.lowPriority:
        return 'Düşük Önemde';
      default:
        return '';
    }
  }
}
