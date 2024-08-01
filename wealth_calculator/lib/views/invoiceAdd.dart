import 'package:flutter/material.dart';

class AddInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic>? invoice;

  AddInvoiceScreen({this.invoice});

  @override
  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _invoiceDate = DateTime.now();
  double _amount = 0.0;
  String _category = 'Elektrik';
  String _description = '';
  bool _isPaid = false;
  String _priority = 'Orta Önemde';

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _amount = widget.invoice!['amount'];
      _category = widget.invoice!['category'];
      _description = widget.invoice!['description'] ?? '';
      _isPaid = widget.invoice!['is_paid'];
      _priority = widget.invoice!['priority'];
      _invoiceDate = widget.invoice!['invoice_date'] ??
          DateTime.now(); // Eğer fatura tarihi varsa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.invoice == null ? 'Fatura Ekle' : 'Fatura Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _amount.toString(),
                decoration: InputDecoration(labelText: 'Tutar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen tutarı girin';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Açıklama'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              ListTile(
                title: Text(
                    "Fatura Tarihi: ${_invoiceDate.toLocal()}".split(' ')[0]),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _invoiceDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null && picked != _invoiceDate) {
                    setState(() {
                      _invoiceDate = picked;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Kategori'),
                items:
                    <String>['Elektrik', 'Su', 'Internet'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
                onSaved: (value) {
                  _category = value!;
                },
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: InputDecoration(labelText: 'Önem Sırası'),
                items: <String>['Yüksek Önemde', 'Orta Önemde', 'Düşük Önemde']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                onSaved: (value) {
                  _priority = value!;
                },
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _isPaid,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPaid = value!;
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
                    // Verileri kaydetmek veya güncellemek için bir yöntem çağır
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
}
