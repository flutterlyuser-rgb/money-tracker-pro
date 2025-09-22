// Import the pure Riverpod package instead of flutter_riverpod. This ensures
// that StateNotifier and related classes are correctly recognized by the
// Dart analyzer even outside of a Flutter environment. The flutter_riverpod
// package is a Flutter-specific wrapper around riverpod that may not be
// available in non-Flutter contexts, which can cause issues such as
// "Classes can only extend other classes" errors when compiling the Dart
// source. Riverpod re-exports StateNotifier from the state_notifier package,
// so importing riverpod gives us access to StateNotifier, StateNotifierProvider,
// StateProvider, FutureProvider, and other riverpod types directly.
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/entities/account_entity.dart';
import '../../data/providers/repository_providers.dart';

/// A [StateNotifier] that manages the list of accounts.
///
/// It loads all accounts from the [AccountRepository] upon construction
/// and exposes methods to create, update and delete accounts. After
/// each mutating operation the accounts are reloaded from the database
/// so that the UI reflects the latest state. When loading accounts
/// the current balance for each account is computed via
/// [AccountRepository.getAccountBalance] and assigned to the
/// `currentBalance` property on the returned [AccountEntity].
class AccountsNotifier extends StateNotifier<List<AccountEntity>> {
  final Ref _ref;

  AccountsNotifier(this._ref) : super([]) {
    _loadAccounts();
  }

  /// Loads all accounts from the repository and computes the current
  /// balance for each account. The resulting list is assigned to
  /// [state], triggering a rebuild of any listening widgets.
  Future<void> _loadAccounts() async {
    final repository = _ref.read(accountRepositoryProvider);
    final accounts = await repository.getAllAccounts();
    // Compute current balance for each account
    final List<AccountEntity> enriched = [];
    for (final account in accounts) {
      final balance = await repository.getAccountBalance(account.id ?? 0);
      enriched.add(account.copyWith(currentBalance: balance));
    }
    state = enriched;
  }

  /// Creates a new account in the database and reloads all accounts.
  Future<void> addAccount(AccountEntity account) async {
    final repository = _ref.read(accountRepositoryProvider);
    await repository.createAccount(account);
    await _loadAccounts();
  }

  /// Updates an existing account and reloads all accounts.
  Future<void> updateAccount(AccountEntity account) async {
    final repository = _ref.read(accountRepositoryProvider);
    await repository.updateAccount(account);
    await _loadAccounts();
  }

  /// Deletes an account by [id] and reloads all accounts.
  Future<void> deleteAccount(int id) async {
    final repository = _ref.read(accountRepositoryProvider);
    await repository.deleteAccount(id);
    await _loadAccounts();
  }
}

/// Provider exposing the list of accounts managed by [AccountsNotifier].
final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<AccountEntity>>(
  (ref) => AccountsNotifier(ref),
);