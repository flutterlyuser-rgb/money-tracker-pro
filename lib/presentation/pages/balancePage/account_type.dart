/// Defines the various account types supported by the balance page.
///
/// Payment accounts track everyday spending and therefore have
/// `trackIncome` set to true.  Credit cards and liabilities represent
/// debt, so their balances are negative by default.  Assets represent
/// positive balances, and online banking is currently treated as a
/// payment account but may be extended to support bank connectivity.
enum AccountType {
  payment,
  creditCard,
  asset,
  liability,
  onlineBanking,
}