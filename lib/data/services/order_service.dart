import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiClient _apiClient;
  
  OrderService(this._apiClient);
  
  Future<OrderModel> createOrder(OrderCreate order) async {
    final response = await _apiClient.post(
      ApiConstants.orders,
      data: order.toJson(),
    );
    return OrderModel.fromJson(response.data);
  }
  
  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.get(ApiConstants.orders);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }
  
  Future<List<OrderModel>> getCustomerOrders(int customerId) async {
    final response = await _apiClient.get(
      ApiConstants.customerOrders(customerId),
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }
  
  Future<OrderModel> getOrder(int id) async {
    final response = await _apiClient.get(ApiConstants.orderById(id));
    return OrderModel.fromJson(response.data);
  }
  
  Future<OrderModel> updateOrderStatus(int id, String status) async {
    final response = await _apiClient.put(
      ApiConstants.orderStatus(id),
      data: OrderStatusUpdate(status: status).toJson(),
    );
    return OrderModel.fromJson(response.data);
  }
}
