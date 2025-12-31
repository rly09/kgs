import '../../core/supabase_config.dart';
import '../models/order_model.dart';

class OrderService {
  final _supabase = SupabaseConfig.client;
  
  /// Create new order with items
  Future<OrderModel> createOrder(OrderCreate order) async {
    try {
      // Insert order
      final orderResponse = await _supabase
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();
      
      final orderId = orderResponse['id'] as int;
      
      // Insert order items
      final itemsData = order.items.map((item) => {
        ...item.toJson(),
        'order_id': orderId,
      }).toList();
      
      await _supabase
          .from('order_items')
          .insert(itemsData);
      
      // Update product stock for each item
      for (var item in order.items) {
        // Get current product
        final product = await _supabase
            .from('products')
            .select('stock')
            .eq('id', item.productId)
            .single();
        
        final currentStock = product['stock'] as int;
        final newStock = currentStock - item.quantity;
        
        // Update stock
        await _supabase
            .from('products')
            .update({
              'stock': newStock,
              'is_available': newStock > 0,
            })
            .eq('id', item.productId);
      }
      
      // Fetch complete order with items
      return await getOrder(orderId);
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }
  
  /// Get all orders (admin)
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: ${e.toString()}');
    }
  }
  
  /// Get customer orders
  Future<List<OrderModel>> getCustomerOrders(int customerId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch customer orders: ${e.toString()}');
    }
  }
  
  /// Get single order
  Future<OrderModel> getOrder(int id) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', id)
          .single();
      
      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch order: ${e.toString()}');
    }
  }
  
  /// Update order status
  Future<OrderModel> updateOrderStatus(int id, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', id);
      
      return await getOrder(id);
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }
}
