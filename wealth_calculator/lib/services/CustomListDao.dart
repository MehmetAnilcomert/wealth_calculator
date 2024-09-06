import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class CustomListDao {
  // WealthPrice nesnesini tabloya eklemek için fonksiyon
  Future<void> insertWealthPrice(WealthPrice wealthPrice) async {
    final db = await DbHelper.instance.customListDatabase;
    print("${wealthPrice.title} dbye eklendi");
    await db.insert(
      'wealth_prices',
      wealthPrice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Tüm WealthPrice nesnelerini almak için fonksiyon
  Future<List<WealthPrice>> getWealthPrices() async {
    final db = await DbHelper.instance.customListDatabase;

    final List<Map<String, dynamic>> maps = await db.query('wealth_prices');

    return List.generate(maps.length, (i) {
      return WealthPrice(
        title: maps[i]['title'],
        buyingPrice: maps[i]['buyingPrice'].toString(),
        sellingPrice: maps[i]['sellingPrice'].toString(),
        change: maps[i]['change'],
        time: maps[i]['time'],
        type: PriceType.values[maps[i]['type']],
        currentPrice: maps[i]['currentPrice'].toString(),
        volume: maps[i]['volume'],
        changeAmount: maps[i]['changeAmount'],
      );
    });
  }

  // WealthPrice nesnesini silmek için fonksiyon
  Future<void> deleteWealthPrice(String title) async {
    final db = await DbHelper.instance.customListDatabase;

    await db.delete(
      'wealth_prices',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  Future<void> updateWealthPrices(List<WealthPrice> updatedPrices) async {
    final db = await DbHelper.instance.customListDatabase;
    for (WealthPrice wealthPrice in updatedPrices) {
      await db.update(
        'wealth_prices',
        wealthPrice.toMap(),
        where: 'title = ?',
        whereArgs: [wealthPrice.title],
      );
    }
  }
}
