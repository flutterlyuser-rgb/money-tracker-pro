import 'package:flutter/material.dart';
class BudgetEntity {
  final int? id;
  final String categoryId;
  final String categoryName; // Added for UI display
  final double amount;
  final int period; // 0 = monthly, 1 = weekly, 2 = yearly
  final DateTime startDate;
  final DateTime endDate;
  final double alertThreshold;
  final double spentAmount;
  final double remainingAmount;
  final double percentageSpent;

  BudgetEntity({
    this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.alertThreshold = 0.9,
    this.spentAmount = 0.0,
    this.remainingAmount = 0.0,
    this.percentageSpent = 0.0,
  });

  BudgetEntity copyWith({
    int? id,
    String? categoryId,
    String? categoryName,
    double? amount,
    int? period,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
    double? spentAmount,
    double? remainingAmount,
    double? percentageSpent,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      spentAmount: spentAmount ?? this.spentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      percentageSpent: percentageSpent ?? this.percentageSpent,
    );
  }

  // Helper methods
  bool get isOverBudget => spentAmount > amount;
  bool get isCloseToLimit => percentageSpent >= alertThreshold;
  bool get isActive => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  String get periodText {
    switch (period) {
      case 0: return 'Monthly';
      case 1: return 'Weekly';
      case 2: return 'Yearly';
      default: return 'Custom';
    }
  }

  String get status {
    if (!isActive) return 'Inactive';
    if (isOverBudget) return 'Over Budget';
    if (isCloseToLimit) return '接近 Limit';
    return 'On Track';
  }

  Color get statusColor {
    if (!isActive) return Colors.grey;
    if (isOverBudget) return Colors.red;
    if (isCloseToLimit) return Colors.orange;
    return Colors.green;
  }

  @override
  String toString() {
    return 'BudgetEntity(id: $id, category: $categoryName, amount: $amount, spent: $spentAmount)';
  }
}