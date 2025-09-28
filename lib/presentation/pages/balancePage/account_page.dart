import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/presentation/widgets/background_container.dart';

// Domain entities
import '../../../domain/entities/account_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/transaction_entity.dart';

// Repository providers to fetch transactions and categories
import '../../../data/providers/repository_providers.dart';

// Presentation providers and pages
import '../../providers/transaction_providers.dart';
import '../../providers/category_providers.dart';
import '../todayPage/category_selection_page.dart';
import '../todayPage/TransactionPage.dart';

import '../../widgets/modern_transaction_list.dart';

/// A page that displays all transactions associated with a specific account.
///
/// When navigated to from the Balance page, this screen shows the account
/// name at the top, provides controls for searching, filtering and
/// selecting a date range, and lists the transactions using the
/// pre‑built [ModernTransactionList] widget. Users can add new
/// transactions tied to the account, edit existing ones or delete them.
class AccountPage extends ConsumerStatefulWidget {
  /// The account whose transactions are shown on this page.
  final AccountEntity account;

  const AccountPage({Key? key, required this.account}) : super(key: key);

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  // Date range for filtering transactions. Defaults to the current month.
  late DateTime _startDate;
  late DateTime _endDate;

  // 0 = all, 1 = expenses only, 2 = incomes only
  int _filterIndex = 0;

  // Whether the search bar is visible.
  bool _showSearchBar = false;

  // Controller for search input.
  final TextEditingController _searchController = TextEditingController();

  // All transactions loaded for this account after applying date and type filters.
  List<TransactionEntity> _transactions = [];

  // Transactions filtered by the search query.
  List<TransactionEntity> _displayedTransactions = [];

  // Map of category IDs to their corresponding entities for icon and colour lookup.
  Map<String, CategoryEntity> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    // Compute the last day of the current month by getting the first day
    // of the next month and subtracting a day.
    _endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    // Load data when the page is first created.
    _loadData();
    // Listen to search field changes to update displayed list.
    _searchController.addListener(_applySearchFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches transactions and categories from the repository and applies
  /// date/type filters. Called initially and whenever the user adjusts
  /// the date range or filter type.
  Future<void> _loadData() async {
    // Fetch transactions for this account.
    final repo = ref.read(transactionRepositoryProvider);
    // The repository expects the account identifier as a string. Use '0'
    // for any accounts without a persisted id to avoid null issues.
    final allTransactions = await repo.getTransactionsByAccount(
      (widget.account.id ?? 0).toString(),
    );
    // Filter by date range.
    List<TransactionEntity> filtered = allTransactions.where((t) {
      // Only include transactions whose date lies between start and end inclusive.
      final dt = DateTime(t.date.year, t.date.month, t.date.day);
      return (dt.isAtSameMomentAs(_startDate) || dt.isAfter(_startDate)) &&
          (dt.isAtSameMomentAs(_endDate) || dt.isBefore(_endDate.add(const Duration(days: 1))));
    }).toList();
    // Filter by type.
    if (_filterIndex == 1) {
      filtered = filtered.where((t) => t.isExpense).toList();
    } else if (_filterIndex == 2) {
      filtered = filtered.where((t) => !t.isExpense).toList();
    }
    // Load all categories to build the map. Using the repository directly
    // here avoids triggering unnecessary rebuilds of other providers.
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final categories = await categoryRepo.getAllCategories();
    final Map<String, CategoryEntity> categoryMap = {
      for (final c in categories) (c.id ?? 0).toString(): c,
    };
    setState(() {
      _transactions = filtered;
      _categoryMap = categoryMap;
    });
    // After updating the main list, apply any active search filter.
    _applySearchFilter();
  }

  /// Rebuilds the displayed transactions based on the current search query.
  void _applySearchFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayedTransactions = List.from(_transactions);
      } else {
        _displayedTransactions = _transactions.where((t) {
          final category = _categoryMap[t.categoryId];
          final categoryName = category?.name.toLowerCase() ?? '';
          final description = t.description.toLowerCase();
          return categoryName.contains(query) || description.contains(query);
        }).toList();
      }
    });
  }

  /// Presents a date picker for selecting either the start or end date.
  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(picked.year, picked.month, picked.day);
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = DateTime(picked.year, picked.month, picked.day);
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
      await _loadData();
    }
  }

  /// Displays a bottom sheet allowing the user to choose between
  /// showing all transactions, only expenses or only incomes.
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Center(child: Text('All transactions')),
              onTap: () {
                Navigator.of(ctx).pop();
                if (_filterIndex != 0) {
                  setState(() => _filterIndex = 0);
                  _loadData();
                }
              },
            ),
            ListTile(
              title: const Center(child: Text('Expenses only')),
              onTap: () {
                Navigator.of(ctx).pop();
                if (_filterIndex != 1) {
                  setState(() => _filterIndex = 1);
                  _loadData();
                }
              },
            ),
            ListTile(
              title: const Center(child: Text('Income only')),
              onTap: () {
                Navigator.of(ctx).pop();
                if (_filterIndex != 2) {
                  setState(() => _filterIndex = 2);
                  _loadData();
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  /// Handles the creation of a new transaction tied to this account.
  /// Presents the category selection screen followed by the transaction
  /// entry form. When the user completes the form, the resulting
  /// [TransactionEntity] is persisted via the [transactionsProvider],
  /// overriding its accountId to ensure it belongs to this account.
Future<void> _addTransaction() async {
  // First select a category.// push a category to 
  final CategoryEntity? category = await Navigator.push<CategoryEntity?>( // When navigate to select catogery in sategory selection page it return a category
    context,
    MaterialPageRoute(builder: (context) => const CategorySelectionPage()),

  );
  
  if (category != null) {
    // Pass the selected account to the TransactionPage
    final TransactionEntity? newTx = await Navigator.push<TransactionEntity?>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
          category: category,
          isCalender: false,
          account: widget.account,  // Pass the selected account here
        ),
      ),
    );

    if (newTx != null) {
      // Ensure the transaction is associated with this account.
      final txWithAccount = newTx.copyWith(accountId: (widget.account.id ?? 0).toString());
      await ref.read(transactionsProvider.notifier).addTransaction(txWithAccount);
      await _loadData();
    }
  }
}


  /// Called when a transaction tile’s edit action is tapped. Opens the
  /// transaction page prepopulated with the selected transaction and
  /// category. Saves updates via the provider and reloads data.
  Future<void> _editTransaction(TransactionEntity tx) async {
    final category = _categoryMap[tx.categoryId];
    if (category == null) return;
    final TransactionEntity? updated = await Navigator.push<TransactionEntity?>(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionPage(
          category: category,
          isCalender: false,
          transaction: tx,
        ),
      ),
    );
    if (updated != null) {
      final txWithAccount = updated.copyWith(accountId: (widget.account.id ?? 0).toString());
      await ref.read(transactionsProvider.notifier).updateTransaction(txWithAccount);
      await _loadData();
    }
  }

  /// Deletes a transaction from the database and reloads data.
  Future<void> _deleteTransaction(TransactionEntity tx) async {
    if (tx.id != null) {
      await ref.read(transactionsProvider.notifier).deleteTransaction(tx.id!);
      await _loadData();
    }
  }

  /// Formats a [DateTime] as a string in the same style as the design images.
  String _formatDate(DateTime date) {
    // e.g. "Sep 20, 2025"
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    //final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.account.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearchBar = !_showSearchBar;
                  if (!_showSearchBar) {
                    _searchController.clear();
                    _applySearchFilter();
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTransaction,
            ),
          ],
        ),
        body: Column(
          children: [
            // Optional search bar
            if (_showSearchBar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              _applySearchFilter();
                            },
                          )
                        : null,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            // Date range selector and filter button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(isStart: true),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:  const Color.fromARGB(35, 158, 158, 158),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Begin',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(_startDate),
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(isStart: false),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(35, 158, 158, 158),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(_endDate),
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(35, 158, 158, 158),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                                      icon: const Icon(Icons.more_vert, color: Colors.white),
                                      
                                      onPressed: _showFilterOptions,
                                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 4),
            // Transaction list
            Expanded(
              child: _displayedTransactions.isNotEmpty
                  ? ModernTransactionList(
                      transactions: _displayedTransactions,
                      categoryMap: _categoryMap,
                      onEdit: (tx) => _editTransaction(tx),
                      onDelete: (tx) => _deleteTransaction(tx),
                    )
                  : const Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}