import 'package:money_tracker/data/datasources/database_helper.dart';
import 'package:money_tracker/data/models/budget_model.dart';
import 'package:money_tracker/domain/entities/budget_entity.dart';
import 'package:money_tracker/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final DatabaseHelper _databaseHelper;

  BudgetRepositoryImpl(this._databaseHelper);

  // Helper method to get category name
  Future<String> _getCategoryName(int categoryId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    
    if (maps.isNotEmpty) {
      return maps.first['name'] as String;
    }
    return 'Unknown Category';
  }

  @override
  Future<int> createBudget(BudgetEntity entity) async {
    final db = await _databaseHelper.database;
    final model = BudgetModel.fromEntity(entity);
    return await db.insert('budgets', model.toMap());
  }

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('budgets');
    final budgets = maps.map((map) => BudgetModel.fromMap(map)).toList();
    
    // Convert to entities with category names
    return await Future.wait(
      budgets.map((model) async {
        final categoryName = await _getCategoryName(model.categoryId);
        return model.toEntity(categoryName: categoryName);
      }),
    );
  }

  @override
  Future<BudgetEntity?> getBudgetById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final model = BudgetModel.fromMap(maps.first);
      final categoryName = await _getCategoryName(model.categoryId);
      return model.toEntity(categoryName: categoryName);
    }
    return null;
  }

  @override
  Future<List<BudgetEntity>> getBudgetsByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'budgets',
      where: 'categoryId = ?',
      whereArgs: [int.parse(categoryId)],
    );
    final budgets = maps.map((map) => BudgetModel.fromMap(map)).toList();
    
    // Convert to entities with category names
    return await Future.wait(
      budgets.map((model) async {
        final categoryName = await _getCategoryName(model.categoryId);
        return model.toEntity(categoryName: categoryName);
      }),
    );
  }

  @override
  Future<List<BudgetEntity>> getActiveBudgets() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'budgets',
      where: 'startDate <= ? AND endDate >= ?',
      whereArgs: [now, now],
    );
    final budgets = maps.map((map) => BudgetModel.fromMap(map)).toList();
    
    // Convert to entities with category names
    return await Future.wait(
      budgets.map((model) async {
        final categoryName = await _getCategoryName(model.categoryId);
        return model.toEntity(categoryName: categoryName);
      }),
    );
  }

  @override
  Future<void> updateBudget(BudgetEntity entity) async {
    final db = await _databaseHelper.database;
    final model = BudgetModel.fromEntity(entity);
    await db.update(
      'budgets',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> deleteBudget(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<double> getBudgetSpending(String categoryId, DateTime start, DateTime end) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE categoryId = ? AND date BETWEEN ? AND ? AND isExpense = 1
    ''', [int.parse(categoryId), start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    
    return result.first['total'] as double? ?? 0.0;
  }

  @override
  Future<int> getBudgetsCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM budgets');
    return result.first['count'] as int? ?? 0;
  }
}