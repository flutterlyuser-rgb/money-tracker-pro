import 'package:money_tracker/domain/entities/transaction_entity.dart';

class TransactionModel {
  int? id;
  DateTime date;
  double amount;
  String description;
  int categoryId;
  bool isExpense;
  int accountId;
  String? receiptImagePath;
  String? location;
  bool isRecurring;
  String? recurringPattern;
  DateTime createdAt;

  TransactionModel({
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

  // Convert to Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'description': description,
      'categoryId': categoryId,
      'isExpense': isExpense ? 1 : 0,
      'accountId': accountId,
      'receiptImagePath': receiptImagePath,
      'location': location,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringPattern': recurringPattern,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map for SQLite queries
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      amount: map['amount'],
      description: map['description'],
      categoryId: map['categoryId'],
      isExpense: map['isExpense'] == 1,
      accountId: map['accountId'],
      receiptImagePath: map['receiptImagePath'],
      location: map['location'],
      isRecurring: map['isRecurring'] == 1,
      recurringPattern: map['recurringPattern'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Convert to Entity for domain layer
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      date: date,
      amount: amount,
      description: description,
      categoryId: categoryId.toString(),
      isExpense: isExpense,
      accountId: accountId.toString(),
      receiptImagePath: receiptImagePath,
      location: location,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      createdAt: createdAt,
    );
  }

  // Create from Entity for data layer
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      date: entity.date,
      amount: entity.amount,
      description: entity.description,
      categoryId: int.parse(entity.categoryId),
      isExpense: entity.isExpense,
      accountId: int.parse(entity.accountId),
      receiptImagePath: entity.receiptImagePath,
      location: entity.location,
      isRecurring: entity.isRecurring,
      recurringPattern: entity.recurringPattern,
      createdAt: entity.createdAt,
    );
  }

  // Helper method for creating with current time
  factory TransactionModel.withCurrentTime({
    int? id,
    required DateTime date,
    required double amount,
    required String description,
    required int categoryId,
    required bool isExpense,
    required int accountId,
    String? receiptImagePath,
    String? location,
    bool isRecurring = false,
    String? recurringPattern,
  }) {
    return TransactionModel(
      id: id,
      date: date,
      amount: amount,
      description: description,
      categoryId: categoryId,
      isExpense: isExpense,
      accountId: accountId,
      receiptImagePath: receiptImagePath,
      location: location,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      createdAt: DateTime.now(),
    );
  }

  // Copy with method for immutability
  TransactionModel copyWith({
    int? id,
    DateTime? date,
    double? amount,
    String? description,
    int? categoryId,
    bool? isExpense,
    int? accountId,
    String? receiptImagePath,
    String? location,
    bool? isRecurring,
    String? recurringPattern,
    DateTime? createdAt,
  }) {
    return TransactionModel(
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
    return 'TransactionModel(id: $id, date: $date, amount: $amount, description: $description, categoryId: $categoryId, isExpense: $isExpense, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TransactionModel &&
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