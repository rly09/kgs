import '../api/api_client.dart';
import '../api/api_constants.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  /// Update admin phone number
  Future<Map<String, dynamic>> updatePhone(String newPhone) async {
    final response = await _apiClient.put(
      '${ApiConstants.admin}/update-phone',
      data: {'new_phone': newPhone},
    );
    return response.data;
  }

  /// Update admin password
  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.admin}/update-password',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
    return response.data;
  }

  /// Upload product image
  Future<String> uploadProductImage({
    required List<int> bytes,
    required String filename,
  }) async {
    final response = await _apiClient.uploadFileBytes(
      '${ApiConstants.products}/upload-image',
      bytes: bytes,
      filename: filename,
    );
    return response.data['image_path'] as String;
  }
}
