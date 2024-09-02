import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class CustomListDao {
  // WealthPrice nesnesini tabloya eklemek için fonksiyon
  Future<void> insertWealthPrice(WealthPrice wealthPrice) async {
    final db = await DbHelper.instance.customListDatabase;

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
        buyingPrice: maps[i]['buyingPrice'],
        sellingPrice: maps[i]['sellingPrice'],
        change: maps[i]['change'],
        time: maps[i]['time'],
        type: PriceType.values[maps[i]['type']],
        currentPrice: maps[i]['currentPrice'],
        volume: maps[i]['volume'],
        changeAmount: maps[i]['changeAmount'],
      );
    });
  }

  // WealthPrice nesnesini silmek için fonksiyon
  Future<void> deleteWealthPrice(int id) async {
    final db = await DbHelper.instance.customListDatabase;

    await db.delete(
      'wealth_prices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
