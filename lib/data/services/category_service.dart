import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/category_model.dart';

class CategoryService {
  final ApiClient _apiClient;
  
  CategoryService(this._apiClient);
  
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.categories);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }
  
  Future<CategoryModel> createCategory(String name) async {
    final response = await _apiClient.post(
      ApiConstants.categories,
      data: CategoryCreate(name: name).toJson(),
    );
    return CategoryModel.fromJson(response.data);
  }
  
  Future<CategoryModel> updateCategory(int id, String name) async {
    final response = await _apiClient.put(
      ApiConstants.categoryById(id),
      data: {'name': name},
    );
    return CategoryModel.fromJson(response.data);
  }
  
  Future<void> deleteCategory(int id) async {
    await _apiClient.delete(ApiConstants.categoryById(id));
  }
}
