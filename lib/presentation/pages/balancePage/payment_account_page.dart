import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/account_entity.dart';
import '../../providers/account_providers.dart';
import 'currency_selection_page.dart';
import 'account_type.dart';

/// A form used to create a new account of a given [AccountType].  The
/// layout follows the design screenshots: a header with a cancel
/// button, a large icon, a name input, and rows for balance,
/// currency, bank connection and reconcile.  On save the account is
/// persisted via [accountsProvider].
class PaymentAccountPage extends ConsumerStatefulWidget {
  final AccountType accountType;
  const PaymentAccountPage({Key? key, required this.accountType})
      : super(key: key);

  @override
  ConsumerState<PaymentAccountPage> createState() => _PaymentAccountPageState();
}

class _PaymentAccountPageState extends ConsumerState<PaymentAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String _currency = 'USD';
  bool _reconcile = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this account should track income.  Payment and
    // onlineBanking accounts track income; the others do not.
    final bool trackIncome = widget.accountType == AccountType.payment ||
        widget.accountType == AccountType.onlineBanking;
    // Select a default colour for the account based on its type.
    String defaultColour;
    switch (widget.accountType) {
      case AccountType.payment:
        defaultColour = '#2196F3'; // blue
        break;
      case AccountType.creditCard:
        defaultColour = '#E53935'; // red
        break;
      case AccountType.asset:
        defaultColour = '#4CAF50'; // green
        break;
      case AccountType.liability:
        defaultColour = '#FFB300'; // amber
        break;
      case AccountType.onlineBanking:
        defaultColour = '#2196F3'; // same as payment for now
        break;
    }

    // Determine appropriate title for the header based on type.
    String pageTitle;
    switch (widget.accountType) {
      case AccountType.payment:
        pageTitle = 'Payment Account';
        break;
      case AccountType.creditCard:
        pageTitle = 'Credit Card';
        break;
      case AccountType.asset:
        pageTitle = 'Asset';
        break;
      case AccountType.liability:
        pageTitle = 'Liability';
        break;
      case AccountType.onlineBanking:
        pageTitle = 'Online Banking';
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Center(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        title: Text(
          pageTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a name'),
                  ),
                );
                return;
              }
              final balanceStr = _balanceController.text.trim();
              final double value = double.tryParse(balanceStr.isEmpty ? '0' : balanceStr) ?? 0.0;
              // For credit and liability accounts, treat the value as negative.
              final bool isDebt = widget.accountType == AccountType.creditCard ||
                  widget.accountType == AccountType.liability;
              final double signedBalance = isDebt ? -value : value;
              final newAccount = AccountEntity(
                name: name,
                initialBalance: signedBalance,
                currentBalance: signedBalance,
                currency: _currency,
                colorHex: defaultColour,
                trackIncome: trackIncome,
              );
              await ref.read(accountsProvider.notifier).addAccount(newAccount);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Center(
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large icon and name input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white54, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Balance row
            _buildRow(
              label: 'Balance',
              child: Flexible(
                child: TextField(
                  controller: _balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            // Currency selection row
            _buildRow(
              label: 'Currency',
              child: GestureDetector(
                onTap: () async {
                  final selected = await Navigator.push<String?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CurrencySelectionPage(selected: _currency),
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      _currency = selected;
                    });
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            // Connect bank account row (non interactive placeholder)
            _buildRow(
              label: 'Connect Bank Account',
              child: const SizedBox.shrink(),
            ),
            const Divider(color: Colors.white24),
            // Reconcile row with a switch
            _buildRow(
              label: 'Reconcile',
              child: Switch(
                value: _reconcile,
                onChanged: (value) {
                  setState(() {
                    _reconcile = value;
                  });
                },
                activeColor: const Color(0xFF00A3E0),
              ),
            ),
            const Divider(color: Colors.white24),
            // Optional description row (disabled for simplicity)
            _buildRow(
              label: 'Description',
              child: const SizedBox.shrink(),
            ),
            const Divider(color: Colors.white24),
          ],
        ),
      ),
    );
  }

  /// Helper that builds a row with a label on the left and an arbitrary
  /// widget on the right.  Used for the balance, currency and other
  /// fields to keep consistent spacing and alignment.
  Widget _buildRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 120, child: child),
        ],
      ),
    );
  }
}