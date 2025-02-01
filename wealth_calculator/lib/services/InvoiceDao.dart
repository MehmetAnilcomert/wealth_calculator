import 'package:wealth_calculator/modals/InvoiceModal.dart';
import 'package:wealth_calculator/services/DatabaseHelper.dart';

// This class is responsible for handling all the database operations related to the Invoice model.
class InvoiceDao {
  final DbHelper _dbHelper = DbHelper.instance;

  Future<List<Invoice>> getAllInvoices() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('fatura');
    return maps.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<int> addInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    return await db.insert('fatura', invoice.toMap());
  }

  Future<int> updateInvoice(Invoice invoice) async {
    final db = await _dbHelper.database;
    return await db.update(
      'fatura',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> deleteInvoice(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'fatura',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
