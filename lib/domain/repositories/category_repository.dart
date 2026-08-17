import 'package:money_management_app/domain/models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<int> addCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<bool> categoryHasExpenses(int id);
}
