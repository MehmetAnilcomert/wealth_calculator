import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_bloc.dart';
import 'package:wealth_calculator/bloc/InvoiceBloc/invoice_event.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';

class InvoiceAddUpdateScreen extends StatefulWidget {
  final Invoice? fatura;

  InvoiceAddUpdateScreen({this.fatura});

  @override
  _InvoiceAddUpdateScreenState createState() => _InvoiceAddUpdateScreenState();
}

class _InvoiceAddUpdateScreenState extends State<InvoiceAddUpdateScreen> {
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

  Future<void> _faturaEkleGuncelle(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final dateFormat = DateFormat('dd.MM.yyyy');
      final selectedDate = dateFormat.parse(_tarihController.text);
      final fatura = Invoice(
        id: widget.fatura?.id,
        tarih: selectedDate,
        tutar: double.parse(_tutarController.text),
        aciklama: _aciklamaController.text,
        onemSeviyesi: _secilenOnemSeviyesi,
        odendiMi: _odendiMi,
      );

      if (widget.fatura == null) {
        BlocProvider.of<InvoiceBloc>(context).add(AddInvoice(fatura));
      } else {
        BlocProvider.of<InvoiceBloc>(context).add(UpdateInvoice(fatura));
      }
      Navigator.pop(context, true);
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
      backgroundColor: Color.fromARGB(255, 177, 210, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 177, 210, 226),
        title: Text(widget.fatura == null ? 'Fatura Ekle' : 'Fatura Güncelle'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Lottie.asset("images/bill.json"),
            Padding(
              padding: const EdgeInsets.all(13.0),
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
                      items:
                          OnemSeviyesi.values.map((OnemSeviyesi onemSeviyesi) {
                        return DropdownMenuItem<OnemSeviyesi>(
                          value: onemSeviyesi,
                          child: Text(onemSeviyesi
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase()),
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
                      onPressed: () => _faturaEkleGuncelle(context),
                      child: Text(widget.fatura == null
                          ? 'Faturayı Kaydet'
                          : 'Faturayı Güncelle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
