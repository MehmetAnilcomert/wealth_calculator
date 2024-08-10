import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/modals/Wealths.dart';

class SavedWealthsdao {
  Future<List<SavedWealths>> getAllWealths() async {
    final db = await DbHelper.instance.inventoryDatabase;
    List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM wealths");

    return List.generate(maps.length, (i) {
      return SavedWealths.fromMap(maps[i]);
    });
  }

  Future<void> insertWealth(SavedWealths wealth) async {
    final db = await DbHelper.instance.inventoryDatabase;
    await db.insert(
      'wealths',
      wealth.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteWealth(int id) async {
    final db = await DbHelper.instance.inventoryDatabase;
    await db.delete(
      'wealths',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateWealth(SavedWealths wealth) async {
    final db = await DbHelper.instance.inventoryDatabase;
    await db.update(
      'wealths',
      wealth.toMap(),
      where: 'id = ?',
      whereArgs: [wealth.id],
    );
  }

  Future<SavedWealths?> getWealthByType(String type) async {
    final db = await DbHelper.instance.inventoryDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'wealths',
      where: 'type = ?',
      whereArgs: [type],
    );

    if (maps.isNotEmpty) {
      return SavedWealths.fromMap(maps.first);
    } else {
      return null;
    }
  }
}
