import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:money_tracker/presentation/widgets/background_container.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../providers/transaction_providers.dart';
import '../../providers/category_providers.dart';
import '../../providers/budget_providers.dart';
import '../../widgets/modern_transaction_list.dart';
//import 'edit_transaction_page.dart';
import '../budget_page.dart' show AddBudgetPage;

/// Today’s summary page. Displays a date header, goals, planned and paid
/// transactions using the modern sliding tile design, and totals/promo at the end.
class TodayPage extends ConsumerWidget {
  final VoidCallback onAdd;
  final VoidCallback? onDateTap;
  final void Function(TransactionEntity transaction)? onEdit;
  final void Function(TransactionEntity transaction)? onDelete;

  const TodayPage({
    Key? key,
    required this.onAdd,
    this.onDateTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  static const List<String> _daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dayName = _daysOfWeek[now.weekday % 7];
    final monthName = _months[now.month - 1];
    final dayNumber = now.day.toString().padLeft(2, '0');

    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final budgets = ref.watch(budgetsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        // Build lookup for category entities
        List<CategoryEntity> categories = [];
        categoriesAsync.when(
          data: (list) => categories = list,
          loading: () {},
          error: (_, __) {},
        );
        final Map<String, CategoryEntity> categoryMap = {
          for (final c in categories) (c.id ?? 0).toString(): c,
        };

        // Split transactions into planned (future) and paid (past/today) and sum totals.
        final nowDate = DateTime(now.year, now.month, now.day);
        double totalExpense = 0;
        double totalIncome = 0;
        final List<TransactionEntity> plannedTransactions = [];
        final List<TransactionEntity> paidTransactions = [];
        for (final t in transactions) {
          if (t.isExpense) {
            totalExpense += t.amount;
          } else {
            totalIncome += t.amount;
          }
          if (t.date.isAfter(nowDate)) {
            plannedTransactions.add(t);
          } else {
            paidTransactions.add(t);
          }
        }

        // Active budgets become goals.
        final List<BudgetEntity> activeBudgets = budgets
            .where((b) => b.isActive)
            .toList();

        // Define sections for the list view.
        final List<Map<String, dynamic>> listItems = [];
        if (activeBudgets.isNotEmpty) {
          listItems.add({'type': 'header', 'title': 'GOALS'});
          for (final b in activeBudgets) {
            listItems.add({'type': 'goal', 'budget': b});
          }
        }
        listItems.add({'type': 'header', 'title': 'PLANNED'});
        listItems.add({'type': 'planned_list'});
        listItems.add({'type': 'header', 'title': 'PAID'});
        listItems.add({'type': 'paid_list'});
        listItems.add({'type': 'totals'});
        listItems.add({'type': 'promo'});

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date and add button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: onDateTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Text(
                              dayNumber,
                              style: const TextStyle(
                                fontSize: 72,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '$monthName ${now.year}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  height: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                ),
                // List sections
                Expanded(
                  child: ListView.builder(
                    itemCount: listItems.length,
                    itemBuilder: (context, index) {
                      final item = listItems[index];
                      final type = item['type'] as String;
                      if (type == 'header') {
                        final String title = item['title'] as String;
                        if (title == 'GOALS') {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddBudgetPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Add',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      } else if (type == 'goal') {
                        final BudgetEntity b = item['budget'] as BudgetEntity;
                        final cat =
                            categoryMap[b.categoryId] ??
                            CategoryEntity(
                              id: null,
                              name: b.categoryName,
                              colorHex: '#FFC107',
                              iconCode: '0xe15b',
                              isExpenseCategory: true,
                            );
                        Color parseColor(String hex) {
                          var cleaned = hex.replaceFirst('#', '');
                          if (cleaned.length == 6) cleaned = 'FF$cleaned';
                          return Color(int.parse(cleaned, radix: 16));
                        }

                        final Color catColor = parseColor(cat.colorHex);
                        final IconData iconData = IconData(
                          int.tryParse(cat.iconCode) ?? 0xe15b,
                          fontFamily: 'MaterialIcons',
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(iconData, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.categoryName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final double ratio = b.amount > 0
                                                ? (b.spentAmount / b.amount)
                                                : 0.0;
                                            return Container(
                                              height: 8,
                                              width:
                                                  constraints.maxWidth * ratio,
                                              decoration: BoxDecoration(
                                                color: catColor,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Spent: \$${b.spentAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Remaining: \$${b.remainingAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${b.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (type == 'planned_list') {
                        return ModernTransactionList(
                          transactions: plannedTransactions,
                          categoryMap: categoryMap,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        );
                      } else if (type == 'paid_list') {
                        return ModernTransactionList(
                          transactions: paidTransactions,
                          categoryMap: categoryMap,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        );
                      } else if (type == 'totals') {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'TOTAL EXPENSES: \$${totalExpense.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'TOTAL INCOME: \$${totalIncome.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (type == 'promo') {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Online Banking',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Money Pro will connect to your bank and download your transactions',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading transactions: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
