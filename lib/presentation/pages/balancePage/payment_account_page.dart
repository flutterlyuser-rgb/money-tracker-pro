import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/presentation/widgets/background_container.dart';

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
  /// The type of account being created. Ignored when [account] is
  /// provided (edit mode), in which case the existing account's
  /// properties drive the form.
  final AccountType accountType;
  /// Optional account to edit. When non‑null the page will prefill
  /// existing values and update the account on save instead of
  /// creating a new one.
  final AccountEntity? account;

  const PaymentAccountPage({Key? key, required this.accountType, this.account})
      : super(key: key);

  @override
  ConsumerState<PaymentAccountPage> createState() => _PaymentAccountPageState();
}

class _PaymentAccountPageState extends ConsumerState<PaymentAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String _currency = 'USD';
  bool _reconcile = false;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    // Determine if we are editing an existing account.
    _isEditMode = widget.account != null;
    if (_isEditMode) {
      final acc = widget.account!;
      _nameController.text = acc.name;
      // For credit and liability accounts the balance is stored as
      // negative. Display the absolute value for editing.
      _balanceController.text = acc.initialBalance.abs().toStringAsFixed(0);
      _currency = acc.currency;
      // The reconcile switch currently has no backing storage. Leave
      // it false on edit by default.
      _reconcile = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this account should track income.  For edit mode
    // we derive this from the existing account; otherwise use the
    // selected account type. Payment and online banking accounts
    // track income; the others do not.
    final bool trackIncome = _isEditMode
        ? widget.account!.trackIncome
        : (widget.accountType == AccountType.payment ||
            widget.accountType == AccountType.onlineBanking);

    // Select a colour for the account. Use the existing colour when
    // editing, otherwise choose a default based on the type.
    String defaultColour;
    if (_isEditMode) {
      defaultColour = widget.account!.colorHex;
    } else {
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
    }

    // Determine an appropriate title for the header. In edit mode
    // display the existing account name; otherwise derive from type.
    String pageTitle;
    if (_isEditMode) {
      pageTitle = widget.account!.name;
    } else {
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
    }

    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                // Determine if the account represents debt. In edit mode
                // derive from the existing account; when creating use
                // the selected type.
                bool isDebt;
                if (_isEditMode) {
                  isDebt = widget.account!.initialBalance < 0;
                } else {
                  isDebt = widget.accountType == AccountType.creditCard ||
                      widget.accountType == AccountType.liability;
                }
                final double signedBalance = isDebt ? -value : value;
                if (_isEditMode) {
                  // Update existing account
                  final updated = widget.account!.copyWith(
                    name: name,
                    initialBalance: signedBalance,
                    currentBalance: signedBalance,
                    currency: _currency,
                    colorHex: defaultColour,
                    trackIncome: trackIncome,
                  );
                  await ref.read(accountsProvider.notifier).updateAccount(updated);
                } else {
                  // Create new account
                  final newAccount = AccountEntity(
                    name: name,
                    initialBalance: signedBalance,
                    currentBalance: signedBalance,
                    currency: _currency,
                    colorHex: defaultColour,
                    trackIncome: trackIncome,
                  );
                  await ref.read(accountsProvider.notifier).addAccount(newAccount);
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Center(
                child: Text(
                  _isEditMode ? 'Update' : 'Save',
                  style: const TextStyle(
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