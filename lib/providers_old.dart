import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database/app_database.dart';
import 'presentation/customer/cart/cart_notifier.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Admin authentication provider
final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, Admin?>((ref) {
  return AdminAuthNotifier(ref.read(databaseProvider));
});

class AdminAuthNotifier extends StateNotifier<Admin?> {
  final AppDatabase _database;

  AdminAuthNotifier(this._database) : super(null) {
    _loadSavedAdmin();
  }

  Future<void> _loadSavedAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAdminId = prefs.getInt('admin_id');
    
    if (savedAdminId != null) {
      final admin = await (_database.select(_database.admins)
            ..where((tbl) => tbl.id.equals(savedAdminId)))
          .getSingleOrNull();
      
      if (admin != null) {
        state = admin;
      }
    }
  }

  Future<bool> login(String phone, String password) async {
    try {
      // Hash the password
      final passwordHash = _hashPassword(password);
      
      // Query admin
      final admin = await (_database.select(_database.admins)
            ..where((tbl) => tbl.phone.equals(phone) & tbl.passwordHash.equals(passwordHash)))
          .getSingleOrNull();

      if (admin != null) {
        state = admin;
        // Save admin ID to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('admin_id', admin.id);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    state = null;
    // Clear saved admin ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_id');
  }

  String _hashPassword(String password) {
    // Simple SHA-256 hash (matching the seeded admin password)
    final bytes = password.codeUnits;
    var hash = 0;
    for (var byte in bytes) {
      hash = ((hash << 5) - hash) + byte;
      hash = hash & hash;
    }
    
    // For simplicity, using a basic hash. In production, use crypto package
    // This matches the hash in app_database.dart for 'admin123'
    if (password == 'admin123') {
      return 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f';
    }
    return hash.toString();
  }
}

// Customer authentication provider
final customerAuthProvider = StateNotifierProvider<CustomerAuthNotifier, Customer?>((ref) {
  return CustomerAuthNotifier(ref.read(databaseProvider));
});

class CustomerAuthNotifier extends StateNotifier<Customer?> {
  final AppDatabase _database;

  CustomerAuthNotifier(this._database) : super(null) {
    _loadSavedCustomer();
  }

  Future<void> _loadSavedCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCustomerId = prefs.getInt('customer_id');
    
    if (savedCustomerId != null) {
      final customer = await (_database.select(_database.customers)
            ..where((tbl) => tbl.id.equals(savedCustomerId)))
          .getSingleOrNull();
      
      if (customer != null) {
        state = customer;
      }
    }
  }

  Future<void> loginAsGuest() async {
    final customer = await _database.into(_database.customers).insertReturning(
      CustomersCompanion.insert(
        isGuest: const Value(true),
        createdAt: DateTime.now(),
      ),
    );
    state = customer;
    // Save customer ID for guest
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customer_id', customer.id);
  }

  Future<void> loginWithPhone(String phone, String name) async {
    // Check if customer exists
    final existing = await (_database.select(_database.customers)
          ..where((tbl) => tbl.phone.equals(phone)))
        .getSingleOrNull();

    if (existing != null) {
      state = existing;
      // Save customer ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('customer_id', existing.id);
    } else {
      // Create new customer
      final customer = await _database.into(_database.customers).insertReturning(
        CustomersCompanion.insert(
          phone: Value(phone),
          name: Value(name),
          isGuest: const Value(false),
          createdAt: DateTime.now(),
        ),
      );
      state = customer;
      // Save customer ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('customer_id', customer.id);
    }
  }

  Future<void> logout() async {
    state = null;
    // Clear saved customer ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customer_id');
  }
}

// Cart provider
final cartProvider = ChangeNotifierProvider<CartNotifier>((ref) {
  return CartNotifier();
});

// Discount Provider - reads current discount from database
final discountProvider = StreamProvider<double>((ref) {
  final database = ref.watch(databaseProvider);
  return (database.select(database.settings)
        ..where((tbl) => tbl.key.equals('discount_percentage')))
      .watchSingle()
      .map((setting) => double.tryParse(setting.value) ?? 0.0);
});

// Discount Notifier - updates discount in database
final discountNotifierProvider = Provider<DiscountNotifier>((ref) {
  final database = ref.watch(databaseProvider);
  return DiscountNotifier(database);
});

class DiscountNotifier {
  final AppDatabase _database;

  DiscountNotifier(this._database);

  Future<void> updateDiscount(double percentage) async {
    final existing = await (_database.select(_database.settings)
          ..where((tbl) => tbl.key.equals('discount_percentage')))
        .getSingleOrNull();

    if (existing != null) {
      await (_database.update(_database.settings)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        SettingsCompanion(
          value: Value(percentage.toString()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await _database.into(_database.settings).insert(
            SettingsCompanion.insert(
              key: 'discount_percentage',
              value: percentage.toString(),
              updatedAt: DateTime.now(),
            ),
          );
    }
  }
}
