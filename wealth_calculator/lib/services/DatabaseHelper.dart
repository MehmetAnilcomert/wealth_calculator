import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final String dbName = "inventory.db";

  static Future<Database> dbAccess() async {
    String dbPath = join(await getDatabasesPath(), dbName);

    if (await databaseExists(dbPath)) {
      //Checking db if it exists
      print("There is also a database.No need to copy.");
    } else {
      //fetching db from assets
      ByteData data = await rootBundle.load("database/$dbName");
      //Byte change to open db
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      //Copying db.
      await File(dbPath).writeAsBytes(bytes, flush: true);
      print("Database copied.");
    }
    //Opening db.
    return openDatabase(dbPath);
  }
}
