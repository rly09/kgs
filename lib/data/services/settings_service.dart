import '../api/api_client.dart';
import '../api/api_constants.dart';
import '../models/settings_model.dart';

class SettingsService {
  final ApiClient _apiClient;
  
  SettingsService(this._apiClient);
  
  Future<double> getDiscount() async {
    final response = await _apiClient.get(ApiConstants.discount);
    final discountResponse = DiscountResponse.fromJson(response.data);
    return discountResponse.discountPercentage;
  }
  
  Future<double> updateDiscount(double percentage) async {
    final response = await _apiClient.put(
      '${ApiConstants.discount}?discount=$percentage',
    );
    final discountResponse = DiscountResponse.fromJson(response.data);
    return discountResponse.discountPercentage;
  }
}
