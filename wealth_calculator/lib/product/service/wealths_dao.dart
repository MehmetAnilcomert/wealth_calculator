import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';
import 'package:wealth_calculator/feature/inventory/model/wealths_model.dart';

// Envanterdeki varlıkları saklamak için kullanılan tablonun veritabanı işlemlerini yapan sınıf
// This class is responsible for database operations of the table used to store wealth items in the inventory
class SavedWealthsdao {
  Future<List<SavedWealths>> getAllWealths() async {
    final db = await DbHelper.instance.database;
    List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM inventory");

    return List.generate(maps.length, (i) {
      return SavedWealths.fromMap(maps[i]);
    });
  }

  // This method is used to insert a new wealth to the database`s inventory table
  Future<void> insertWealth(SavedWealths wealth) async {
    final db = await DbHelper.instance.database;
    await db.insert(
      'inventory',
      wealth.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // This method is used to delete a wealth from the database`s inventory table
  Future<void> deleteWealth(int id) async {
    final db = await DbHelper.instance.database;
    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // This method is used to update a wealth in the database`s inventory table
  Future<void> updateWealth(SavedWealths wealth) async {
    final db = await DbHelper.instance.database;
    await db.update(
      'inventory',
      wealth.toMap(),
      where: 'id = ?',
      whereArgs: [wealth.id],
    );
  }

  // This method is used to get a wealth by its type from the database`s inventory table
  Future<SavedWealths?> getWealthByType(String type) async {
    final db = await DbHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'inventory',
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
