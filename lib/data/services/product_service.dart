import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _apiClient;
  
  ProductService(this._apiClient);
  
  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    final response = await _apiClient.get(
      ApiConstants.products,
      queryParameters: categoryId != null ? {'category_id': categoryId} : null,
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
  
  Future<ProductModel> getProduct(int id) async {
    final response = await _apiClient.get(ApiConstants.productById(id));
    return ProductModel.fromJson(response.data);
  }
  
  Future<ProductModel> createProduct(ProductCreate product) async {
    final response = await _apiClient.post(
      ApiConstants.products,
      data: product.toJson(),
    );
    return ProductModel.fromJson(response.data);
  }
  
  Future<ProductModel> updateProduct(int id, ProductUpdate product) async {
    final response = await _apiClient.put(
      ApiConstants.productById(id),
      data: product.toJson(),
    );
    return ProductModel.fromJson(response.data);
  }
  
  Future<ProductModel> updateStock(int id, int stock) async {
    final response = await _apiClient.put(
      ApiConstants.productStock(id),
      data: {'stock': stock},
    );
    return ProductModel.fromJson(response.data);
  }
  
  Future<void> deleteProduct(int id) async {
    await _apiClient.delete(ApiConstants.productById(id));
  }
}
