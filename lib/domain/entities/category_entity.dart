class CategoryEntity {
  final int? id;
  final String name;
   final String colorHex;
  final String iconCode;
  final bool isExpenseCategory;

  CategoryEntity({
    this.id,
    required this.name,
    required this.colorHex,
    required this.iconCode,
    required this.isExpenseCategory,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? colorHex,
    String? iconCode,
    bool? isExpenseCategory,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconCode: iconCode ?? this.iconCode,
      isExpenseCategory: isExpenseCategory ?? this.isExpenseCategory,
    );
  }

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, type: ${isExpenseCategory ? 'Expense' : 'Income'})';
  }
}