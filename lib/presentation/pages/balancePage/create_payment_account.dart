import 'package:flutter/material.dart';
import 'currency_page.dart';

/// Page for creating a new payment account.  This form replicates
/// the layout shown in the provided screenshots with fields for
/// entering a name, starting balance, selecting a currency, and
/// toggles for connecting a bank account and reconciling.  A
/// description field is provided at the bottom.
class CreatePaymentAccountPage extends StatefulWidget {
  const CreatePaymentAccountPage({super.key});

  @override
  State<CreatePaymentAccountPage> createState() => _CreatePaymentAccountPageState();
}

class _CreatePaymentAccountPageState extends State<CreatePaymentAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController(text: '0');
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
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        title: const Text('Payment Account'),
        actions: [
          TextButton(
            onPressed: () {
              // In a real app, saving would persist the new account.
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 28,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Balance entry row.
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Balance'),
            trailing: SizedBox(
              width: 120,
              child: TextField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          // Currency selection row.
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Currency'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_currency),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => CurrencyPage(selected: _currency),
                ),
              );
              if (result != null) {
                setState(() {
                  _currency = result;
                });
              }
            },
          ),
          const Divider(),
          // Connect Bank Account row.  In the screenshot this uses an
          // arrow rather than a switch.  Tapping it shows a SnackBar.
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Connect Bank Account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connect Bank Account is not implemented.')),
              );
            },
          ),
          const Divider(),
          // Reconcile toggle row.
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reconcile'),
            value: _reconcile,
            onChanged: (val) {
              setState(() {
                _reconcile = val;
              });
            },
          ),
          const Divider(),
          // Description field.
          TextField(
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}