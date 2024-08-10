import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();
  static Database? _faturaDatabase;
  static Database? _inventoryDatabase;

  Future<Database> get faturaDatabase async {
    if (_faturaDatabase != null) return _faturaDatabase!;
    _faturaDatabase = await _initFaturaDatabase();
    return _faturaDatabase!;
  }

  Future<Database> get inventoryDatabase async {
    if (_inventoryDatabase != null) return _inventoryDatabase!;
    _inventoryDatabase = await _initInventoryDatabase();
    return _inventoryDatabase!;
  }

  Future<Database> _initFaturaDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await openDatabase(
      join(await getDatabasesPath(), 'my_database.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fatura (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tarih TEXT NOT NULL,
            tutar REAL NOT NULL,
            aciklama TEXT,
            onemSeviyesi TEXT,
            odendiMi INTEGER
          )
        ''');
      },
    );
  }

  Future<Database> _initInventoryDatabase() async {
    String dbPath = join(await getDatabasesPath(), "inventory.db");

    if (await databaseExists(dbPath)) {
      print("Inventory database already exists.");
    } else {
      ByteData data = await rootBundle.load("database/inventory.db");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
      print("Inventory database copied.");
    }

    return openDatabase(dbPath);
  }
}
