import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/budget_entity.dart';
import 'edit_transaction_page.dart';
import '../../providers/transaction_providers.dart';
import '../../providers/category_providers.dart';
import '../../providers/budget_providers.dart';
import '../budget_page.dart' show AddBudgetPage;

/// The landing page showing today's transactions and summary.
///
/// It displays the current date, a list of recorded transactions grouped
/// under the "PAID" section, totals for expenses and income, and a banner
/// promoting an online banking feature. A prominent plus button in the header
/// triggers navigation to add a new transaction via the supplied [onAdd] callback.
class TodayPage extends ConsumerWidget {
  /// Called when the floating add button in the header is pressed.
  final VoidCallback onAdd;

  /// Optional callback when the date header is tapped. Navigates to calendar.
  final VoidCallback? onDateTap;

  /// Optional callback when a transaction should be edited. If null, a default message is shown.
  final void Function(TransactionEntity transaction)? onEdit;

  /// Optional callback when a transaction should be deleted. If null, a default message is shown.
  final void Function(TransactionEntity transaction)? onDelete;

  const TodayPage({
    Key? key,
    required this.onAdd,
    this.onDateTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final months = [
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
      'December'
    ];
    final dayName = daysOfWeek[now.weekday % 7];
    final monthName = months[now.month - 1];
    final dayNumber = now.day.toString().padLeft(2, '0');

    // Watch transactions, categories and budgets providers.
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final budgets = ref.watch(budgetsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        // Build a map of categoryId to CategoryEntity for quick lookup.
        List<CategoryEntity> categories = [];
        categoriesAsync.when(
          data: (list) => categories = list,
          loading: () {},
          error: (_, __) {},
        );
        final Map<String, CategoryEntity> categoryMap = {
          for (final c in categories) (c.id ?? 0).toString(): c
        };

        // Split transactions into planned (future) and paid (past/today) and calculate totals.
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
        // Filter active budgets as goals.
        final List<BudgetEntity> activeBudgets = budgets.where((b) => b.isActive).toList();

        // Build a combined list of items for a single ListView.
        final List<Map<String, dynamic>> listItems = [];
        // Goals section
        if (activeBudgets.isNotEmpty) {
          listItems.add({'type': 'header', 'title': 'GOALS'});
          for (final b in activeBudgets) {
            listItems.add({'type': 'goal', 'budget': b});
          }
        }
        // Planned section
        listItems.add({'type': 'header', 'title': 'PLANNED'});
        for (final t in plannedTransactions) {
          listItems.add({'type': 'planned', 'transaction': t});
        }
        // Paid section
        listItems.add({'type': 'header', 'title': 'PAID'});
        for (final t in paidTransactions) {
          listItems.add({'type': 'paid', 'transaction': t});
        }
        // Totals summary
        listItems.add({'type': 'totals'});
        // Promo section
        listItems.add({'type': 'promo'});

        return Scaffold(
          backgroundColor: const Color(0xFF01304B),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with date and add button.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date area triggers optional onDateTap.
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
                      // Add button.
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
                // Divider line.
                Container(
                  height: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                ),
                // Combined goals, planned, paid sections and lists.
                Expanded(
                  child: ListView.builder(
                    itemCount: listItems.length,
                    itemBuilder: (context, index) {
                      final item = listItems[index];
                      final type = item['type'] as String;
                      if (type == 'header') {
                        final String title = item['title'] as String;
                        // For GOALS header show Add button on the right
                        if (title == 'GOALS') {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                        builder: (context) => const AddBudgetPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.add, color: Colors.white, size: 16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        final cat = categoryMap[b.categoryId] ?? CategoryEntity(
                          id: null,
                          name: b.categoryName,
                          colorHex: '#FFC107',
                          iconCode: '0xe15b',
                          isExpenseCategory: true,
                        );
                        Color parseColor(String hex) {
                          hex = hex.replaceFirst('#', '');
                          if (hex.length == 6) hex = 'FF$hex';
                          return Color(int.parse(hex, radix: 16));
                        }
                        final Color catColor = parseColor(cat.colorHex);
                        final IconData iconData = IconData(
                          int.tryParse(cat.iconCode) ?? 0xe15b,
                          fontFamily: 'MaterialIcons',
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final double ratio = b.amount > 0
                                                ? (b.spentAmount / b.amount)
                                                : 0.0;
                                            return Container(
                                              height: 8,
                                              width: constraints.maxWidth * ratio,
                                              decoration: BoxDecoration(
                                                color: catColor,
                                                borderRadius: BorderRadius.circular(4),
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
                      } else if (type == 'planned' || type == 'paid') {
                        final TransactionEntity t = item['transaction'] as TransactionEntity;
                        final CategoryEntity category = categoryMap[t.categoryId] ?? CategoryEntity(
                          id: null,
                          name: 'Unknown',
                          colorHex: '#FFC107',
                          iconCode: '0xe15b',
                          isExpenseCategory: t.isExpense,
                        );
                        Color parseColor(String hex) {
                          hex = hex.replaceFirst('#', '');
                          if (hex.length == 6) hex = 'FF$hex';
                          return Color(int.parse(hex, radix: 16));
                        }
                        final Color categoryColor = parseColor(category.colorHex);
                        final IconData iconData = IconData(
                          int.tryParse(category.iconCode) ?? 0xe15b,
                          fontFamily: 'MaterialIcons',
                        );
                        // Each transaction (planned or paid) is wrapped in a Slidable to
                        // allow swipe actions. The row design here closely follows the
                        // provided reference images. A larger category icon is displayed
                        // without a colored background, the date is shown in a light
                        // green hue, and the amount appears inside a wide pill-shaped
                        // container. Swiping left reveals two simple icon actions
                        // (duplicate/edit and delete) without labels.
                        return Slidable(
                          key: ValueKey('${t.date.toIso8601String()}_${t.amount}_$type'),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            // Reserve roughly 30% of the row for action icons (two actions).
                            extentRatio: 0.3,
                            children: [
                              SlidableAction(
                                // First action behaves like an edit/duplicate. If a custom
                                // onEdit callback is provided, invoke it; otherwise open
                                // the edit page directly. The edit page updates the
                                // transaction via the provider.
                                onPressed: (context) async {
                                  if (onEdit != null) {
                                    onEdit!(t);
                                  } else {
                                    // Open the edit page for the selected transaction. Pass
                                    // the resolved category entity along so the edit form
                                    // can display the correct icon and color.
                                    final CategoryEntity catEntity = category;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TransactionPage(
                                          transaction: t,
                                          category: catEntity, isCalender: false, 
                                        ),
                                      ),
                                    );
                                  }
                                },
                                // Match the row background for a seamless slide effect.
                                backgroundColor: const Color(0xFF01304B),
                                foregroundColor: Colors.white,
                                // Use a copy icon to reflect duplication/editing.
                                icon: Icons.content_copy,
                                // Hide the label to match the reference design.
                                label: '',
                              ),
                              SlidableAction(
                                // Second action deletes the transaction. Prefer a supplied
                                // callback but fall back to the provider deletion.
                                onPressed: (context) async {
                                  if (onDelete != null) {
                                    onDelete!(t);
                                  } else {
                                    await ref
                                        .read(transactionsProvider.notifier)
                                        .deleteTransaction(t.id ?? 0);
                                  }
                                },
                                backgroundColor: const Color(0xFF01304B),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: '',
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white12),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Category icon: bigger and without colored background. The icon
                                // itself is white to stand out against the dark row.
                                Icon(
                                  iconData,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                const SizedBox(width: 16),
                                // Name and date column. The date uses a light green color
                                // similar to the reference images.
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${months[t.date.month - 1].substring(0, 3)} ${t.date.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          color: Color(0xFF70D7A0),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Amount pill. A wide pill with a bright highlight color and
                                // dark text matches the look of the Money Pro design.
                                Container(
                                  width: 110,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: category.isExpenseCategory
                                        ? const Color(0xFFFFC107)
                                        : const Color(0xFF00BCD4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '\$${t.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      // Dark text inside the pill for better contrast.
                                      color: Color(0xFF01304B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (type == 'totals') {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading transactions: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}