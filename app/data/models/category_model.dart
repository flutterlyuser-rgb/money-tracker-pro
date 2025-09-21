import 'package:money_tracker/domain/entities/category_entity.dart';

class CategoryModel {
  int? id;
  String name;
  String colorHex;
  String iconCode;
  bool isExpenseCategory;

  CategoryModel({
    this.id,
    required this.name,
    required this.colorHex,
    required this.iconCode,
    required this.isExpenseCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'iconCode': iconCode,
      'isExpenseCategory': isExpenseCategory ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      colorHex: map['colorHex'],
      iconCode: map['iconCode'],
      isExpenseCategory: map['isExpenseCategory'] == 1,
    );
  }

  // ✅ ADD THIS METHOD
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      colorHex: colorHex,
      iconCode: iconCode,
      isExpenseCategory: isExpenseCategory,
    );
  }

  // ✅ Optional: Create from Entity
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      colorHex: entity.colorHex,
      iconCode: entity.iconCode,
      isExpenseCategory: entity.isExpenseCategory,
    );
  }
}