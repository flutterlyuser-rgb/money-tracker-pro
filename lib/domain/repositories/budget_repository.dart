import 'package:money_tracker/domain/entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<int> createBudget(BudgetEntity budget);
  Future<List<BudgetEntity>> getAllBudgets();
  Future<BudgetEntity?> getBudgetById(int id);
  Future<List<BudgetEntity>> getBudgetsByCategory(String categoryId);
  Future<List<BudgetEntity>> getActiveBudgets();
  Future<void> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(int id);
  Future<double> getBudgetSpending(String categoryId, DateTime start, DateTime end);
  Future<int> getBudgetsCount();
}