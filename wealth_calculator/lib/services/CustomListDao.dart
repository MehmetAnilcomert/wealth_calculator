import 'package:sqflite/sqflite.dart';
import 'package:wealth_calculator/modals/WealthDataModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

class CustomListDao {
  /// Portföy için seçilmiş varlığı, [custom_wealth_assets] tablosuna ekler.
  /// Eğer aynı varlık zaten varsa eklemeyi göz ardı eder.
  /// This method inserts the selected wealth into the [custom_wealth_assets] table for user`s portfolio.
  Future<void> insertWealthPrice(WealthPrice wealthPrice) async {
    try {
      final db = await DbHelper.instance.database;
      print('Inserting into custom_wealth_assets: ${wealthPrice.title}');
      await db.insert(
        'custom_wealth_assets',
        {
          'title': wealthPrice.title,
          'type': wealthPrice
              .type.index, // PriceType enum değeri, integer olarak saklanır.
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
        // Eğer aynı varlık zaten varsa eklemeyi göz ardı eder.
      );
    } catch (e) {
      print('Error occurred while inserting into custom_wealth_assets: $e');
    }
  }

  /// [custom_wealth_assets] tablosundaki kayıtların title ve type bilgilerini kullanarak,
  /// [cached_wealth_prices] tablosundan güncel fiyat verilerini getirir.
  /// This method fetches the current price data from the [cached_wealth_prices] table
  /// using the title and type information of the records in the [custom_wealth_assets] table.
  Future<List<WealthPrice>> getSelectedWealthPrices() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT cw.*
      FROM cached_wealth_prices cw
      INNER JOIN custom_wealth_assets ca
      ON cw.title = ca.title AND cw.type = ca.type
    ''');

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

  /// [custom_wealth_assets] tablosundan, [title] ve [type] bilgisine göre kaydı siler.
  /// This method deletes the record from the [custom_wealth_assets] table according to the [title] and [type] information as well as user`s portfolio.
  Future<void> deleteWealthPrice(WealthPrice wealthPrice) async {
    try {
      final db = await DbHelper.instance.database;
      print('Deleting from custom_wealth_assets: ${wealthPrice.title}');
      await db.delete(
        'custom_wealth_assets',
        where: 'title = ? AND type = ?',
        whereArgs: [wealthPrice.title, wealthPrice.type.index],
      );
    } catch (e) {
      print('Error occurred while deleting from custom_wealth_assets: $e');
    }
  }
}
