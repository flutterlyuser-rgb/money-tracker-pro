import 'package:money_tracker/data/datasources/database_helper.dart';
import 'package:money_tracker/data/models/category_model.dart';
import 'package:money_tracker/data/models/account_model.dart';

class DefaultData {
  static final List<CategoryModel> defaultCategories = [
    CategoryModel(
      name: 'Food & Dining',
      colorHex: '#FF6B6B',
      iconCode: '0xe561',
      isExpenseCategory: true,
    ),
    CategoryModel(
      name: 'Transportation',
      colorHex: '#4ECDC4',
      iconCode: '0xe531',
      isExpenseCategory: true,
    ),
    CategoryModel(
      name: 'Shopping',
      colorHex: '#45B7D1',
      iconCode: '0xf1cc',
      isExpenseCategory: true,
    ),
    CategoryModel(
      name: 'Salary',
      colorHex: '#96CEB4',
      iconCode: '0xf201',
      isExpenseCategory: false,
    ),
    CategoryModel(
      name: 'Freelance',
      colorHex: '#FFEAA7',
      iconCode: '0xe86f',
      isExpenseCategory: false,
    ),
  ];

  static Future<void> initializeDefaultData(DatabaseHelper databaseHelper) async {
    final db = await databaseHelper.database;
    
    // Check if categories already exist
    final categoryCount = await db.rawQuery('SELECT COUNT(*) FROM categories');
    if ((categoryCount.first['COUNT(*)'] as int) == 0) {
      for (final category in defaultCategories) {
        await db.insert('categories', category.toMap());
      }
    }
    
    // Check if accounts already exist
    final accountCount = await db.rawQuery('SELECT COUNT(*) FROM accounts');
    if ((accountCount.first['COUNT(*)'] as int) == 0) {
      final defaultAccount = AccountModel(
        name: 'Cash Wallet',
        initialBalance: 0.0,
      );
      await db.insert('accounts', defaultAccount.toMap());
    }
  }
}