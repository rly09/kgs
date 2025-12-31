class ApiConstants {
  // Base URL - Production backend
  static const String baseUrl = 'https://backend-supabase-omega.vercel.app';
  static const String apiPrefix = '/api';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Endpoints
  // Auth
  static const String adminLogin = '$apiPrefix/auth/admin/login';
  static const String customerLogin = '$apiPrefix/auth/customer/login';
  
  // Categories
  static const String categories = '$apiPrefix/categories';
  static String categoryById(int id) => '$apiPrefix/categories/$id';
  
  // Products
  static const String products = '$apiPrefix/products';
  static String productById(int id) => '$apiPrefix/products/$id';
  static String productStock(int id) => '$apiPrefix/products/$id/stock';
  
  // Orders
  static const String orders = '$apiPrefix/orders';
  static String orderById(int id) => '$apiPrefix/orders/$id';
  static String orderStatus(int id) => '$apiPrefix/orders/$id/status';
  static String customerOrders(int customerId) => '$apiPrefix/orders/customer/$customerId';
  
  // Settings
  static const String discount = '$apiPrefix/settings/discount';
  
  // Admin
  static const String admin = '$apiPrefix/admin';
  static const String adminDashboard = '$apiPrefix/admin/dashboard';
  static const String adminAnalytics = '$apiPrefix/admin/analytics';
  
  // Headers
  static const String authHeader = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
}
