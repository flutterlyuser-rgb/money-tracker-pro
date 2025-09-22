// Use the core Riverpod package instead of flutter_riverpod. See the notes in
// account_providers.dart for an explanation of why riverpod is used here.
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/entities/budget_entity.dart';
import '../../data/providers/repository_providers.dart';

/// A [StateNotifier] that manages the list of budgets.
///
/// Budgets are loaded from the database on construction. For each
/// retrieved [BudgetEntity] the current spending is calculated via
/// [BudgetRepository.getBudgetSpending] so that the UI can display
/// up‑to‑date consumption, remaining amount and percentage spent. The
/// notifier exposes methods to create, update and delete budgets and
/// refreshes its state after each operation.
class BudgetsNotifier extends StateNotifier<List<BudgetEntity>> {
  final Ref _ref;

  BudgetsNotifier(this._ref) : super([]) {
    _loadBudgets();
  }

  /// Loads all budgets from the repository and enriches each one with
  /// spending information. This method is invoked automatically on
  /// construction and after each mutation. It assigns the enriched list
  /// to [state], triggering rebuilds of consumers.
  Future<void> _loadBudgets() async {
    final repository = _ref.read(budgetRepositoryProvider);
    final budgets = await repository.getAllBudgets();
    final List<BudgetEntity> enriched = [];
    for (final budget in budgets) {
      final spent = await repository.getBudgetSpending(
        budget.categoryId,
        budget.startDate,
        budget.endDate,
      );
      final remaining = budget.amount - spent;
      final percentage = budget.amount > 0 ? spent / budget.amount : 0.0;
      enriched.add(
        budget.copyWith(
          spentAmount: spent,
          remainingAmount: remaining,
          percentageSpent: percentage,
        ),
      );
    }
    state = enriched;
  }

  /// Persists a new [BudgetEntity] and reloads the list of budgets.
  Future<void> addBudget(BudgetEntity budget) async {
    final repository = _ref.read(budgetRepositoryProvider);
    await repository.createBudget(budget);
    await _loadBudgets();
  }

  /// Updates an existing budget and reloads the list.
  Future<void> updateBudget(BudgetEntity budget) async {
    final repository = _ref.read(budgetRepositoryProvider);
    await repository.updateBudget(budget);
    await _loadBudgets();
  }

  /// Deletes a budget by [id] and reloads the list.
  Future<void> deleteBudget(int id) async {
    final repository = _ref.read(budgetRepositoryProvider);
    await repository.deleteBudget(id);
    await _loadBudgets();
  }
}

/// Provider exposing the list of budgets managed by [BudgetsNotifier].
final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, List<BudgetEntity>>(
  (ref) => BudgetsNotifier(ref),
);