import 'package:flutter/material.dart';
import 'create_payment_account.dart';

/// Distinguishes between payment accounts and other types of assets.
enum AccountType { payment, asset }

/// Simple model representing either a payment account or an asset.  The
/// balance sign determines whether the entry is positive (asset) or
/// negative (liability).  For example, a wallet with -4055 denotes
/// money owed.
class Account {
  final String name;
  final double balance;
  final AccountType type;

  Account({required this.name, required this.balance, required this.type});
}

/// The main balance page shown in the screenshots.  Displays a
/// summary bar, grouped lists of accounts, and an optional edit mode
/// with deletion and reordering.  A modal sheet allows creation of
/// new accounts.  All visual styling attempts to mirror the look
/// captured in the photos provided by the user.
class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  /// Hard‑coded data representing the accounts shown in the sample.
  /// Negative balances appear in blue while positive balances appear in
  /// yellow.  In a real app this list would be loaded from a
  /// database.
  final List<Account> _accounts = [
    Account(name: 'Wallet', balance: -4055, type: AccountType.payment),
    Account(name: 'essam', balance: -1300, type: AccountType.payment),
    Account(name: 'me (sal)', balance: 200, type: AccountType.asset),
  ];

  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final negativeTotal = _accounts
        .where((a) => a.balance < 0)
        .fold<double>(0, (sum, a) => sum + a.balance);
    final positiveTotal = _accounts
        .where((a) => a.balance >= 0)
        .fold<double>(0, (sum, a) => sum + a.balance);

    return Scaffold(
      appBar: AppBar(
        leading: _editing
            ? TextButton(
                onPressed: _showAddOptions,
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () {
                  // In the original app this might trigger an export
                  // function.  Here it simply does nothing.
                },
              ),
        title: const Text('Balance'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _editing = !_editing;
              });
            },
            child: Text(
              _editing ? 'Done' : 'Edit',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSummary(negativeTotal, positiveTotal),
          Expanded(
            child: ListView(
              children: [
                _buildSectionHeader('Payment Accounts', negativeTotal),
                ..._buildAccountList(AccountType.payment),
                _buildSectionHeader('Other Assets', positiveTotal),
                ..._buildAccountList(AccountType.asset),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildOnlineBankingTile(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Creates a summary bar composed of two columns with vertical bars
  /// whose heights reflect the magnitude of the negative and positive
  /// totals.  The colours and layout resemble the screenshot: blue for
  /// debts and yellow for assets.
  Widget _buildTopSummary(double negative, double positive) {
    final total = negative.abs() + positive;
    final negRatio = total == 0 ? 0.5 : negative.abs() / total;
    final posRatio = total == 0 ? 0.5 : positive / total;
    const double maxBarHeight = 32.0;
    final double negHeight = maxBarHeight * negRatio;
    final double posHeight = maxBarHeight * posRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatCurrency(negative),
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: negHeight,
                color: Colors.cyanAccent,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(positive),
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: posHeight,
                color: Colors.amberAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Renders a header for a section (payment accounts or other
  /// assets).  The title is capitalised and the subtotal is shown on
  /// the right.
  Widget _buildSectionHeader(String title, double subtotal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            _formatCurrency(subtotal),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of accounts for a given type.  In edit mode a
  /// reorderable list is presented with a red minus button for
  /// removal and a drag handle.  Outside of edit mode simple list
  /// tiles are shown.
  List<Widget> _buildAccountList(AccountType type) {
    final accounts = _accounts.where((a) => a.type == type).toList();
    if (_editing) {
      return [
        ReorderableListView.builder(
          key: ValueKey(type),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: accounts.length,
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final account = accounts.removeAt(oldIndex);
              accounts.insert(newIndex, account);
              // Now update the original list positions.
              final originalIndices = _accounts
                  .asMap()
                  .entries
                  .where((e) => e.value.type == type)
                  .map((e) => e.key)
                  .toList();
              final globalOld = originalIndices[oldIndex];
              final globalNew = originalIndices[newIndex];
              final moved = _accounts.removeAt(globalOld);
              _accounts.insert(globalNew, moved);
            });
          },
          itemBuilder: (context, index) {
            final account = accounts[index];
            return Container(
              key: ValueKey(account.name),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Minus delete button.
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _accounts.removeWhere((a) => a == account);
                      });
                    },
                  ),
                  // Icon representing the account type.
                  Icon(
                    account.type == AccountType.payment
                        ? Icons.account_balance_wallet
                        : Icons.home,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 12),
                  // Name text.
                  Expanded(
                    child: Text(
                      account.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Amount.
                  Text(
                    _formatCurrency(account.balance),
                    style: TextStyle(
                      color: account.balance < 0
                          ? Colors.cyanAccent
                          : Colors.amberAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Drag handle for reorder.
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        ),
      ];
    } else {
      return [
        for (final account in accounts)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(
              account.type == AccountType.payment
                  ? Icons.account_balance_wallet
                  : Icons.home,
              color: Colors.white70,
            ),
            title: Text(
              account.name,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: Text(
              _formatCurrency(account.balance),
              style: TextStyle(
                color: account.balance < 0
                    ? Colors.cyanAccent
                    : Colors.amberAccent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              // Placeholder for tapping the account when not editing.
            },
          ),
      ];
    }
  }

  /// Formats a number into a currency string with commas and a dollar
  /// symbol.  Negative values include a leading minus sign.  For
  /// example: -4055 becomes '-$4,055' and 200 becomes '$200'.
  String _formatCurrency(double value) {
    final sign = value < 0 ? '-' : '';
    final absVal = value.abs().round();
    final digits = absVal.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final idxFromRight = digits.length - i - 1;
      buffer.write(digits[i]);
      if (idxFromRight % 3 == 0 && i != digits.length - 1) {
        buffer.write(',');
      }
    }
    // Concatenate using plain strings to avoid interpolation issues in patch.
    return sign + '\$' + buffer.toString();
  }

  /// Displays the online banking hint tile.  When tapped, it
  /// currently shows a SnackBar indicating the feature is not
  /// implemented.  In the original screenshot this card explains
  /// that the app can connect to your bank to download transactions.
  Widget _buildOnlineBankingTile() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Online banking is not implemented.')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Online Banking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Money Pro will connect to your bank and download your transactions',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constructs the bottom navigation bar.  Only the Balance tab is
  /// functional; other tabs display SnackBars indicating they are
  /// placeholders.
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (index) {
        if (index != 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tab $index not implemented.')),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Today',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.balance),
          label: 'Balance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'More',
        ),
      ],
    );
  }

  /// Presents a modal bottom sheet with options to add new items.  The
  /// Payment Account option opens the `CreatePaymentAccountPage`.
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetOption('Payment Account', () {
              Navigator.pop(ctx);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreatePaymentAccountPage(),
                ),
              );
            }),
            _buildSheetOption('Credit Card', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Credit cards not implemented.')),
              );
            }),
            _buildSheetOption('Asset', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assets not implemented.')),
              );
            }),
            _buildSheetOption('Liability', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Liabilities not implemented.')),
              );
            }),
            _buildSheetOption('Online Banking', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Online banking not implemented.')),
              );
            }),
            _buildSheetOption('Cancel', () {
              Navigator.pop(ctx);
            }),
          ],
        );
      },
    );
  }

  /// Helper to construct an entry in the add sheet.  Each entry is
  /// centre aligned as in the screenshot.
  Widget _buildSheetOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      onTap: onTap,
    );
  }
}