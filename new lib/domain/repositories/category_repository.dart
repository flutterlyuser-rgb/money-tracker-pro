import 'package:money_tracker/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<int> createCategory(CategoryEntity category);
  Future<List<CategoryEntity>> getAllCategories();
  Future<List<CategoryEntity>> getExpenseCategories();
  Future<List<CategoryEntity>> getIncomeCategories();
  Future<CategoryEntity?> getCategoryById(int id);
  Future<CategoryEntity?> getCategoryByName(String name);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(int id);
  Future<int> getCategoriesCount();
}