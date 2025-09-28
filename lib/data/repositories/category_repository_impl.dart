import 'package:money_tracker/data/datasources/database_helper.dart';
import 'package:money_tracker/data/models/category_model.dart';
import 'package:money_tracker/domain/entities/category_entity.dart';
import 'package:money_tracker/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepositoryImpl(this._databaseHelper);

  @override
  Future<int> createCategory(CategoryEntity category) async {
    final db = await _databaseHelper.database;
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      colorHex: category.colorHex,
      iconCode: category.iconCode,
      isExpenseCategory: category.isExpenseCategory,
    );
    return await db.insert('categories', model.toMap());
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('categories');
    final categories = maps.map((map) => CategoryModel.fromMap(map)).toList();
    return categories.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      where: 'isExpenseCategory = ?',
      whereArgs: [1],
    );
    final categories = maps.map((map) => CategoryModel.fromMap(map)).toList();
    return categories.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      where: 'isExpenseCategory = ?',
      whereArgs: [0],
    );
    final categories = maps.map((map) => CategoryModel.fromMap(map)).toList();
    return categories.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first).toEntity();
    }
    return null;
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return CategoryModel.fromMap(maps.first).toEntity();
    }
    return null;
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final db = await _databaseHelper.database;
    final model = CategoryModel(
      id: category.id,
      name: category.name,
      colorHex: category.colorHex,
      iconCode: category.iconCode,
      isExpenseCategory: category.isExpenseCategory,
    );
    await db.update(
      'categories',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> getCategoriesCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM categories');
    return result.first['count'] as int? ?? 0;
  }
}