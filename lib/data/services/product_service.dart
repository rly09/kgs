import 'dart:typed_data';
import '../../core/supabase_config.dart';
import '../models/product_model.dart';

class ProductService {
  final _supabase = SupabaseConfig.client;
  
  /// Get all products, optionally filtered by category
  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    try {
      var query = _supabase.from('products').select();
      
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }
  
  /// Get products stream with real-time updates
  Stream<List<ProductModel>> getProductsStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => ProductModel.fromJson(json)).toList());
  }
  
  /// Get products by category stream with real-time updates
  Stream<List<ProductModel>> getProductsByCategoryStream(int? categoryId) {
    var query = _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
    
    return query.map((data) {
      final products = data.map((json) => ProductModel.fromJson(json)).toList();
      if (categoryId == null) {
        return products;
      }
      return products.where((p) => p.categoryId == categoryId).toList();
    });
  }
  
  /// Get single product by ID
  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();
      
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product: ${e.toString()}');
    }
  }
  
  /// Create new product
  Future<ProductModel> createProduct(ProductCreate product) async {
    try {
      final response = await _supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();
      
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }
  
  /// Update product
  Future<ProductModel> updateProduct(int id, ProductUpdate product) async {
    try {
      final response = await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', id)
          .select()
          .single();
      
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }
  
  /// Update product stock
  Future<ProductModel> updateStock(int id, int stock) async {
    try {
      final response = await _supabase
          .from('products')
          .update({'stock': stock, 'is_available': stock > 0})
          .eq('id', id)
          .select()
          .single();
      
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update stock: ${e.toString()}');
    }
  }
  
  /// Delete product (hard delete)
  Future<void> deleteProduct(int id) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }
  
  /// Upload product image to Supabase Storage
  Future<String> uploadProductImage(List<int> imageBytes, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      
      // Convert List<int> to Uint8List
      final uint8List = Uint8List.fromList(imageBytes);
      
      await _supabase.storage
          .from('product-images')
          .uploadBinary(uniqueFileName, uint8List);
      
      final publicUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(uniqueFileName);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
}
