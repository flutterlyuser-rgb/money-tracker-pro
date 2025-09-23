import 'package:money_tracker/domain/entities/account_entity.dart';

abstract class AccountRepository {
  Future<int> createAccount(AccountEntity account); // ✅ Change to AccountEntity
  Future<List<AccountEntity>> getAllAccounts(); // ✅ Change to AccountEntity
  Future<AccountEntity?> getAccountById(int id); // ✅ Change to AccountEntity
  Future<void> updateAccount(AccountEntity account); // ✅ Change to AccountEntity
  Future<void> deleteAccount(int id);
  Future<double> getAccountBalance(int accountId);
  Future<int> getAccountsCount();
}