import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/data/datasources/database_helper.dart';
import 'package:money_tracker/data/repositories/account_repository_impl.dart';
import 'package:money_tracker/data/repositories/budget_repository_impl.dart';
import 'package:money_tracker/data/repositories/category_repository_impl.dart';
import 'package:money_tracker/data/repositories/transaction_repository_impl.dart';
import 'package:money_tracker/domain/repositories/account_repository.dart';
import 'package:money_tracker/domain/repositories/budget_repository.dart';
import 'package:money_tracker/domain/repositories/category_repository.dart';
import 'package:money_tracker/domain/repositories/transaction_repository.dart';

// Database Provider
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Repository Providers
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final databaseHelper = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(databaseHelper);
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final databaseHelper = ref.watch(databaseProvider);
  return AccountRepositoryImpl(databaseHelper);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final databaseHelper = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(databaseHelper);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final databaseHelper = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(databaseHelper);
});