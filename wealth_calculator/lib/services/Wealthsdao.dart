import 'package:wealth_calculator/services/DatabaseHelper.dart';
import 'package:wealth_calculator/services/Wealths.dart';

class SavedWealthsdao {
  Future<List<SavedWealths>> getAllWealths() async {
    var db = await DbHelper.dbAccess();

    List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT * FROM wealths");

    return List.generate(maps.length, (i) {
      var row = maps[i];
      return SavedWealths(
          id: row["id"], type: row["type"], amount: row["amount"]);
    });
  }

  Future<void> insertWealth(SavedWealths wealth) async {
    var db = await DbHelper.dbAccess();
    await db.insert('wealths', {
      'id': wealth.id,
      'type': wealth.type,
      'amount': wealth.amount,
    });
  }

  Future<void> deleteWealth(int id) async {
    final db = await DbHelper.dbAccess();
    await db.delete(
      'wealths',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
