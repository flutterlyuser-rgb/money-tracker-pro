class TransactionEntity {
  final int? id;
  final DateTime date;
  final double amount;
  final String description;
  final String categoryId;
  final bool isExpense;
  final String accountId;
  final String? receiptImagePath;
  final String? location;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime createdAt;

  TransactionEntity({
    this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.isExpense,
    required this.accountId,
    this.receiptImagePath,
    this.location,
    this.isRecurring = false,
    this.recurringPattern,
    required this.createdAt,
  });

  // Copy with method for immutability
  TransactionEntity copyWith({
    int? id,
    DateTime? date,
    double? amount,
    String? description,
    String? categoryId,
    bool? isExpense,
    String? accountId,
    String? receiptImagePath,
    String? location,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isExpense: isExpense ?? this.isExpense,
      accountId: accountId ?? this.accountId,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TransactionEntity(id: $id, date: $date, amount: $amount, description: $description, categoryId: $categoryId, isExpense: $isExpense, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TransactionEntity &&
        other.id == id &&
        other.date == date &&
        other.amount == amount &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.isExpense == isExpense &&
        other.accountId == accountId &&
        other.receiptImagePath == receiptImagePath &&
        other.location == location &&
        other.isRecurring == isRecurring &&
        other.recurringPattern == recurringPattern &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      date,
      amount,
      description,
      categoryId,
      isExpense,
      accountId,
      receiptImagePath,
      location,
      isRecurring,
      recurringPattern,
      createdAt,
    );
  }
}