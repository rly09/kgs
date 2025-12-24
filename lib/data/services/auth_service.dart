import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _apiClient;
  
  AuthService(this._apiClient);
  
  Future<AuthResponse> adminLogin(String phone, String password) async {
    final response = await _apiClient.post(
      ApiConstants.adminLogin,
      data: {
        'phone': phone,
        'password': password,
      },
    );
    
    final authResponse = AuthResponse.fromJson(response.data);
    await _apiClient.saveToken(authResponse.accessToken);
    return authResponse;
  }
  
  Future<AuthResponse> customerLogin(String phone, String name) async {
    final response = await _apiClient.post(
      ApiConstants.customerLogin,
      data: {
        'phone': phone,
        'name': name,
      },
    );
    
    final authResponse = AuthResponse.fromJson(response.data);
    await _apiClient.saveToken(authResponse.accessToken);
    return authResponse;
  }
  
  Future<void> logout() async {
    await _apiClient.clearToken();
  }
  
  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null;
  }
}
