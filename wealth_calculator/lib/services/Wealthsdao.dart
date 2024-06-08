import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/services/Wealths.dart';

class SavedWealthsdao {
  Future<List<SavedWealths>> getAllWealths() async {
    final db = await DbHelper.dbAccess();
    final List<Map<String, dynamic>> maps = await db.query('wealths');

    return List.generate(maps.length, (i) {
      return SavedWealths.fromMap(maps[i]);
    });
  }

  /* Future<void> insertWealth(SavedWealths wealth) async {
    var db = await DbHelper.dbAccess();
    await db.insert('wealths', {
      'id': wealth.id,
      'type': wealth.type,
      'amount': wealth.amount,
    });
  } */

  Future<void> insertWealth(SavedWealths wealth) async {
    final db = await DbHelper.dbAccess();
    await db.insert(
      'wealths',
      wealth.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteWealth(int id) async {
    final db = await DbHelper.dbAccess();
    await db.delete(
      'wealths',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateWealth(SavedWealths wealth) async {
    final db = await DbHelper.dbAccess();
    await db.update(
      'wealths',
      wealth.toMap(),
      where: 'id = ?',
      whereArgs: [wealth.id],
    );
  }

  Future<SavedWealths?> getWealthByType(String type) async {
    final db = await DbHelper.dbAccess();
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
