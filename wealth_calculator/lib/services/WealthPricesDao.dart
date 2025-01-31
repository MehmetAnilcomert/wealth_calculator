import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class WealthPricesDao {
  Future<List<WealthPrice>> getAllPrices() async {
    final db = await DbHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query('cached_wealth_prices');
    print("Veritabanından gelen: $maps");
    return List.generate(maps.length, (i) {
      return WealthPrice.fromMap(maps[i]);
    });
  }

  Future<void> insertPrices(List<WealthPrice> prices) async {
    final db = await DbHelper.instance.database;
    Batch batch = db.batch();

    // Get the current date and time for `lastUpdatedDate` and `lastUpdatedTime`
    String currentDate =
        DateTime.now().toIso8601String().split("T").first; // YYYY-MM-DD
    String currentTime = DateTime.now()
        .toIso8601String()
        .split("T")
        .last
        .split(".")
        .first; // HH:MM:SS

    // Add each price to the batch
    for (var price in prices) {
      // Insert the additional fields for `lastUpdatedDate` and `lastUpdatedTime`
      batch.insert(
        'cached_wealth_prices',
        {
          ...price.toMap(),
          'lastUpdatedDate': currentDate,
          'lastUpdatedTime': currentTime,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }
}
