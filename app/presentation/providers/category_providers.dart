// Import Riverpod core instead of flutter_riverpod. See account_providers.dart
// for an explanation of why riverpod is used directly.
import 'package:riverpod/riverpod.dart';
import 'package:money_tracker/data/providers/repository_providers.dart';
import 'package:money_tracker/domain/entities/category_entity.dart';

/// A collection of Riverpod providers related to categories.
///
/// These providers expose asynchronous streams of category data fetched
/// from the underlying repository. Separating them here allows the
/// presentation layer to remain agnostic of the data source while still
/// being able to reactively update when the database changes.  When
/// building UI widgets, use [ref.watch] on the appropriate provider
/// (e.g. [allCategoriesProvider] or [expenseCategoriesProvider]) to
/// retrieve the latest values.

/// Fetch all categories from the database.
final allCategoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getAllCategories();
});

/// Fetch only expense categories from the database.
final expenseCategoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getExpenseCategories();
});

/// Fetch only income categories from the database.
final incomeCategoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getIncomeCategories();
});