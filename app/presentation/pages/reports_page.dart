import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_providers.dart';
import '../providers/transaction_providers.dart';

/// A page that displays a summary of expenses by category and overall profit.
///
/// This page computes the total income and total expenses from all
/// transactions and calculates the profit (income minus expenses). It
/// also aggregates expenses by category and displays them in a list
/// alongside a central donut placeholder showing the profit. The
/// categories list displays the category name, a colored indicator
/// using the category's color, and the total spent for that category.
class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
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
    // Compute totals per category and overall income/expenses
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryTotals = {};
    for (final t in transactions) {
      if (t.isExpense) {
        totalExpense += t.amount;
        categoryTotals.update(t.categoryId, (value) => value + t.amount,
            ifAbsent: () => t.amount);
      } else {
        totalIncome += t.amount;
      }
    }
    final totalProfit = totalIncome - totalExpense;
    // Build list of category entities with totals
    final List<_CategorySummary> summaries = [];
    categoryTotals.forEach((catId, amount) {
      final cat = categories.firstWhere(
        (c) => (c.id ?? 0).toString() == catId,
        orElse: () => CategoryEntity(
          id: 0,
          name: 'Unknown',
          colorHex: '#607D8B',
          iconCode: '0xe15b',
          isExpenseCategory: true,
        ),
      );
      summaries.add(_CategorySummary(category: cat, amount: amount));
    });
    // Sort categories by amount descending
    summaries.sort((a, b) => b.amount.compareTo(a.amount));
    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Donut placeholder with profit value
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white24,
                                width: 24,
                              ),
                            ),
                          ),
                          // Inner circle with profit text
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF014B6D),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'PROFIT',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${totalProfit.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Categories list with totals
                  Expanded(
                    flex: 4,
                    child: summaries.isEmpty
                        ? const Center(
                            child: Text(
                              'No expenses yet',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: summaries.length,
                            itemBuilder: (context, index) {
                              final summary = summaries[index];
                              // Parse color
                              Color parseColor(String hex) {
                                var hexValue = hex.replaceFirst('#', '');
                                if (hexValue.length == 6) hexValue = 'FF$hexValue';
                                return Color(int.parse(hexValue, radix: 16));
                              }
                              final color = parseColor(summary.category.colorHex);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        summary.category.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${summary.amount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class representing a category summary item.
class _CategorySummary {
  final CategoryEntity category;
  final double amount;

  _CategorySummary({required this.category, required this.amount});
}