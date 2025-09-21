import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the account entity and provider so we can watch and modify
// the list of accounts. AccountEntity provides helper methods for
// retrieving the balance and colour.
import '../../../domain/entities/account_entity.dart';
import '../../providers/account_providers.dart';

// Import our local pages for creating new accounts and selecting currencies.
import 'payment_account_page.dart';
import 'account_type.dart';

/// Enumerates the high level types of accounts that can be created from
/// the add menu.  These map roughly onto the options shown in the design
/// images.  Payment accounts track everyday spending, credit cards and
/// liabilities represent debt, and assets track positive balances.  The
/// onlineBanking type is currently a placeholder which behaves like an
/// asset but could be extended in the future.

/// The main balance page of the application.  This widget displays the
/// current totals for your accounts as well as a breakdown of payment
/// accounts (those that track income) and other assets.  An edit mode
/// allows you to delete accounts or add new ones via a modal sheet.
class BalancePage extends ConsumerStatefulWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  ConsumerState<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends ConsumerState<BalancePage> {
  // Whether the page is currently in edit mode.  In edit mode the
  // interface shows delete controls and explanatory text.  Outside of
  // edit mode it shows an "Edit" button and the online banking card.
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    // Listen to the list of accounts from the provider.  Whenever the
    // underlying data changes the UI will rebuild.  We classify
    // accounts into those that track income (payment accounts) and
    // those that do not (other assets).  Negative balances are handled
    // natively by the AccountEntity.currentBalance value.
    final accounts = ref.watch(accountsProvider);
    final paymentAccounts = accounts.where((acc) => acc.trackIncome).toList();
    final otherAccounts = accounts.where((acc) => !acc.trackIncome).toList();

    // Compute totals for each category.  Payment accounts can have
    // negative balances (e.g. cash on hand) while other assets may be
    // positive.  The sums are displayed in the coloured bars at the top
    // of the page.  We cast to double to ensure the fold is typed.
    final double paymentTotal = paymentAccounts.fold(
        0.0, (double sum, acc) => sum + acc.currentBalance);
    final double otherTotal = otherAccounts.fold(
        0.0, (double sum, acc) => sum + acc.currentBalance);

    // Determine sign prefixes for display.  We explicitly prefix
    // negatives with a minus sign and positives with nothing (the
    // currency symbol is prefixed separately).  The images use a
    // hyphen in front of negative values and none for zero.
    String formatAmount(double amount) {
      // Format without decimal places and with thousand separators.
      final String formatted = amount.abs().toStringAsFixed(0);
      return (amount < 0 ? '-\$' : '\$') + formatted;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
        // Show either the edit controls or the normal controls depending
        // on the mode.  In normal mode there is a leading arrow and an
        // "Edit" action; in edit mode the leading becomes "Add" and
        // trailing becomes "Done".
        leading: GestureDetector(
          onTap: () {
            if (_isEditing) {
              // In edit mode the leading acts as an Add action.
              _showAddMenu(context);
            } else {
              // Outside of edit mode we simply pop back if possible.
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _isEditing ? 'Add' : '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        title: const Text('Balance'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  _isEditing ? 'Done' : 'Edit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: accounts.isEmpty
          ? const Center(
              child: Text(
                'No accounts found',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top totals section: two coloured indicators with
                  // corresponding sums.  We use SizedBox to add vertical
                  // spacing similar to the screenshots.
                  Row(
                    children: [
                      // Blue line for payment accounts
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A3E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatAmount(paymentTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Yellow line for other assets
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatAmount(otherTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Payment accounts section
                  if (paymentAccounts.isNotEmpty) ...[
                    _buildSectionHeader(
                      title: 'PAYMENT ACCOUNTS',
                      total: paymentTotal,
                    ),
                    const SizedBox(height: 4),
                    ...paymentAccounts.map((acc) => _buildAccountRow(acc, isOther: false)).toList(),
                    const SizedBox(height: 20),
                  ],
                  // Other assets section
                  if (otherAccounts.isNotEmpty) ...[
                    _buildSectionHeader(
                      title: 'OTHER ASSETS',
                      total: otherTotal,
                    ),
                    const SizedBox(height: 4),
                    ...otherAccounts.map((acc) => _buildAccountRow(acc, isOther: true)).toList(),
                    const SizedBox(height: 20),
                  ],
                  // Additional content
                  if (_isEditing) ...[
                    // Explanatory text shown in edit mode.  This
                    // replicates the help text from the design that
                    // explains the difference between payment accounts
                    // and credit cards.  The text is kept white70 to
                    // reduce emphasis compared to the primary content.
                    const Text(
                      'Payment Accounts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Payment account is an account used in everyday payments, e.g. wallet, e‑money, debit card, settlement bank account (except for credit cards).',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Credit Cards',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Credit card accounts show your current debt to the bank. Income transactions assigned to credit cards reduce your debt.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ] else ...[
                    // Card for online banking shown in normal mode.  It
                    // encourages users to connect a bank account.  We
                    // display a simple icon and descriptive text.
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.lightbulb_outline, color: Colors.white70),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Online Banking',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Money Pro will connect to your bank and download your transactions',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  /// Builds the section header row.  Displays the section title and
  /// associated total on a semi‑transparent grey bar.  Negative totals
  /// are prefixed with a minus sign.  The style loosely mirrors the
  /// screenshots provided by the user.
  Widget _buildSectionHeader({required String title, required double total}) {
    String formattedTotal = (total < 0 ? '-\$' : '\$') + total.abs().toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          Text(
            formattedTotal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an individual account row.  When the page is in edit mode
  /// the row includes a red delete button on the left and a grey drag
  /// handle on the right.  Otherwise it simply shows the account
  /// details.  The [isOther] flag determines which icon to display
  /// (wallet for payment accounts, home for other assets).
  Widget _buildAccountRow(AccountEntity account, {required bool isOther}) {
    // Determine the appropriate icon based on account type.  Use a
    // wallet for payment accounts and a home for other assets.  If
    // additional account types are added in the future this can be
    // expanded.
    final iconData = isOther ? Icons.home : Icons.account_balance_wallet;

    // Format the current balance with a minus sign for negatives.
    final String formattedBalance = (account.currentBalance < 0
            ? '-\$'
            : '\$') +
        account.currentBalance.abs().toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          if (_isEditing) ...[
            // Delete control
            GestureDetector(
              onTap: () async {
                if (account.id != null) {
                  await ref
                      .read(accountsProvider.notifier)
                      .deleteAccount(account.id!);
                }
              },
              child: const Icon(
                Icons.remove_circle,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Icon(iconData, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              account.name,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            formattedBalance,
            style: TextStyle(
              color: account.currentBalance < 0
                  ? const Color(0xFF00BCD4)
                  : const Color(0xFF4CAF50),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(width: 12),
            const Icon(
              Icons.menu,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  /// Displays the modal bottom sheet used to select which type of
  /// account to add.  Options mirror those in the reference images.
  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddOption(
                ctx,
                label: 'Payment Account',
                type: AccountType.payment,
              ),
              _buildAddOption(
                ctx,
                label: 'Credit Card',
                type: AccountType.creditCard,
              ),
              _buildAddOption(
                ctx,
                label: 'Asset',
                type: AccountType.asset,
              ),
              _buildAddOption(
                ctx,
                label: 'Liability',
                type: AccountType.liability,
              ),
              _buildAddOption(
                ctx,
                label: 'Online Banking',
                type: AccountType.onlineBanking,
              ),
              ListTile(
                title: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Helper to build each option in the add account modal sheet.  When
  /// selected this pushes the [PaymentAccountPage] configured for the
  /// appropriate [AccountType].
  Widget _buildAddOption(BuildContext ctx,
      {required String label, required AccountType type}) {
    return ListTile(
      title: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () {
        Navigator.of(ctx).pop();
        // Navigate to the account creation page.  We pass the type
        // so the form knows how to preconfigure itself (e.g. whether
        // to track income or not).  Payment accounts and online banking
        // accounts track income; others do not.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentAccountPage(accountType: type),
          ),
        );
      },
    );
  }
}