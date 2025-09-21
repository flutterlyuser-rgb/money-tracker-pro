import 'package:money_tracker/data/datasources/database_helper.dart';
import 'package:money_tracker/data/models/account_model.dart';
import 'package:money_tracker/domain/entities/account_entity.dart';
import 'package:money_tracker/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final DatabaseHelper _databaseHelper;

  AccountRepositoryImpl(this._databaseHelper);

  @override
  Future<int> createAccount(AccountEntity account) async {
    final db = await _databaseHelper.database;
    final model = AccountModel(
      id: account.id,
      name: account.name,
      initialBalance: account.initialBalance,
      currency: account.currency,
      colorHex: account.colorHex,
      trackIncome: account.trackIncome,
    );
    return await db.insert('accounts', model.toMap());
  }

  @override
  Future<List<AccountEntity>> getAllAccounts() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('accounts');
    final accounts = maps.map((map) => AccountModel.fromMap(map)).toList();
    return accounts.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AccountEntity?> getAccountById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first).toEntity();
    }
    return null;
  }

  @override
  Future<void> updateAccount(AccountEntity account) async {
    final db = await _databaseHelper.database;
    final model = AccountModel(
      id: account.id,
      name: account.name,
      initialBalance: account.initialBalance,
      currency: account.currency,
      colorHex: account.colorHex,
      trackIncome: account.trackIncome,
    );
    await db.update(
      'accounts',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  @override
  Future<void> deleteAccount(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<double> getAccountBalance(int accountId) async {
    final db = await _databaseHelper.database;
    
    // Get total income
    final incomeResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE accountId = ? AND isExpense = 0
    ''', [accountId]);
    
    // Get total expenses
    final expenseResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE accountId = ? AND isExpense = 1
    ''', [accountId]);
    
    final totalIncome = incomeResult.first['total'] as double? ?? 0.0;
    final totalExpenses = expenseResult.first['total'] as double? ?? 0.0;
    
    return totalIncome - totalExpenses;
  }

  @override
  Future<int> getAccountsCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM accounts');
    return result.first['count'] as int? ?? 0;
  }
}