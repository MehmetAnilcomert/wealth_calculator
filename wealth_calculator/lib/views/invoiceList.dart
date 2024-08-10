import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/views/invoiceAdd.dart';

class FaturaListesi extends StatefulWidget {
  @override
  _FaturaListesiState createState() => _FaturaListesiState();
}

class _FaturaListesiState extends State<FaturaListesi> {
  List<Fatura> faturalar = [];

  Future<void> _getFaturaListesi() async {
    final db =
        await DbHelper.instance.faturaDatabase; // Fatura veritabanını kullanın
    final List<Map<String, dynamic>> maps = await db.query('fatura');
    setState(() {
      faturalar = List.generate(maps.length, (i) {
        return Fatura.fromMap(maps[i]);
      });
    });
  }

  Future<void> _deleteFatura(int id) async {
    final db =
        await DbHelper.instance.faturaDatabase; // Fatura veritabanını kullanın
    await db.delete(
      'fatura',
      where: 'id = ?',
      whereArgs: [id],
    );
    _getFaturaListesi();
  }

  @override
  void initState() {
    super.initState();
    _getFaturaListesi();
  }

  Color _getOnemSeviyesiRenk(OnemSeviyesi onemSeviyesi) {
    switch (onemSeviyesi) {
      case OnemSeviyesi.yuksek:
        return Color(0xFF9A270D);
      case OnemSeviyesi.orta:
        return Color(0xFFFF7E00);
      case OnemSeviyesi.dusuk:
        return Color(0xFFFFF103);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fatura Listesi'),
      ),
      body: ListView.builder(
        itemCount: faturalar.length,
        itemBuilder: (context, index) {
          final fatura = faturalar[index];
          return Dismissible(
            key: Key(fatura.id.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteFatura(fatura.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${fatura.aciklama} silindi')),
              );
            },
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FaturaEklemeGuncellemeEkrani(fatura: fatura),
                  ),
                ).then((value) {
                  if (value == true) {
                    _getFaturaListesi();
                  }
                });
              },
              child: Container(
                color:
                    _getOnemSeviyesiRenk(fatura.onemSeviyesi).withOpacity(0.2),
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fatura.aciklama,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${fatura.tutar} TL',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy').format(fatura.tarih),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      fatura.odendiMi ? Icons.check : Icons.close,
                      color: fatura.odendiMi ? Colors.green : Colors.red,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.black),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Faturayı Sil'),
                              content: Text(
                                  'Bu faturayı silmek istediğinizden emin misiniz?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('İptal'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Sil'),
                                  onPressed: () {
                                    _deleteFatura(fatura.id!);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FaturaEklemeGuncellemeEkrani()),
          ).then((value) {
            if (value == true) {
              _getFaturaListesi();
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
