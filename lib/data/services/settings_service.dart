import '../../core/supabase_config.dart';
import '../models/settings_model.dart';

class SettingsService {
  final _supabase = SupabaseConfig.client;
  
  /// Get discount percentage
  Future<double> getDiscount() async {
    try {
      final response = await _supabase
          .from('settings')
          .select('value')
          .eq('key', 'discount_percentage')
          .maybeSingle();
      
      if (response == null) {
        return 0.0;
      }
      
      return double.tryParse(response['value'] as String) ?? 0.0;
    } catch (e) {
      throw Exception('Failed to fetch discount: ${e.toString()}');
    }
  }
  
  /// Update discount percentage
  Future<double> updateDiscount(double percentage) async {
    try {
      // Check if setting exists
      final existing = await _supabase
          .from('settings')
          .select()
          .eq('key', 'discount_percentage')
          .maybeSingle();
      
      if (existing == null) {
        // Insert new
        await _supabase
            .from('settings')
            .insert({
              'key': 'discount_percentage',
              'value': percentage.toString(),
            });
      } else {
        // Update existing
        await _supabase
            .from('settings')
            .update({'value': percentage.toString()})
            .eq('key', 'discount_percentage');
      }
      
      return percentage;
    } catch (e) {
      throw Exception('Failed to update discount: ${e.toString()}');
    }
  }
}
