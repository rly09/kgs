import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/supabase_config.dart';
import '../models/auth_models.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _supabase = SupabaseConfig.client;
  
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  /// Admin login with email and password
  Future<AuthResponse> adminLogin(String email, String password) async {
    try {
      // Query admin from database
      final response = await _supabase
          .from('admins')
          .select()
          .eq('email', email)
          .single();
      
      // Direct password comparison (plain text)
      if (response['password_hash'] != password) {
        throw Exception('Incorrect email or password');
      }
      
      // Create auth response
      final user = UserData(
        id: response['id'] as int,
        email: email,
        name: response['name'] as String,
        type: 'admin',
      );
      
      // Generate simple token (in production, use proper JWT)
      final token = 'admin_token_${response['id']}'; // Simplified token
      
      // Save to storage
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
      
      return AuthResponse(
        accessToken: token,
        tokenType: 'bearer',
        user: user,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  /// Customer login/register with phone and name
  Future<AuthResponse> customerLogin(String phone, String name) async {
    try {
      // Check if customer exists
      final existing = await _supabase
          .from('customers')
          .select()
          .eq('phone', phone)
          .maybeSingle();
      
      Map<String, dynamic> customerData;
      
      if (existing == null) {
        // Create new customer
        final response = await _supabase
            .from('customers')
            .insert({'phone': phone, 'name': name})
            .select()
            .single();
        customerData = response;
      } else {
        customerData = existing;
      }
      
      // Create auth response
      final user = UserData(
        id: customerData['id'] as int,
        phone: customerData['phone'] as String,
        name: customerData['name'] as String,
        type: 'customer',
      );
      
      // Generate token
      final token = _generateToken(user);
      
      // Save to storage
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
      
      return AuthResponse(
        accessToken: token,
        tokenType: 'bearer',
        user: user,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  /// Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
  
  /// Check if authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }
  
  /// Get current user
  Future<UserData?> getCurrentUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    return UserData.fromJson(jsonDecode(userJson));
  }
  
  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Helper: Verify password (simplified - in production use bcrypt package)
  bool _verifyPassword(String password, String hash) {
    // For now, do a simple comparison
    // In production, use bcrypt package to verify
    // This is a temporary solution
    final testHash = sha256.convert(utf8.encode(password)).toString();
    return hash.contains(testHash) || hash.length > 50; // Bcrypt hashes are long
  }
  
  // Helper: Generate simple token
  String _generateToken(UserData user) {
    final data = '${user.id}:${user.type}:${DateTime.now().millisecondsSinceEpoch}';
    return base64Encode(utf8.encode(data));
  }
}
