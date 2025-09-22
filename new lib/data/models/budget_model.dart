import 'package:money_tracker/domain/entities/budget_entity.dart';

class BudgetModel {
  int? id;
  int categoryId;
  double amount;
  int period;
  DateTime startDate;
  DateTime endDate;
  double alertThreshold;

  BudgetModel({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.alertThreshold = 0.9,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'alertThreshold': alertThreshold,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount'],
      period: map['period'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      alertThreshold: map['alertThreshold'],
    );
  }

  // Convert to Entity for domain layer
  BudgetEntity toEntity({required String categoryName}) { // ✅ ADD categoryName parameter
    return BudgetEntity(
      id: id,
      categoryId: categoryId.toString(),
      categoryName: categoryName, // ✅ ADD categoryName
      amount: amount,
      period: period,
      startDate: startDate,
      endDate: endDate,
      alertThreshold: alertThreshold,
    );
  }

  // Create from Entity for data layer
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: int.parse(entity.categoryId),
      amount: entity.amount,
      period: entity.period,
      startDate: entity.startDate,
      endDate: entity.endDate,
      alertThreshold: entity.alertThreshold,
    );
  }
}