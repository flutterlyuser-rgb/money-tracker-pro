import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/presentation/widgets/background_container.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/transaction_providers.dart';
import '../../providers/category_providers.dart';
import 'category_selection_page.dart';
import 'add_transaction_page.dart';

/// Displays a monthly calendar with markers for each day that has transactions.
///
/// Tapping on a day shows a list of events for that day. A custom header
/// replicates the look of the example screenshot with a back button, the
/// current month/year and buttons for search and adding new transactions. When
/// a new transaction is added via the plus button, both the calendar and
/// underlying transaction list are updated accordingly via the [onAddTransaction]
/// callback.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  /// Handles adding a new transaction from the calendar page.
  Future<void> _onAddPressed() async {
    // Choose a category first
    final CategoryEntity? category = await Navigator.push<CategoryEntity?>(
      context,
      MaterialPageRoute(builder: (context) => const CategorySelectionPage()),
    );
    if (category != null) {
      final TransactionEntity? transaction = await Navigator.push<TransactionEntity?>(
        context,
        MaterialPageRoute(
          builder: (context) => AddTransactionPage(category: category),
        ),
      );
      if (transaction != null) {
        // Persist the transaction via the provider
        await ref.read(transactionsProvider.notifier).addTransaction(transaction);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build header month/year string (e.g., "August 2025").
    final monthNames = [
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
    final headerTitle = '${monthNames[_focusedDay.month - 1]} ${_focusedDay.year}';

    // Watch the transactions and categories providers.
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return transactionsAsync.when(
      data: (transactions) {
        // Map categories for quick lookup.
        List<CategoryEntity> categories = [];
        categoriesAsync.when(
          data: (list) => categories = list,
          loading: () {},
          error: (_, __) {},
        );
        final categoryMap = {
          for (final c in categories) (c.id ?? 0).toString(): c,
        };

        // Build events list for selected day.
        final eventsForSelectedDay = <TransactionEntity>[];
        if (_selectedDay != null) {
          final DateTime key = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
          for (final t in transactions) {
            final transactionDay = DateTime(t.date.year, t.date.month, t.date.day);
            if (transactionDay == key) {
              eventsForSelectedDay.add(t);
            }
          }
        }

        return BackgroundContainer(
          child: Scaffold(
            backgroundColor:  Colors.transparent,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom header row with back, month/year and action icons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        // Back arrow
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(24),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Label "Today"
                        const Text(
                          'Today',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Month/year title in the middle
                        Text(
                          headerTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Search icon (non-functional placeholder)
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(24),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Add transaction icon
                        InkWell(
                          onTap: _onAddPressed,
                          borderRadius: BorderRadius.circular(24),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calendar widget
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TableCalendar<TransactionEntity>(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          _selectedDay != null && isSameDay(day, _selectedDay),
                      eventLoader: (day) {
                        final List<TransactionEntity> eventsForDay = [];
                        final dayKey = DateTime(day.year, day.month, day.day);
                        for (final t in transactions) {
                          final transactionKey = DateTime(t.date.year, t.date.month, t.date.day);
                          if (transactionKey == dayKey) {
                            eventsForDay.add(t);
                          }
                        }
                        return eventsForDay;
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerVisible: false,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.white),
                        weekendStyle: TextStyle(color: Colors.white),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: const TextStyle(color: Colors.white),
                        weekendTextStyle: const TextStyle(color: Colors.white),
                        outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        markersMaxCount: 3,
                        markerDecoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Events list for the selected day
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: eventsForSelectedDay.isEmpty
                          ? const Center(
                              child: Text(
                                'No transactions',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: eventsForSelectedDay.length,
                              itemBuilder: (context, index) {
                                final t = eventsForSelectedDay[index];
                                final category = categoryMap[t.categoryId] ?? CategoryEntity(
                                  id: null,
                                  name: 'Unknown',
                                  colorHex: '#FFC107',
                                  iconCode: '0xe15b',
                                  isExpenseCategory: t.isExpense,
                                );
                                // Determine color for amount based on transaction type or category.
                                final boxColor = category.isExpenseCategory
                                    ? const Color(0xFFFFC107)
                                    : const Color(0xFF00BCD4);
                                // Convert icon code.
                                final iconData = IconData(
                                  int.tryParse(category.iconCode) ?? 0xe15b,
                                  fontFamily: 'MaterialIcons',
                                );
                                // Format date/time.
                                final dateStr = _formatDate(t.date);
                                final timeStr = _formatTime(t.date);
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.white12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                        child: Icon(
                                          iconData,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  dateStr,
                                                  style: TextStyle(
                                                    color: Colors.greenAccent.shade100,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Colors.white54,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  timeStr,
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: boxColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '\$${t.amount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF01304B),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFF01304B),
        body: Center(
          child: Text(
            'Error loading transactions: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Formats a date as a short month-day string (e.g., "Aug 1").
  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Formats the time portion of a DateTime object (e.g., "14:05").
  static String _formatTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}