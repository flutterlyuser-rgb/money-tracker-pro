import 'package:flutter/material.dart';
import 'package:money_tracker/presentation/widgets/background_container.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/transaction_entity.dart';

/// Screen for entering details of a transaction (either new or edit).
class TransactionPage extends StatefulWidget {
  final CategoryEntity category;
  final TransactionEntity? transaction;
  final DateTime? selectedDate;
  final bool isCalender;

  const TransactionPage({Key? key, required this.category, required this.isCalender,this.transaction, this.selectedDate}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool get isEditMode => widget.transaction != null;
  
   // Checks if we are editing

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Pre-fill the fields if we are in edit mode
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.description ?? '';

    }
          if(widget.isCalender == true){
      _selectedDate = widget.selectedDate!;
      }else if(isEditMode ==true){
        _selectedDate = widget.transaction!.date;
      }else{
        _selectedDate =  DateTime.now();
      }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
     
    // Parse color and icon from the category entity.
    Color parseColor(String hex) {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    }
    final categoryColor = parseColor(category.colorHex);
    final iconData = IconData(
      int.tryParse(category.iconCode) ?? 0xe15b,
      fontFamily: 'MaterialIcons',
    );

    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon and amount entry.
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      iconData,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 32,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildField(
                icon: Icons.calendar_today,
                label: 'Date',
                value:
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              _buildField(
                icon: Icons.account_balance_wallet,
                label: 'Wallet',
                value: 'Default', // Placeholder for wallet selection
                onTap: () {
                  // Wallet selection could be implemented here in the future.
                },
              ),
              const SizedBox(height: 10),
              _buildField(
                icon: Icons.repeat,
                label: 'Repeat',
                value: 'Never', // Placeholder for repeat interval
                onTap: () {
                  // Repeat interval selection can be added here later.
                },
              ),
              const SizedBox(height: 10),
              _buildNoteField(),
              const SizedBox(height: 30),
              // Save button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008CC8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      final amount = double.tryParse(_amountController.text) ?? 0.0;
                      final newTransaction = TransactionEntity(
                        id: isEditMode ? widget.transaction!.id : null,  // Preserve id if editing
                        date: _selectedDate,
                        amount: amount,
                        description: _noteController.text,
                        categoryId: (category.id ?? 0).toString(),
                        isExpense: category.isExpenseCategory,
                        accountId: '1', // Hardcoded for now, may change based on your logic
                        receiptImagePath: null,
                        location: null,
                        isRecurring: false,
                        recurringPattern: null,
                        createdAt: DateTime.now(),
                      );
                      Navigator.of(context).pop(newTransaction);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.note, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _noteController,
              maxLines: null,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Note',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
