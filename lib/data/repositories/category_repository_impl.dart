import 'package:money_management_app/data/datasources/category_local_datasource.dart';
import 'package:money_management_app/domain/models/category.dart';
import 'package:money_management_app/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDatasource localDatasource;

  CategoryRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Category>> getAllCategories() async {
    return await localDatasource.getAllCategories();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    return await localDatasource.getCategoryById(id);
  }

  @override
  Future<int> addCategory(Category category) async {
    return await localDatasource.insertCategory(category);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await localDatasource.deleteCategory(id);
  }

  @override
  Future<bool> categoryHasExpenses(int id) async {
    return await localDatasource.categoryHasExpenses(id);
  }
}
