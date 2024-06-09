import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class CurrencyDataDao {
  // Insert a WealthPrice into the database
  Future<void> insertWealthPrice(WealthPrice wealthPrice) async {
    final db = await DbHelper.dbAccess();
    await db.insert(
      'currencydata',
      wealthPrice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a WealthPrice in the database
  Future<void> updateWealthPrice(WealthPrice wealthPrice) async {
    final db = await DbHelper.dbAccess();
    await db.update(
      'currencydata',
      wealthPrice.toMap(),
      where: 'title = ?',
      whereArgs: [wealthPrice.title],
    );
  }

  // Delete a WealthPrice from the database
  Future<void> deleteWealthPrice(String title) async {
    final db = await DbHelper.dbAccess();
    await db.delete(
      'currencydata',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Fetch a WealthPrice by type from the database
  Future<WealthPrice?> getWealthByType(String type) async {
    final db = await DbHelper.dbAccess();
    final List<Map<String, dynamic>> maps = await db.query(
      'currencydata',
      where: 'title = ?',
      whereArgs: [type],
    );

    if (maps.isNotEmpty) {
      return WealthPrice.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Save currency prices to the database
  Future<void> saveCurrencyPrices(List<WealthPrice> currencyPrices) async {
    for (var price in currencyPrices) {
      await insertWealthPrice(price);
    }
  }

  // Fetch all currency prices from the database
  Future<List<WealthPrice>> fetchAllCurrencyPrices() async {
    final db = await DbHelper.dbAccess();
    final List<Map<String, dynamic>> maps = await db.query('currencydata');

    return List.generate(maps.length, (i) {
      return WealthPrice.fromMap(maps[i]);
    });
  }
}
