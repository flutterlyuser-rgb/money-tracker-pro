import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/presentation/pages/todayPage/TransactionPage.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../providers/transaction_providers.dart';
import 'sliding_transaction_tile.dart';

/// Manages a list of sliding tiles and keeps track of which row is open.
/// If the user taps the copy icon and no `onEdit` callback is provided,
/// this widget duplicates the transaction using the provider.
class ModernTransactionList extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final Map<String, CategoryEntity> categoryMap;
  final void Function(TransactionEntity transaction)? onEdit;
  final void Function(TransactionEntity transaction)? onDelete;

  const ModernTransactionList({
    Key? key,
    required this.transactions,
    required this.categoryMap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ModernTransactionList> createState() => _ModernTransactionListState();
}

class _ModernTransactionListState extends State<ModernTransactionList> {
  int _openIndex = -1;

  void _handleOpenChanged(int index) {
    setState(() {
      _openIndex = index;
    });
  }

  void _copyTransaction(int index, WidgetRef ref) {
    final original = widget.transactions[index];
    // Duplicate with a new date and null id (adjust for your model)
    final duplicate = TransactionEntity(
      id: null,
      categoryId: original.categoryId,
      isExpense: original.isExpense,
      amount: original.amount,
      date: DateTime.now(),
      description: original.description,
      accountId: '',
      createdAt: DateTime.now(),
    );
    ref.read(transactionsProvider.notifier).addTransaction(duplicate);
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.transactions.length,
          itemBuilder: (context, index) {
            final t = widget.transactions[index];
            final category = widget.categoryMap[t.categoryId] ??
                CategoryEntity(
                  id: null,
                  name: 'Unknown',
                  colorHex: '#FFC107',
                  iconCode: '0xe15b',
                  isExpenseCategory: t.isExpense,
                );
            final IconData iconData = IconData(
              int.tryParse(category.iconCode) ?? 0xe15b,
              fontFamily: 'MaterialIcons',
            );
            final String formattedDate =
                '${t.date.day.toString().padLeft(2, '0')} '
                '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][t.date.month - 1]}';
            final txModel = Transaction(
              icon: iconData,
              category: category.name,
              date: formattedDate,
              amount: t.amount,
            );
            return SlidingTransactionTile(
              index: index,
              transaction: txModel,
              isOpen: _openIndex == index,
              onOpenChanged: _handleOpenChanged,
               onCopy:() async {
                                  if (widget.onEdit != null) {
                                    widget.onEdit!(t);
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
                                          category: catEntity,
                                          isCalender: false,
                                        ),
                                      ),
                                    );
                                  }
                                },
              //() {
              //   if (widget.onEdit != null) {
              //     widget.onEdit!(t);
              //   } else {
              //    // _copyTransaction(index, ref);
              //   }
              // },
              onDelete: () {
                if (widget.onDelete != null) {
                  widget.onDelete!(t);
                } else {
                  ref
                      .read(transactionsProvider.notifier)
                      .deleteTransaction(t.id ?? 0);
                }
              },
            );
          },
        );
      },
    );
  }
}
