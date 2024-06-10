import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class GoldDataDao {
// Insert a WealthPrice into the database
  Future<void> insertWealthPrice(WealthPrice wealthPrice) async {
    final db = await DbHelper.dbAccess();
    await db.insert(
      'wealthPrice',
      wealthPrice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update a WealthPrice in the database
  Future<void> updateWealthPrice(WealthPrice wealthPrice) async {
    final db = await DbHelper.dbAccess();
    await db.update(
      'wealthPrice',
      wealthPrice.toMap(),
      where: 'title = ?',
      whereArgs: [wealthPrice.title],
    );
  }

  // Delete a WealthPrice from the database
  Future<void> deleteWealthPrice(String title) async {
    final db = await DbHelper.dbAccess();
    await db.delete(
      'wealthPrice',
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Fetch a WealthPrice by type from the database
  Future<WealthPrice?> getWealthByType(String type) async {
    final db = await DbHelper.dbAccess();
    final List<Map<String, dynamic>> maps = await db.query(
      'wealthPrice',
      where: 'title = ?',
      whereArgs: [type],
    );

    if (maps.isNotEmpty) {
      return WealthPrice.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Fetch all WealthPrices from the database
  Future<List<WealthPrice>> fetchAllWealthPrices() async {
    final db = await DbHelper.dbAccess();
    final List<Map<String, dynamic>> maps = await db.query('wealthPrice');

    return List.generate(maps.length, (i) {
      return WealthPrice.fromMap(maps[i]);
    });
  }

  Future<void> saveGoldPrices(List<WealthPrice> goldPrices) async {
    for (var price in goldPrices) {
      await insertWealthPrice(price);
    }
  }
}
