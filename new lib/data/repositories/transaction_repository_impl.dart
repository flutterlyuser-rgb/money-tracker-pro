// import 'package:money_tracker/data/datasources/database_helper.dart';
// import 'package:money_tracker/data/models/transaction_model.dart';
// import 'package:money_tracker/domain/entities/transaction_entity.dart';
// import 'package:money_tracker/domain/repositories/transaction_repository.dart';

// class TransactionRepositoryImpl implements TransactionRepository {
//   final DatabaseHelper _databaseHelper;

//   TransactionRepositoryImpl(this._databaseHelper);

//   @override
//   Future<int> createTransaction(TransactionEntity transaction) async {
//     final db = await _databaseHelper.database;
//     final model = TransactionModel.fromEntity(transaction);
//     return await db.insert('transactions', model.toMap());
//   }

//   @override
//   Future<TransactionEntity?> getTransactionById(int id) async {
//     final db = await _databaseHelper.database;
//     final maps = await db.query(
//       'transactions',
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (maps.isNotEmpty) {
//       return TransactionModel.fromMap(maps.first).toEntity();
//     }
//     return null;
//   }

//   @override
//   Future<List<TransactionEntity>> getTransactionsByAccount(String accountId) async {
//     final db = await _databaseHelper.database;
//     final maps = await db.query(
//       'transactions',
//       where: 'accountId = ?',
//       whereArgs: [int.parse(accountId)],
//     );

//     return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
//   }

//   @override
//   Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end) async {
//     final db = await _databaseHelper.database;
//     final maps = await db.query(
//       'transactions',
//       where: 'date BETWEEN ? AND ?',
//       whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
//     );

//     return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
//   }

//   @override
// Future<double> getTotalExpenses(DateTime start, DateTime end) async {
//   final db = await _databaseHelper.database;
  
//   // ✅ Use SQL SUM() function - much more efficient!
//   final result = await db.rawQuery('''
//     SELECT SUM(amount) as total 
//     FROM transactions 
//     WHERE date BETWEEN ? AND ? AND isExpense = 1
//   ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
  
//   return result.first['total'] as double? ?? 0.0;
// }

// @override
// Future<double> getTotalIncome(DateTime start, DateTime end) async {
//   final db = await _databaseHelper.database;
  
//   // ✅ Use SQL SUM() function - much more efficient!
//   final result = await db.rawQuery('''
//     SELECT SUM(amount) as total 
//     FROM transactions 
//     WHERE date BETWEEN ? AND ? AND isExpense = 0
//   ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
  
//   return result.first['total'] as double? ?? 0.0;
// }
//   @override
//   Future<void> deleteTransaction(int id) async {
//     final db = await _databaseHelper.database;
//     await db.delete(
//       'transactions',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   @override
//   Future<void> updateTransaction(TransactionEntity transaction) async {
//     final db = await _databaseHelper.database;
//     final model = TransactionModel.fromEntity(transaction);
//     await db.update(
//       'transactions',
//       model.toMap(),
//       where: 'id = ?',
//       whereArgs: [transaction.id],
//     );
//   }

//   @override
//   Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId) async {
//     final db = await _databaseHelper.database;
//     final maps = await db.query(
//       'transactions',
//       where: 'categoryId = ?',
//       whereArgs: [int.parse(categoryId)],
//     );

//     return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
//   }

//   @override
//   Future<Map<String, double>> getCategoryWiseSpending(DateTime start, DateTime end) async {
//     final expenses = await getTotalExpenses(start, end);
//     // This would need more complex SQL query for category-wise totals
//     // For now, return empty map or implement proper SQL query
//     return {};
//   }
//   // Add these methods to your existing TransactionRepositoryImpl class

// @override
// Future<List<TransactionEntity>> getAllTransactions() async {
//   final db = await _databaseHelper.database;
//   final maps = await db.query('transactions', orderBy: 'date DESC');
//   return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
// }

// @override
// Future<int> getTransactionsCount() async {
//   final db = await _databaseHelper.database;
//   final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
//   return result.first['count'] as int? ?? 0;
// }

// @override
// Future<void> deleteAllTransactions() async {
//   final db = await _databaseHelper.database;
//   await db.delete('transactions');
// }

// @override
// Future<double> getAccountBalance(int accountId) async {
//   final db = await _databaseHelper.database;
  
//   // Get total income for account
//   final incomeResult = await db.rawQuery('''
//     SELECT SUM(amount) as total FROM transactions 
//     WHERE accountId = ? AND isExpense = 0
//   ''', [accountId]);
  
//   // Get total expenses for account
//   final expenseResult = await db.rawQuery('''
//     SELECT SUM(amount) as total FROM transactions 
//     WHERE accountId = ? AND isExpense = 1
//   ''', [accountId]);
  
//   final totalIncome = incomeResult.first['total'] as double? ?? 0.0;
//   final totalExpenses = expenseResult.first['total'] as double? ?? 0.0;
  
//   return totalIncome - totalExpenses;
// }
// }
import 'package:money_tracker/data/datasources/database_helper.dart';
import 'package:money_tracker/data/models/transaction_model.dart';
import 'package:money_tracker/domain/entities/transaction_entity.dart';
import 'package:money_tracker/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {// it must to implement the TransactionRepository (abstract class)
  final DatabaseHelper _databaseHelper;

  TransactionRepositoryImpl(this._databaseHelper);

  @override
  Future<int> createTransaction(TransactionEntity transaction) async {
    final db = await _databaseHelper.database;
    final model = TransactionModel.fromEntity(transaction);
    return await db.insert('transactions', model.toMap());
  }

  @override
  Future<TransactionEntity?> getTransactionById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first).toEntity();
    }
    return null;
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByAccount(String accountId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [int.parse(accountId)],
    );

    return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    
    // ✅ Use SQL SUM() function - much more efficient!
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE date BETWEEN ? AND ? AND isExpense = 1
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    
    return result.first['total'] as double? ?? 0.0;
  }

  @override
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    
    // ✅ Use SQL SUM() function - much more efficient!
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions 
      WHERE date BETWEEN ? AND ? AND isExpense = 0
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    
    return result.first['total'] as double? ?? 0.0;
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final db = await _databaseHelper.database;
    final model = TransactionModel.fromEntity(transaction);
    await db.update(
      'transactions',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'categoryId = ?',
      whereArgs: [int.parse(categoryId)],
    );

    return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
  }

  @override
  Future<Map<String, double>> getCategoryWiseSpending(DateTime start, DateTime end) async {
    final expenses = await getTotalExpenses(start, end);
    // This would need more complex SQL query for category-wise totals
    // For now, return empty map or implement proper SQL query
    return {};
  }

  // Add these methods to your existing TransactionRepositoryImpl class

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((map) => TransactionModel.fromMap(map).toEntity()).toList();
  }

  // ✅ NEW METHOD: Get recent transactions with limit
  @override
  Future<List<TransactionEntity>> getRecentTransactions(int limit) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]).toEntity();
    });
  }

  @override
  Future<int> getTransactionsCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
    return result.first['count'] as int? ?? 0;
  }

  @override
  Future<void> deleteAllTransactions() async {
    final db = await _databaseHelper.database;
    await db.delete('transactions');
  }

  @override
  Future<double> getAccountBalance(int accountId) async {
    final db = await _databaseHelper.database;
    
    // Get total income for account
    final incomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE accountId = ? AND isExpense = 0
    ''', [accountId]);
    
    // Get total expenses for account
    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE accountId = ? AND isExpense = 1
    ''', [accountId]);
    
    final totalIncome = incomeResult.first['total'] as double? ?? 0.0;
    final totalExpenses = expenseResult.first['total'] as double? ?? 0.0;
    
    return totalIncome - totalExpenses;
  }
}