// Use the core Riverpod package instead of flutter_riverpod. This ensures that
// StateNotifier and other provider classes are properly resolved when the
// Dart code is compiled outside of a Flutter context. See the notes in
// account_providers.dart for more details.
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:money_tracker/data/providers/repository_providers.dart';
import 'package:money_tracker/domain/entities/transaction_entity.dart';

/// A [StateNotifier] that manages a list of recent transactions.
///
/// This notifier encapsulates the logic for loading, adding, updating
/// and deleting transactions. It leverages the [transactionRepositoryProvider]
/// from the data layer to perform the underlying database operations.
/// When the internal list changes, the notifier refreshes its state so
/// that any listening UI can rebuild with the latest information.
class TransactionsNotifier extends StateNotifier<AsyncValue<List<TransactionEntity>>> {
  TransactionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadRecent();
  }

  final Ref ref;

  /// Loads the most recent transactions from the repository.
  ///
  /// The optional [limit] parameter allows callers to specify how many
  /// transactions to retrieve. If omitted the default of 20 is used.
  Future<void> _loadRecent([int limit = 20]) async {
    final repo = ref.read(transactionRepositoryProvider);
    try {
      final transactions = await repo.getRecentTransactions(limit);
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Persists a new transaction and refreshes the transaction list.
  Future<void> addTransaction(TransactionEntity entity) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.createTransaction(entity);
    await _loadRecent();
  }

  /// Deletes a transaction by its [id] and refreshes the transaction list.
  Future<void> deleteTransaction(int id) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.deleteTransaction(id);
    await _loadRecent();
  }

  /// Updates an existing transaction and refreshes the transaction list.
  Future<void> updateTransaction(TransactionEntity entity) async {
    final repo = ref.read(transactionRepositoryProvider);
    await repo.updateTransaction(entity);
    await _loadRecent();
  }
}

/// A Riverpod provider that exposes the [TransactionsNotifier].
///
/// Listen to this provider in your UI to build reactively based on
/// [AsyncValue] states of transaction data. For example, call
/// `ref.watch(transactionsProvider)` in a ConsumerWidget to retrieve
/// the current transaction list.
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<TransactionEntity>>>(
  (ref) => TransactionsNotifier(ref),
);