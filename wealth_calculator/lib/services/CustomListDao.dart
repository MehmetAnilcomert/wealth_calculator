import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

// Portföydeki fiyatları saklamak için kullanılan tablonun veritabanı işlemlerini yapan sınıf
//This class is responsible for database operations of the table used to store prices in the portfolio
class CustomListDao {
  Future<void> insertWealthPrice(WealthPrice wealthPrice) async {
    final db = await DbHelper.instance.database;

    // Set isSelected to 1 when inserting or updating
    await db.insert(
      'cached_wealth_prices',
      wealthPrice.toMap()..['isSelected'] = 1, // Set isSelected to 1
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Tüm portfölyo WealthPrice nesnelerini almak için fonksiyon
  // Get all WealthPrice entries in portfolio where isSelected = 1
  Future<List<WealthPrice>> getSelectedWealthPrices() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'cached_wealth_prices',
      where: 'isSelected = ?',
      whereArgs: [1],
    );

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
  // Function to delete a WealthPrice object
  Future<void> deleteWealthPrice(String title) async {
    final db = await DbHelper.instance.database;

    // Set isSelected to 0 when deleting
    await db.update(
      'cached_wealth_prices',
      {'isSelected': 0}, // Set isSelected to 0
      where: 'title = ?',
      whereArgs: [title],
    );
  }
}
