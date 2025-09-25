import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/budget_providers.dart';
import '../providers/category_providers.dart';

/// Displays the list of budgets and their progress.
///
/// Budgets are obtained from [budgetsProvider] and enriched with
/// spending data. Each budget is shown with its category name,
/// allocated amount, spent amount, remaining amount and a progress
/// indicator. A floating action button opens [AddBudgetPage] to create
/// a new budget.
class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
      ),
      body: budgets.isEmpty
          ? const Center(
              child: Text(
                'No budgets created',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final spent = budget.spentAmount;
                final remaining = budget.remainingAmount;
                final percent = budget.percentageSpent.clamp(0.0, 1.0);
                return Card(
                  color: const Color(0xFF014B6D),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                budget.categoryName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '\$${spent.toStringAsFixed(0)} / \$${budget.amount.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percent >= 1.0
                                ? Colors.red
                                : percent >= budget.alertThreshold
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining: \$${remaining.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              budget.periodText,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBudgetPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF008CC8),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Page for creating a new [BudgetEntity].
///
/// It allows the user to select a category, define a budget amount,
/// choose a period (monthly, weekly or yearly) and pick start and end
/// dates. When saved, the budget is persisted via
/// [BudgetsNotifier.addBudget] and the page pops.
class AddBudgetPage extends ConsumerStatefulWidget {
  const AddBudgetPage({super.key});

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  CategoryEntity? _selectedCategory;
  final _amountController = TextEditingController();
  int _period = 0; // 0 = monthly, 1 = weekly, 2 = yearly
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Computes an end date based on the selected period and the start date.
  DateTime _computeEndDate(DateTime start, int period) {
    switch (period) {
      case 0: // monthly
        return DateTime(start.year, start.month + 1, start.day);
      case 1: // weekly
        return start.add(const Duration(days: 7));
      case 2: // yearly
        return DateTime(start.year + 1, start.month, start.day);
      default:
        return start.add(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    List<CategoryEntity> categories = [];
    categoriesAsync.when(
      data: (data) => categories = data,
      loading: () {},
      error: (_, __) {},
    );
    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        title: const Text('Add Budget'),
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category dropdown
            DropdownButtonFormField<CategoryEntity>(
              value: _selectedCategory,
              dropdownColor: const Color(0xFF01304B),
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              items: categories.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    c.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
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
            // Period dropdown
            DropdownButtonFormField<int>(
              value: _period,
              dropdownColor: const Color(0xFF01304B),
              decoration: const InputDecoration(
                labelText: 'Period',
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
                  value: 0,
                  child: Text('Monthly', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Weekly', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('Yearly', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _period = val ?? 0;
                  // Recompute end date when period changes
                  _endDate = _computeEndDate(_startDate, _period);
                });
              },
            ),
            const SizedBox(height: 20),
            // Start date field
            _buildDateField(
              context: context,
              label: 'Start Date',
              date: _startDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked;
                    _endDate = _computeEndDate(_startDate, _period);
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            // End date field
            _buildDateField(
              context: context,
              label: 'End Date',
              date: _endDate,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
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
                  if (_selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a category')),
                    );
                    return;
                  }
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter a valid amount')),
                    );
                    return;
                  }
                  final newBudget = BudgetEntity(
                    categoryId: (_selectedCategory!.id ?? 0).toString(),
                    categoryName: _selectedCategory!.name,
                    amount: amount,
                    period: _period,
                    startDate: _startDate,
                    endDate: _endDate,
                    alertThreshold: 0.9,
                  );
                  await ref.read(budgetsProvider.notifier).addBudget(newBudget);
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

  /// Builds a tappable field for displaying and selecting a date.
  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}