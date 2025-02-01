import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// This class is responsible for essential database operations
class DbHelper {
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(_createFaturaTable);
        await db.execute(_createInventoryTable);
        await db.execute(_createCachedWealthPricesTable);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE fatura ADD COLUMN isNotificationEnabled INTEGER DEFAULT 0;");
        }
        if (oldVersion < 3) {
          await db.execute(_createCachedWealthPricesTable);
        }
      },
    );
  }

  static const String _createFaturaTable = '''
    CREATE TABLE fatura (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tarih TEXT NOT NULL,
      tutar REAL NOT NULL,
      aciklama TEXT,
      onemSeviyesi TEXT,
      odendiMi INTEGER,
      isNotificationEnabled INTEGER DEFAULT 0
    )
  ''';

  static const String _createInventoryTable = '''
    CREATE TABLE inventory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      amount INTEGER NOT NULL
    )
  ''';

  static const String _createCachedWealthPricesTable = '''
    CREATE TABLE cached_wealth_prices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      buyingPrice TEXT NOT NULL,
      sellingPrice TEXT NOT NULL,
      change RETEXTAL NOT NULL,
      time TEXT NOT NULL,
      type INTEGER NOT NULL, 
      currentPrice TEXT, 
      volume TEXT, 
      changeAmount TEXT,
      lastUpdatedDate TEXT,
      lastUpdatedTime TEXT,
      isSelected INTEGER DEFAULT 0,
      UNIQUE(title, type)
    )
  ''';

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
