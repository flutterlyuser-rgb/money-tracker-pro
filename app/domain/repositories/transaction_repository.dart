// import 'package:money_tracker/domain/entities/transaction_entity.dart';

// abstract class TransactionRepository {
//   // Create
//   Future<int> createTransaction(TransactionEntity transaction);
  
//   // Read
//   Future<TransactionEntity?> getTransactionById(int id);
//   Future<List<TransactionEntity>> getAllTransactions();
//   Future<List<TransactionEntity>> getTransactionsByAccount(String accountId);
//   Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end);
//   Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId);
  
//   // Update
//   Future<void> updateTransaction(TransactionEntity transaction);
  
//   // Delete
//   Future<void> deleteTransaction(int id);
//   Future<void> deleteAllTransactions(); // ✅ Added missing method
  
//   // Analytics
//   Future<double> getTotalExpenses(DateTime start, DateTime end);
//   Future<double> getTotalIncome(DateTime start, DateTime end);
//   Future<double> getAccountBalance(int accountId); // ✅ Added missing method
//   Future<Map<String, double>> getCategoryWiseSpending(DateTime start, DateTime end);
  
//   // Utilities
//   Future<int> getTransactionsCount(); // ✅ Added missing method
// }
// domain/repositories/transaction_repository.dart
import 'package:money_tracker/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {      //this is an abstract class for TransactionRepositoryImpl
  // Create
  Future<int> createTransaction(TransactionEntity transaction);
  
  // Read
  Future<TransactionEntity?> getTransactionById(int id);
  Future<List<TransactionEntity>> getAllTransactions();
  Future<List<TransactionEntity>> getRecentTransactions(int limit); // ✅ NEW METHOD
  Future<List<TransactionEntity>> getTransactionsByAccount(String accountId);
  Future<List<TransactionEntity>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId);
  
  // Update
  Future<void> updateTransaction(TransactionEntity transaction);
  
  // Delete
  Future<void> deleteTransaction(int id);
  Future<void> deleteAllTransactions();
  
  // Analytics
  Future<double> getTotalExpenses(DateTime start, DateTime end);
  Future<double> getTotalIncome(DateTime start, DateTime end);
  Future<double> getAccountBalance(int accountId);
  Future<Map<String, double>> getCategoryWiseSpending(DateTime start, DateTime end);
  
  // Utilities
  Future<int> getTransactionsCount();
}