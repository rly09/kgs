import '../../core/supabase_config.dart';
import './auth_service.dart';

class AdminService {
  final _supabase = SupabaseConfig.client;
  final _authService = AuthService();

  /// Get admin analytics/dashboard stats
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      // Get total revenue (delivered orders only)
      final deliveredOrders = await _supabase
          .from('orders')
          .select('total_amount')
          .eq('status', 'DELIVERED');
      
      final totalRevenue = (deliveredOrders as List)
          .fold<double>(0, (sum, order) => sum + (order['total_amount'] as num).toDouble());
      
      // Get today's revenue
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day).toIso8601String();
      final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
      
      final todayOrders = await _supabase
          .from('orders')
          .select('total_amount')
          .eq('status', 'DELIVERED')
          .gte('created_at', todayStart)
          .lte('created_at', todayEnd);
      
      final todayRevenue = (todayOrders as List)
          .fold<double>(0, (sum, order) => sum + (order['total_amount'] as num).toDouble());
      
      // Get total orders count
      final ordersResponse = await _supabase
          .from('orders')
          .select('id');
      final ordersCount = (ordersResponse as List).length;
      
      // Get pending orders count
      final pendingResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'PENDING');
      final pendingCount = (pendingResponse as List).length;
      
      // Get total products count
      final productsResponse = await _supabase
          .from('products')
          .select('id');
      final productsCount = (productsResponse as List).length;
      
      // Get low stock products count (stock < 10)
      final lowStockResponse = await _supabase
          .from('products')
          .select('id')
          .lt('stock', 10);
      final lowStockCount = (lowStockResponse as List).length;
      
      return {
        'total_revenue': totalRevenue,
        'today_revenue': todayRevenue,
        'total_orders': ordersCount,
        'pending_orders': pendingCount,
        'total_products': productsCount,
        'low_stock_products': lowStockCount,
      };
    } catch (e) {
      throw Exception('Failed to fetch analytics: ${e.toString()}');
    }
  }

  /// Update admin password
  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Get current admin ID from auth
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Not authenticated');
      }
      
      // Get current admin
      final admin = await _supabase
          .from('admins')
          .select('password_hash')
          .eq('id', currentUser.id)
          .single();
      
      // In production, verify old password with bcrypt
      // For now, just update (you'll need to hash the new password)
      
      // Update password (you'll need to hash this properly)
      await _supabase
          .from('admins')
          .update({'password_hash': newPassword}) // TODO: Hash this!
          .eq('id', currentUser.id);
      
      return {'message': 'Password updated successfully'};
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }
}
