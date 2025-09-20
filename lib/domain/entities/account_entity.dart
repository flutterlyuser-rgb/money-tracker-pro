import 'package:flutter/material.dart';
class AccountEntity {
  final int? id;
  final String name;
  final double initialBalance;
  final String currency;
  final String colorHex;
  final bool trackIncome;
  final double currentBalance;

  AccountEntity({
    this.id,
    required this.name,
    required this.initialBalance,
    this.currency = 'USD',
    this.colorHex = '#2196F3',
    this.trackIncome = true,
    this.currentBalance = 0.0,
  });

  AccountEntity copyWith({
    int? id,
    String? name,
    double? initialBalance,
    String? currency,
    String? colorHex,
    bool? trackIncome,
    double? currentBalance,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      colorHex: colorHex ?? this.colorHex,
      trackIncome: trackIncome ?? this.trackIncome,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  String toString() {
    return 'AccountEntity(id: $id, name: $name, initialBalance: $initialBalance, currentBalance: $currentBalance)';
  }

  // Helper to get display balance
  String get displayBalance {
    return '\$${currentBalance.toStringAsFixed(2)}';
  }

  // Helper to get color from hex
  Color get color {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }
}