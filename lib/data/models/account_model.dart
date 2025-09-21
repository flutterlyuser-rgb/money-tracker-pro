import 'package:money_tracker/domain/entities/account_entity.dart';

class AccountModel {
  int? id;
  String name;
  double initialBalance;
  String currency;
  String colorHex;
  bool trackIncome;

  AccountModel({
    this.id,
    required this.name,
    required this.initialBalance,
    this.currency = 'USD',
    this.colorHex = '#2196F3',
    this.trackIncome = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initialBalance': initialBalance,
      'currency': currency,
      'colorHex': colorHex,
      'trackIncome': trackIncome ? 1 : 0,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      initialBalance: map['initialBalance'],
      currency: map['currency'],
      colorHex: map['colorHex'],
      trackIncome: map['trackIncome'] == 1,
    );
  }

  // ✅ ADD THIS METHOD
  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      name: name,
      initialBalance: initialBalance,
      currency: currency,
      colorHex: colorHex,
      trackIncome: trackIncome,
    );
  }

  // ✅ Optional: Create from Entity
  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      initialBalance: entity.initialBalance,
      currency: entity.currency,
      colorHex: entity.colorHex,
      trackIncome: entity.trackIncome,
    );
  }
}