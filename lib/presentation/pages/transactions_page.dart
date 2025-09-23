import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/account_entity.dart';
import '../providers/transaction_providers.dart';
import '../providers/category_providers.dart';
import '../providers/account_providers.dart';

/// A page that lists all transactions within a selected date range.
///
/// Users can pick start and end dates, and the page will display
/// transactions falling within that range. Each transaction row
/// displays the date, category name, account name and amount. The
/// table is grouped into expenses and incomes with totals displayed
/// separately. At the bottom, the total expenses and incomes are
/// shown for quick reference.
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to current month
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final accounts = ref.watch(accountsProvider);
      List<TransactionEntity> transactions = [];
      transactionsAsync.when(
        data: (data) => transactions = data,
        loading: () {},
        error: (_, __) {},
      );

    List<CategoryEntity> categories = [];
    categoriesAsync.when(
      data: (data) => categories = data,
      loading: () {},
      error: (_, __) {},
    );
    // Build maps for quick lookup
    final Map<String, CategoryEntity> categoryMap = {
      for (final c in categories) (c.id ?? 0).toString(): c
    };
    final Map<String, AccountEntity> accountMap = {
      for (final a in accounts) (a.id ?? 0).toString(): a
    };
    // Filter transactions within date range
    final filtered = transactions.where((t) {
      return t.date.isAtSameMomentAs(_startDate) || t.date.isAtSameMomentAs(_endDate) ||
          (t.date.isAfter(_startDate) && t.date.isBefore(_endDate));
    }).toList();
    // Separate into expenses and incomes
    final List<TransactionEntity> expenses =
        filtered.where((t) => t.isExpense).toList();
    final List<TransactionEntity> incomes =
        filtered.where((t) => !t.isExpense).toList();
    // Compute totals
    double totalExpenses = expenses.fold(0, (prev, t) => prev + t.amount);
    double totalIncomes = incomes.fold(0, (prev, t) => prev + t.amount);
    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateField(
                  context: context,
                  label: 'Begin',
                  date: _startDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                        if (_startDate.isAfter(_endDate)) {
                          _endDate = _startDate;
                        }
                      });
                    }
                  },
                ),
                _buildDateField(
                  context: context,
                  label: 'End',
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
                        if (_endDate.isBefore(_startDate)) {
                          _startDate = _endDate;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: expenses.isEmpty && incomes.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions in this range',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (expenses.isNotEmpty) ...[
                            const Text(
                              'Expense',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DataTable(
                              columnSpacing: 12,
                              horizontalMargin: 0,
                              headingRowHeight: 0,
                              dataRowColor: MaterialStateProperty.resolveWith(
                                  (states) => Colors.white.withOpacity(0.05)),
                              columns: const [
                                DataColumn(label: SizedBox()),
                                DataColumn(label: SizedBox()),
                                DataColumn(label: SizedBox()),
                                DataColumn(label: SizedBox()),
                              ],
                              rows: expenses.map((t) {
                                final category = categoryMap[t.categoryId];
                                final account = accountMap[t.accountId] ??
                                    AccountEntity(
                                        name: 'Unknown',
                                        initialBalance: 0,
                                        currency: '',
                                        colorHex: '#607D8B',
                                        trackIncome: true);
                                return DataRow(cells: [
                                  DataCell(Text(
                                    _formatDate(t.date),
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Text(
                                    category?.name ?? 'Unknown',
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Text(
                                    account.name,
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Text(
                                    '-\$${t.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ]);
                              }).toList(),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'TOTAL: -\$${totalExpenses.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (incomes.isNotEmpty) ...[
                            const Text(
                              'Income',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DataTable(
                              columnSpacing: 12,
                              horizontalMargin: 0,
                              headingRowHeight: 0,
                              dataRowColor: MaterialStateProperty.resolveWith(
                                  (states) => Colors.white.withOpacity(0.05)),
                              columns: const [
                                DataColumn(label: SizedBox()),
                                DataColumn(label: SizedBox()),
                                DataColumn(label: SizedBox()),
                                DataColumn(label: SizedBox()),
                              ],
                              rows: incomes.map((t) {
                                final category = categoryMap[t.categoryId];
                                final account = accountMap[t.accountId] ??
                                    AccountEntity(
                                        name: 'Unknown',
                                        initialBalance: 0,
                                        currency: '',
                                        colorHex: '#607D8B',
                                        trackIncome: true);
                                return DataRow(cells: [
                                  DataCell(Text(
                                    _formatDate(t.date),
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Text(
                                    category?.name ?? 'Unknown',
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Text(
                                    account.name,
                                    style: const TextStyle(color: Colors.white),
                                  )),
                                  DataCell(Text(
                                    '\$${t.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ]);
                              }).toList(),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'TOTAL: \$${totalIncomes.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a tappable field for selecting a date.
  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
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
      ),
    );
  }

  /// Formats a [DateTime] as "MM/dd/yy".
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$month/$day/$year';
  }
}