import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/presentation/pages/todayPage/TransactionPage.dart';
import 'package:money_tracker/presentation/widgets/background_container.dart';

// Data layer imports
import 'data/datasources/database_helper.dart';
import 'data/utils/default_data.dart';

// Domain entity imports
import 'domain/entities/category_entity.dart';
import 'domain/entities/transaction_entity.dart';

// Presentation layer imports
import 'presentation/pages/todayPage/today_page.dart';
import 'presentation/pages/todayPage/category_selection_page.dart';

import 'presentation/pages/placeholder_page.dart';


import 'presentation/pages/balancePage/balance_pag.dart';
import 'presentation/pages/budget_page.dart';
import 'presentation/pages/reports_page.dart';
import 'presentation/pages/transactions_page.dart';
import 'presentation/pages/todayPage/calendar_page.dart';
import 'presentation/providers/transaction_providers.dart';
import 'presentation/providers/navigation_providers.dart';
import 'presentation/widgets/navigation/custom_bottom_nav_bar.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/theme_providers.dart';

/// Entry point of the application.
///
/// Before the application is run, the SQLite database is initialized and
/// default data (categories and accounts) are inserted if necessary. The
/// entire widget tree is wrapped in a [ProviderScope] to enable Riverpod
/// providers throughout the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database and insert default data.
  final dbHelper = DatabaseHelper();
  await DefaultData.initializeDefaultData(dbHelper);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget for the money management app.
///
/// Sets up theming and hosts the [HomeScreen] which manages bottom
/// navigation and transaction state.
class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Money Pro Flutter',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}

/// The main navigation container with a bottom bar and dynamic pages.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Handles creation of a new transaction from the Today page.
  ///
  /// Presents a category selection screen followed by the transaction
  /// entry screen. Once the user completes the form, the resulting
  /// [TransactionEntity] is persisted via the [transactionsProvider].
  void _onAddPressed() async {
    // Select a category first.
    final CategoryEntity? category = await Navigator.push<CategoryEntity?>(
      context,
      MaterialPageRoute(builder: (context) => const CategorySelectionPage()),
    );
    if (category != null) {
      // Enter transaction details.
      final TransactionEntity? transaction = await Navigator.push<TransactionEntity?>(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionPage(category: category, isCalender: false,),
        ),
      );
      if (transaction != null) {
        // Persist the transaction and refresh the provider state.
        await ref
            .read(transactionsProvider.notifier)
            .addTransaction(transaction);
      }
    }
  }

  /// Navigates to the full calendar page when the date header is tapped.
  void _onDateTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navIndexProvider);
    final pages = [
      TodayPage(
        onAdd: _onAddPressed,
        onDateTap: _onDateTap,
      ),
      const BalancePage(),
      const BudgetPage(),
      const ReportsPage(),
      const TransactionsPage(),
    ];

    final navItems = const [
      NavItem(label: 'Today', icon: Icons.event),
      NavItem(label: 'Balance', icon: Icons.account_balance_wallet),
      NavItem(label: 'Budget', icon: Icons.bar_chart),
      NavItem(label: 'Reports', icon: Icons.pie_chart),
      NavItem(label: 'More', icon: Icons.list_alt),
    ];

    return BackgroundContainer(
      child: Scaffold(
        body:  BackgroundContainer(child: pages[selectedIndex]),
        bottomNavigationBar: CustomBottomNavBar(items: navItems),
      ),
    );
  }
}