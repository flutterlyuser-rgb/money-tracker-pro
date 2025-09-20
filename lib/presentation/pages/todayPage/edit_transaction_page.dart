import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/domain/entities/account_entity.dart';
import 'package:money_tracker/presentation/providers/account_providers.dart';
import 'package:money_tracker/presentation/widgets/background_container.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/transaction_providers.dart';
import 'category_selection_page.dart';

/// Screen for editing an existing transaction.
///
/// The form is pre-filled with the original transaction's values and
/// allows modification of the amount, date, description and, for
/// expense transactions, the category. When saved, the transaction is
/// updated via the [transactionsProvider] and the page pops.
class EditTransactionPage extends ConsumerStatefulWidget {
  /// The transaction to edit.
  final TransactionEntity transaction;

  /// The category associated with the transaction. This is passed in
  /// separately because looking up the category entity in the parent
  /// widget avoids redundant work in the edit page.
  final CategoryEntity category;

  const EditTransactionPage({
    Key? key,
    required this.transaction,
    required this.category,
  }) : super(key: key);

  @override
  ConsumerState<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends ConsumerState<EditTransactionPage> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate = DateTime.now();
  late CategoryEntity _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing transaction values.
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.description ?? '',
    );
   // _selectedDate = widget.transaction.date;
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Parses a hex color string into a [Color]. Falls back to white
  /// with full opacity if parsing fails.
  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute color and icon for the currently selected category.
    final accounts = ref.watch(accountsProvider);
    // Classify accounts into payment (trackIncome true) and credit (trackIncome false)
    final paymentAccounts = accounts.where((acc) => acc.trackIncome).toList();
    
    

    
    final categoryColor = _parseColor(_selectedCategory.colorHex);
    final iconData = IconData(
      int.tryParse(_selectedCategory.iconCode) ?? 0xe15b,
      fontFamily: 'MaterialIcons',
    );
    return BackgroundContainer(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:  Colors.transparent,
          title: const Text('Add Transaction'),
        ),
        backgroundColor:Colors.transparent,

        

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
              // Category field: allow editing for expense transactions.
              _buildCategoryField(),
              const SizedBox(height: 10),
              // Date field.
              _buildDateField(),
              const SizedBox(height: 10),
              // Note field.
              _buildNoteField(),
              const SizedBox(height: 30),
              // Save button.
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
                    onPressed: _save,
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

  /// Builds a row that shows and optionally allows selection of a category.
  /// For expense transactions, this row is tappable and opens the
  /// [CategorySelectionPage] to choose a different category. For income
  /// transactions, the row is displayed but non-interactive.
  
  Widget _buildCategoryField() {
    final isExpense = _selectedCategory.isExpenseCategory;
    return InkWell(
      onTap: isExpense
          ? () async {
              // Only allow category changes for expense transactions. Use
              // CategorySelectionPage which shows expense categories.
              final result = await Navigator.push<CategoryEntity?>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategorySelectionPage(),
                ),
              );
              if (result != null) {
                setState(() {
                  _selectedCategory = result;
                });
              }
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              iconDataFromCategory(_selectedCategory),
              color: Colors.white70,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Category',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(
              _selectedCategory.name,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            if (isExpense)
              const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  /// Builds a row that displays and allows editing of the transaction date.
  Widget _buildDateField() {
    return InkWell(
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white70),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Date',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(
              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  /// Builds the note entry field.
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

  /// Retrieves the icon for the given [category] and constructs an [IconData].
  IconData iconDataFromCategory(CategoryEntity category) {
    return IconData(
      int.tryParse(category.iconCode) ?? 0xe15b,
      fontFamily: 'MaterialIcons',
    );
  }

  /// Handles saving the edited transaction. Builds a new entity based on
  /// the current form values, updates it via the provider and then
  /// navigates back to the previous screen.
  void _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final updatedTransaction = TransactionEntity(
      id: widget.transaction.id,
      date: _selectedDate,
      amount: amount,
      description: _noteController.text,
      categoryId: (_selectedCategory.id ?? 0).toString(),
      isExpense: _selectedCategory.isExpenseCategory,
      accountId: widget.transaction.accountId,
      receiptImagePath: widget.transaction.receiptImagePath,
      location: widget.transaction.location,
      isRecurring: widget.transaction.isRecurring,
      recurringPattern: widget.transaction.recurringPattern,
      createdAt: widget.transaction.createdAt,
    );
    await ref.read(transactionsProvider.notifier).updateTransaction(updatedTransaction);
    // Pop and return the updated transaction. Returning it isn't strictly
    // necessary but may be useful for callers.
    Navigator.of(context).pop(updatedTransaction);
  }
}