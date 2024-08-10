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
        return Color.fromARGB(255, 165, 38, 9);
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
      appBar:
          AppBar(title: Text('Faturalar'), backgroundColor: Colors.blueGrey),
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
                decoration: BoxDecoration(
                  color: fatura.odendiMi
                      ? Colors.green
                      : _getOnemSeviyesiRenk(fatura.onemSeviyesi),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.6,
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fatura.aciklama,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          Row(
                            children: [
                              Text(
                                'Tutar:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                              Text(
                                "  ${fatura.tutar} TL",
                                style: TextStyle(fontSize: 19.0),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Son Ödeme Tarihi:",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "  ${DateFormat('dd.MM.yyyy').format(fatura.tarih)}",
                                style: TextStyle(fontSize: 17.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      fatura.odendiMi ? Icons.check : Icons.warning_rounded,
                      color: fatura.odendiMi ? Colors.black : Colors.red,
                      size: 33,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.black, size: 30),
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
        backgroundColor: Colors.blueGrey,
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
