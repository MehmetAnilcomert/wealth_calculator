import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/feature/inventory/model/wealth_history_model.dart';
import 'package:wealth_calculator/product/service/database_helper.dart';

class PriceHistoryDao {
  /// Her çağrıldığında bugünün tarihini ve verilen toplam fiyatı 'wealth_history' tablosuna ekler.
  /// This method inserts the current date and the given total price into the 'wealth_history' table to generate chart via using them.
  Future<void> insertTotalPriceHistory(double totalPrice) async {
    final db = await DbHelper.instance.database;

    // Sadece tarihi (gün bazında) kaydet - saat/dakika/saniye olmadan
    // Bu sayede aynı gün için sadece 1 kayıt olur
    final todayDate = DateTime.now().toIso8601String().split('T')[0];
    print('Inserting into wealth_history: $todayDate, $totalPrice');
    await db.insert(
      'wealth_history',
      {
        'date': todayDate,
        'totalPrice': totalPrice,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 'wealth_history' tablosundaki tüm kayıtları döndürür.
  /// This method returns all records in the 'wealth_history' table.
  Future<List<WealthHistory>> getAllWealthHistory() async {
    final db = await DbHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query('wealth_history');

    return maps.map((map) => WealthHistory.fromMap(map)).toList();
  }

  /// Bugünün tarihinde bir kayıt olup olmadığını kontrol eder
  /// Checks if there is already a record for today's date
  Future<bool> hasTodayRecord() async {
    final db = await DbHelper.instance.database;
    final todayDate = DateTime.now().toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> result = await db.query(
      'wealth_history',
      where: 'date = ?',
      whereArgs: [todayDate],
      limit: 1,
    );
    
    return result.isNotEmpty;
  }
}
