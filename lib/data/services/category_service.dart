import '../../core/supabase_config.dart';
import '../models/category_model.dart';

class CategoryService {
  final _supabase = SupabaseConfig.client;
  
  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name');
      
      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }
  
  /// Create new category
  Future<CategoryModel> createCategory(String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .insert(CategoryCreate(name: name).toJson())
          .select()
          .single();
      
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }
  
  /// Update category
  Future<CategoryModel> updateCategory(int id, String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();
      
      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }
  
  /// Delete category
  Future<void> deleteCategory(int id) async {
    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }
}
