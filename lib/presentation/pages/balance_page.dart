import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account_entity.dart';
import '../providers/account_providers.dart';

/// Displays a list of accounts with their current balances.
///
/// This page watches the [accountsProvider] and rebuilds whenever
/// the list of accounts changes. It also provides a floating action
/// button that navigates to [AddAccountPage] for creating new
/// accounts. Each account is rendered as a card showing its name,
/// current balance and a color indicator derived from the
/// `colorHex` property.
class BalancePage extends ConsumerWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    // Classify accounts into payment (trackIncome true) and credit (trackIncome false)
    final paymentAccounts =
        accounts.where((acc) => acc.trackIncome).toList();
    final creditAccounts =
        accounts.where((acc) => !acc.trackIncome).toList();
    // Totals for assets (payment) and credits (absolute values)
    double totalAssets = 0;
    for (final acc in paymentAccounts) {
      totalAssets += acc.currentBalance;
    }
    double totalCredits = 0;
    for (final acc in creditAccounts) {
      // Use absolute value for credit cards
      totalCredits += acc.currentBalance.abs();
    }
    final double overall = totalAssets - totalCredits;
    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        title: const Text('Balance'),
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            tooltip: 'Edit accounts',
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
                  // Summary bars showing assets vs credits
                  _buildSummaryBars(totalAssets: totalAssets, totalCredits: totalCredits),
                  const SizedBox(height: 20),
                  // Payment accounts section
                  if (paymentAccounts.isNotEmpty) ...[
                    _buildSectionHeader(
                      title: 'PAYMENT ACCOUNTS',
                      total: totalAssets,
                    ),
                    const SizedBox(height: 4),
                    ...paymentAccounts.map((acc) => _buildAccountRow(acc)).toList(),
                    const SizedBox(height: 20),
                  ],
                  // Credit cards section
                  if (creditAccounts.isNotEmpty) ...[
                    _buildSectionHeader(
                      title: 'CREDIT CARDS',
                      total: totalCredits,
                      isCredit: true,
                    ),
                    const SizedBox(height: 4),
                    ...creditAccounts.map((acc) => _buildAccountRow(acc, isCredit: true)).toList(),
                    const SizedBox(height: 20),
                  ],
                  // Overall total
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'TOTAL: \$${overall.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAccountPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF008CC8),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the summary bar section comparing assets and credits.
  Widget _buildSummaryBars({
    required double totalAssets,
    required double totalCredits,
  }) {
    final double total = totalAssets + totalCredits;
    // Avoid division by zero
    final double assetRatio = total > 0 ? totalAssets / total : 0;
    final double creditRatio = total > 0 ? totalCredits / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Assets bar
        Row(
          children: [
            Container(
              width: 80,
              child: const Text(
                '\$ Assets',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: assetRatio,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${totalAssets.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Credits bar
        Row(
          children: [
            Container(
              width: 80,
              child: const Text(
                '\$ Credit',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: creditRatio,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${totalCredits.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a section header with the section title and total.
  Widget _buildSectionHeader({
    required String title,
    required double total,
    bool isCredit = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          (isCredit ? '-\$' : '\$') + total.toStringAsFixed(0),
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  /// Builds a row for a single account entry.
  Widget _buildAccountRow(AccountEntity account, {bool isCredit = false}) {
    // Determine icon based on account type
    IconData iconData;
    if (isCredit) {
      iconData = Icons.credit_card;
    } else {
      iconData = Icons.account_balance_wallet;
    }
    // Parse color
    Color parseColor(String hex) {
      var hexValue = hex.replaceFirst('#', '');
      if (hexValue.length == 6) hexValue = 'FF$hexValue';
      return Color(int.parse(hexValue, radix: 16));
    }
    final color = parseColor(account.colorHex);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(iconData, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              account.name,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          Text(
            isCredit
                ? '-\$${account.currentBalance.abs().toStringAsFixed(0)}'
                : '\$${account.currentBalance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page for creating a new [AccountEntity].
///
/// It collects the account name, initial balance, currency and an optional
/// tracking flag from the user. When the user taps the save button the
/// account is persisted via [AccountsNotifier.addAccount] and the page
/// pops. A simple colour picker is provided to choose the account
/// colour from a predefined palette.
class AddAccountPage extends ConsumerStatefulWidget {
  const AddAccountPage({super.key});

  @override
  ConsumerState<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends ConsumerState<AddAccountPage> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _currency = 'USD';
  bool _trackIncome = true;
  // Predefined colours for user selection
  final List<String> _colours = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
    '#FFEB3B', // Yellow
    '#795548', // Brown
  ];
  String _selectedColour = '#2196F3';

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        title: const Text('Add Account'),
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Account Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Currency dropdown
            DropdownButtonFormField<String>(
              value: _currency,
              dropdownColor: const Color(0xFF01304B),
              decoration: const InputDecoration(
                labelText: 'Currency',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'EUR',
                  child: Text('EUR', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'GBP',
                  child: Text('GBP', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'YER',
                  child: Text('YER', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _currency = value ?? 'USD';
                });
              },
            ),
            const SizedBox(height: 20),
            // Colour picker
            const Text(
              'Colour',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _colours.map((hex) {
                Color parseColor(String hex) {
                  var val = hex.replaceFirst('#', '');
                  if (val.length == 6) val = 'FF$val';
                  return Color(int.parse(val, radix: 16));
                }
                final colour = parseColor(hex);
                final selected = _selectedColour == hex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColour = hex;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colour,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Track income switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Track Income',
                  style: TextStyle(color: Colors.white70),
                ),
                Switch(
                  value: _trackIncome,
                  onChanged: (val) {
                    setState(() {
                      _trackIncome = val;
                    });
                  },
                  activeColor: const Color(0xFF008CC8),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008CC8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final balance = double.tryParse(_balanceController.text) ?? 0.0;
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter an account name')),
                    );
                    return;
                  }
                  final newAccount = AccountEntity(
                    name: name,
                    initialBalance: balance,
                    currency: _currency,
                    colorHex: _selectedColour,
                    trackIncome: _trackIncome,
                    currentBalance: balance,
                  );
                  // Persist via provider
                  await ref.read(accountsProvider.notifier).addAccount(newAccount);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}