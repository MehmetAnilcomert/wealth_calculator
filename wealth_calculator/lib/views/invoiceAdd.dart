import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

class FaturaEklemeGuncellemeEkrani extends StatefulWidget {
  final Fatura? fatura;

  FaturaEklemeGuncellemeEkrani({this.fatura});

  @override
  _FaturaEklemeGuncellemeEkraniState createState() =>
      _FaturaEklemeGuncellemeEkraniState();
}

class _FaturaEklemeGuncellemeEkraniState
    extends State<FaturaEklemeGuncellemeEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _tarihController = TextEditingController();
  final _tutarController = TextEditingController();
  final _aciklamaController = TextEditingController();
  OnemSeviyesi _secilenOnemSeviyesi = OnemSeviyesi.orta;
  bool _odendiMi = false;

  @override
  void initState() {
    super.initState();
    if (widget.fatura != null) {
      _tarihController.text =
          DateFormat('dd.MM.yyyy').format(widget.fatura!.tarih);
      _tutarController.text = widget.fatura!.tutar.toString();
      _aciklamaController.text = widget.fatura!.aciklama;
      _secilenOnemSeviyesi = widget.fatura!.onemSeviyesi;
      _odendiMi = widget.fatura!.odendiMi;
    }
  }

  Future<void> _faturaEkleGuncelle() async {
    final Database db = await openDatabase('my_database.db');
    if (_formKey.currentState!.validate()) {
      final dateFormat = DateFormat('dd.MM.yyyy');
      final selectedDate = dateFormat.parse(_tarihController.text);
      final fatura = Fatura(
        id: widget.fatura?.id,
        tarih: selectedDate,
        tutar: double.parse(_tutarController.text),
        aciklama: _aciklamaController.text,
        onemSeviyesi: _secilenOnemSeviyesi,
        odendiMi: _odendiMi,
      );

      try {
        if (widget.fatura == null) {
          await db.insert('fatura', fatura.toMap());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fatura başarıyla eklendi.')),
          );
        } else {
          await db.update(
            'fatura',
            fatura.toMap(),
            where: 'id = ?',
            whereArgs: [fatura.id],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fatura başarıyla güncellendi.')),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        print('Hata oluştu: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İşlem başarısız: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.fatura?.tarih ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tarihController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fatura == null ? 'Fatura Ekle' : 'Fatura Güncelle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _tarihController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Son Ödeme Tarihi',
                ),
              ),
              TextFormField(
                controller: _tutarController,
                decoration: InputDecoration(labelText: 'Tutar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen tutarı giriniz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _aciklamaController,
                decoration: InputDecoration(labelText: 'Açıklama'),
              ),
              DropdownButtonFormField<OnemSeviyesi>(
                value: _secilenOnemSeviyesi,
                onChanged: (OnemSeviyesi? newValue) {
                  setState(() {
                    _secilenOnemSeviyesi = newValue!;
                  });
                },
                items: OnemSeviyesi.values.map((OnemSeviyesi onemSeviyesi) {
                  return DropdownMenuItem<OnemSeviyesi>(
                    value: onemSeviyesi,
                    child: Text(
                        onemSeviyesi.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Önem Seviyesi'),
              ),
              SwitchListTile(
                title: Text('Ödendi Mi?'),
                value: _odendiMi,
                onChanged: (bool value) {
                  setState(() {
                    _odendiMi = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _faturaEkleGuncelle,
                child: Text(widget.fatura == null
                    ? 'Faturayı Kaydet'
                    : 'Faturayı Güncelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey, // Arka plan rengi
                  foregroundColor: Colors.white, // Buton metni rengi
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
