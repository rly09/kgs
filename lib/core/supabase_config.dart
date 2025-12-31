import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization
class SupabaseConfig {
  // Supabase credentials
  static const String supabaseUrl = 'https://qokcfsvbcnxqfjcujctg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFva2Nmc3ZiY254cWZqY3VqY3RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcxNzEwNTgsImV4cCI6MjA4Mjc0NzA1OH0.-q_cApU2qOCOGXEwrrU9Sk_jDmmGPrexmkjLaVsMDgA';
  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
}
