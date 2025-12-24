import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/api/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/services/category_service.dart';
import 'data/services/product_service.dart';
import 'data/services/order_service.dart';
import 'data/services/settings_service.dart';
import 'data/models/auth_models.dart';
import 'data/models/category_model.dart';
import 'data/models/product_model.dart';
import 'data/models/order_model.dart';
import 'presentation/customer/cart/cart_notifier.dart';

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Service providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(apiClientProvider));
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.read(apiClientProvider));
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.read(apiClientProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.read(apiClientProvider));
});

// Admin authentication provider
final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AdminModel?>((ref) {
  return AdminAuthNotifier(ref.read(authServiceProvider));
});

class AdminAuthNotifier extends StateNotifier<AdminModel?> {
  final AuthService _authService;

  AdminAuthNotifier(this._authService) : super(null) {
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuth = await _authService.isAuthenticated();
    if (!isAuth) {
      state = null;
    }
    // Note: We don't have the admin details stored, so we'll need to fetch them after login
  }

  Future<bool> login(String phone, String password) async {
    try {
      final authResponse = await _authService.adminLogin(phone, password);
      
      // Extract admin data from auth response
      final userData = authResponse.user;
      final adminId = userData?['id'] as int? ?? 0;
      final adminName = userData?['name'] as String? ?? 'Admin';
      
      // Create admin model with actual ID from backend
      state = AdminModel(
        id: adminId,
        phone: phone,
        name: adminName,
        createdAt: DateTime.now(),
      );
      
      // Save admin info to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_phone', phone);
      await prefs.setString('admin_name', adminName);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
    
    // Clear saved admin info
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_phone');
    await prefs.remove('admin_name');
  }
}

// Customer authentication provider
final customerAuthProvider = StateNotifierProvider<CustomerAuthNotifier, CustomerModel?>((ref) {
  return CustomerAuthNotifier(ref.read(authServiceProvider));
});

class CustomerAuthNotifier extends StateNotifier<CustomerModel?> {
  final AuthService _authService;

  CustomerAuthNotifier(this._authService) : super(null) {
    _loadSavedCustomer();
  }

  Future<void> _loadSavedCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCustomerId = prefs.getInt('customer_id');
    final savedPhone = prefs.getString('customer_phone');
    final savedName = prefs.getString('customer_name');
    
    if (savedCustomerId != null && savedPhone != null && savedName != null) {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        state = CustomerModel(
          id: savedCustomerId,
          phone: savedPhone,
          name: savedName,
          createdAt: DateTime.now(),
        );
      }
    }
  }

  Future<void> loginWithPhone(String phone, String name) async {
    try {
      final authResponse = await _authService.customerLogin(phone, name);
      
      // Extract customer data from auth response
      final userData = authResponse.user;
      final customerId = userData?['id'] as int? ?? 0;
      
      // Create customer model with actual ID from backend
      final customer = CustomerModel(
        id: customerId,
        phone: phone,
        name: name,
        createdAt: DateTime.now(),
      );
      
      state = customer;
      
      // Save customer info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('customer_id', customer.id);
      await prefs.setString('customer_phone', phone);
      await prefs.setString('customer_name', name);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
    
    // Clear saved customer info
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customer_id');
    await prefs.remove('customer_phone');
    await prefs.remove('customer_name');
  }
}

// Cart provider
final cartProvider = ChangeNotifierProvider<CartNotifier>((ref) {
  return CartNotifier();
});

// Categories provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final categoryService = ref.read(categoryServiceProvider);
  return await categoryService.getCategories();
});

// Products provider
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProducts();
});

// Products by category provider
final productsByCategoryProvider = FutureProvider.family<List<ProductModel>, int>((ref, categoryId) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProducts(categoryId: categoryId);
});

// Discount provider
final discountProvider = FutureProvider<double>((ref) async {
  final settingsService = ref.read(settingsServiceProvider);
  return await settingsService.getDiscount();
});

// Discount notifier
final discountNotifierProvider = Provider<DiscountNotifier>((ref) {
  final settingsService = ref.read(settingsServiceProvider);
  return DiscountNotifier(settingsService, ref);
});

class DiscountNotifier {
  final SettingsService _settingsService;
  final Ref _ref;

  DiscountNotifier(this._settingsService, this._ref);

  Future<void> updateDiscount(double percentage) async {
    await _settingsService.updateDiscount(percentage);
    // Invalidate the discount provider to refresh the data
    _ref.invalidate(discountProvider);
  }
}

// Orders provider (for admin)
final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getOrders();
});

// Customer orders provider
final customerOrdersProvider = FutureProvider.family<List<OrderModel>, int>((ref, customerId) async {
  final orderService = ref.read(orderServiceProvider);
  return await orderService.getCustomerOrders(customerId);
});
