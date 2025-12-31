import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/services/auth_service.dart';
import 'data/services/category_service.dart';
import 'data/services/product_service.dart';
import 'data/services/order_service.dart';
import 'data/services/settings_service.dart';
import 'data/services/admin_service.dart';
import 'data/models/auth_models.dart';
import 'data/models/category_model.dart';
import 'data/models/product_model.dart';
import 'data/models/order_model.dart';
import 'presentation/customer/cart/cart_notifier.dart';

// Service providers (no longer need API client)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
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

  Future<bool> login(String email, String password) async {
    try {
      final authResponse = await _authService.adminLogin(email, password);
      
      // Extract admin data from auth response
      final userData = authResponse.user;
      if (userData == null) {
        return false;
      }
      
      // Create admin model with actual ID from backend
      state = AdminModel(
        id: userData.id,
        email: email,
        name: userData.name,
        createdAt: DateTime.now(),
      );
      
      // Save admin info to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_email', email);
      await prefs.setString('admin_name', userData.name);
      
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
    await prefs.remove('admin_email');
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
      if (userData == null) {
        throw Exception('Login failed');
      }
      
      // Create customer model with actual ID from backend
      final customer = CustomerModel(
        id: userData.id,
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

// Products provider with real-time updates
final productsProvider = StreamProvider<List<ProductModel>>((ref) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsStream();
});

// Products by category with real-time updates
final productsByCategoryProvider = StreamProvider.family<List<ProductModel>, int?>((ref, categoryId) {
  final productService = ref.watch(productServiceProvider);
  return productService.getProductsByCategoryStream(categoryId);
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
