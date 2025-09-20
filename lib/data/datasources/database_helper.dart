import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'money_tracker.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        initialBalance REAL NOT NULL,
        currency TEXT DEFAULT 'USD',
        colorHex TEXT DEFAULT '#2196F3',
        trackIncome INTEGER DEFAULT 1
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        colorHex TEXT NOT NULL,
        iconCode TEXT NOT NULL,
        isExpenseCategory INTEGER NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        isExpense INTEGER NOT NULL,
        accountId INTEGER NOT NULL,
        receiptImagePath TEXT,
        location TEXT,
        isRecurring INTEGER DEFAULT 0,
        recurringPattern TEXT,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id),
        FOREIGN KEY (accountId) REFERENCES accounts (id)
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        amount REAL NOT NULL,
        period INTEGER NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        alertThreshold REAL DEFAULT 0.9,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');
  }

  // Helper methods for common operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    required String where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }
   Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }


  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}