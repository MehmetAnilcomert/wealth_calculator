import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_bloc.dart';
import 'package:wealth_calculator/feature/invoice/viewmodel/invoice_event.dart';
import 'package:wealth_calculator/feature/invoice/model/invoice_model.dart';
import 'package:wealth_calculator/product/service/notification_service.dart';

class InvoiceAddingView extends StatefulWidget {
  final Invoice? fatura;

  const InvoiceAddingView({this.fatura, super.key});

  @override
  _InvoiceAddingViewState createState() => _InvoiceAddingViewState();
}

class _InvoiceAddingViewState extends State<InvoiceAddingView> {
  final _formKey = GlobalKey<FormState>();
  final _tarihController = TextEditingController();
  final _tutarController = TextEditingController();
  final _aciklamaController = TextEditingController();
  OnemSeviyesi _secilenOnemSeviyesi = OnemSeviyesi.orta;
  bool _odendiMi = false;
  bool _isNotificationEnabled = false;

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
      _isNotificationEnabled = widget.fatura!.isNotificationEnabled;
      if (widget.fatura!.tarih.isBefore(DateTime.now()) || _odendiMi) {
        _isNotificationEnabled = false;
      }
    } else {
      _tarihController.text = DateFormat('dd.MM.yyyy').format(DateTime.now());
    }
  }

  Future<void> _faturaEkleGuncelle(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final dateFormat = DateFormat('dd.MM.yyyy');
      DateTime selectedDate;

      try {
        selectedDate = dateFormat.parse(_tarihController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Tarih formatı hatalı. Lütfen doğru formatta bir tarih girin.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final fatura = Invoice(
        id: widget.fatura?.id,
        tarih: selectedDate,
        tutar: double.parse(_tutarController.text),
        aciklama: _aciklamaController.text,
        onemSeviyesi: _secilenOnemSeviyesi,
        odendiMi: _odendiMi,
        isNotificationEnabled: _isNotificationEnabled,
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
      initialDate: _tarihController.text.isNotEmpty
          ? DateFormat('dd.MM.yyyy').parse(_tarihController.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tarihController.text = DateFormat('dd.MM.yyyy').format(picked);
        if (picked.isBefore(DateTime.now())) {
          _isNotificationEnabled = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF34495E),
        elevation: 0,
        title: Text(
          widget.fatura == null ? 'Fatura Ekle' : 'Fatura Güncelle',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Lottie.asset(
                "images/bill.json",
                fit: BoxFit.contain,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _tarihController,
                        label: 'Son Ödeme Tarihi',
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _tutarController,
                        label: 'Tutar',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen tutarı giriniz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _aciklamaController,
                        label: 'Açıklama',
                        icon: Icons.description,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(),
                      const SizedBox(height: 20),
                      _buildSwitchTile(
                        title: 'Ödendi Mi?',
                        value: _odendiMi,
                        onChanged: (bool value) {
                          setState(() {
                            _odendiMi = value;
                            if (_odendiMi) {
                              _isNotificationEnabled = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Fatura ödendi, bildirim gönderimi kapalı.',
                                  ),
                                  backgroundColor: Color(0xFF34495E),
                                ),
                              );
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildSwitchTile(
                        title: 'Hatırlatma bildirimi gönderilsin mi?',
                        value: _isNotificationEnabled,
                        onChanged: _odendiMi ||
                                DateFormat('dd.MM.yyyy')
                                    .parse(_tarihController.text)
                                    .isBefore(DateTime.now())
                            ? null
                            : (bool value) async {
                                setState(() {
                                  _isNotificationEnabled = value;
                                });

                                if (_isNotificationEnabled) {
                                  final notificationId = widget.fatura?.id ?? 0;
                                  DateTime scheduledDate =
                                      DateFormat('dd.MM.yyyy')
                                          .parse(_tarihController.text);
                                  scheduledDate = DateTime(
                                      scheduledDate.year,
                                      scheduledDate.month,
                                      scheduledDate.day,
                                      9,
                                      30);
                                  try {
                                    await NotificationService
                                        .scheduleNotification(
                                      context,
                                      notificationId,
                                      "Hatırlatma!",
                                      "${_tutarController.text} TL tutarında olan ${_aciklamaController.text} faturanızı ödemiş miydiniz?",
                                      scheduledDate,
                                    );
                                  } catch (error) {
                                    setState(() {
                                      _isNotificationEnabled = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Bildirim planlanırken hata oluştu: $error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  try {
                                    final notificationId =
                                        widget.fatura?.id ?? 0;
                                    await NotificationService
                                        .cancelNotification(notificationId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Bildirim iptal edildi.')),
                                    );
                                  } catch (error) {
                                    setState(() {
                                      _isNotificationEnabled = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Bildirim iptal edilirken hata oluştu: $error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _faturaEkleGuncelle(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            widget.fatura == null
                                ? 'Faturayı Kaydet'
                                : 'Faturayı Güncelle',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3498DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
        ),
      ),
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<OnemSeviyesi>(
      initialValue: _secilenOnemSeviyesi,
      onChanged: (OnemSeviyesi? newValue) {
        setState(() {
          _secilenOnemSeviyesi = newValue!;
        });
      },
      items: OnemSeviyesi.values.map((OnemSeviyesi onemSeviyesi) {
        IconData icon;
        Color color;
        switch (onemSeviyesi) {
          case OnemSeviyesi.dusuk:
            icon = Icons.arrow_downward;
            color = Colors.green;
            break;
          case OnemSeviyesi.orta:
            icon = Icons.remove;
            color = Colors.orange;
            break;
          case OnemSeviyesi.yuksek:
            icon = Icons.arrow_upward;
            color = Colors.red;
            break;
        }
        return DropdownMenuItem<OnemSeviyesi>(
          value: onemSeviyesi,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                onemSeviyesi.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Önem Seviyesi',
        prefixIcon: const Icon(Icons.priority_high, color: Color(0xFF3498DB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3498DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3498DB)),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3498DB)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF3498DB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
