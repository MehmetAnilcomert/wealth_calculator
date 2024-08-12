import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wealth_calculator/inventory/TotalPrice.dart';
import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/views/invoiceAdd.dart';

class FaturaListesi extends StatefulWidget {
  @override
  _FaturaListesiState createState() => _FaturaListesiState();
}

class _FaturaListesiState extends State<FaturaListesi> {
  List<Fatura> odememisFaturalar = [];
  List<Fatura> odenmisFaturalar = [];

  Future<void> _getFaturaListesi() async {
    final db = await DbHelper.instance.faturaDatabase;
    final List<Map<String, dynamic>> maps = await db.query('fatura');
    setState(() {
      odememisFaturalar = [];
      odenmisFaturalar = [];
      for (var map in maps) {
        Fatura fatura = Fatura.fromMap(map);
        if (fatura.odendiMi) {
          odenmisFaturalar.add(fatura);
        } else {
          odememisFaturalar.add(fatura);
        }
      }
    });
  }

  Future<void> _deleteFatura(int id) async {
    final db = await DbHelper.instance.faturaDatabase;
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

  double getTotalInvoiceAmount(List<Fatura> faturalar) {
    double total = 0;
    for (var invoice in faturalar) {
      total += invoice.tutar;
    }
    return total;
  }

  List<MapEntry<OnemSeviyesi, double>> calculateSegments(
      List<Fatura> faturalar) {
    final Map<OnemSeviyesi, double> groupedSegments = {};

    for (var fatura in faturalar) {
      final onemSeviyesi = fatura.onemSeviyesi;
      final tutar = fatura.tutar;

      if (groupedSegments.containsKey(onemSeviyesi)) {
        groupedSegments[onemSeviyesi] = groupedSegments[onemSeviyesi]! + tutar;
      } else {
        groupedSegments[onemSeviyesi] = tutar;
      }
    }

    return groupedSegments.entries.toList();
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

  Widget _buildFaturaListesi(List<Fatura> faturalar) {
    final segments = calculateSegments(faturalar);
    final colors =
        segments.map((segment) => _getOnemSeviyesiRenk(segment.key)).toList();

    return Padding(
      padding: const EdgeInsets.only(right: .0),
      child: Column(
        children: [
          TotalPrice(
            totalPrice: segments.fold(0, (sum, entry) => sum + entry.value),
            segments: segments.map((entry) => entry.value).toList(),
            colors: colors,
          ),
          Expanded(
            child: ListView.builder(
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
                    /* ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${fatura.aciklama} silindi')),
                    ); */
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
                          _getFaturaListesi(); // Güncelleme işlemi sonrası faturalar listesini yeniden alır
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
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
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Tutar:',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                    Text(
                                      "  ${fatura.tutar} TL",
                                      style: TextStyle(
                                        fontSize: 19.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Son Ödeme Tarihi:",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "  ${DateFormat('dd.MM.yyyy').format(fatura.tarih)}",
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            fatura.odendiMi
                                ? Icons.check
                                : Icons.warning_rounded,
                            color: fatura.odendiMi ? Colors.green : Colors.red,
                            size: 33,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.white, size: 30),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Faturalar'),
          backgroundColor: Colors.blueGrey,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Ödenmemiş Faturalar'),
              Tab(text: 'Ödenmiş Faturalar'),
            ],
            labelColor: Colors.black,
          ),
        ),
        body: TabBarView(
          children: [
            _buildFaturaListesi(odememisFaturalar),
            _buildFaturaListesi(odenmisFaturalar),
          ],
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
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
