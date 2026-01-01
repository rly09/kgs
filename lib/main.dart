import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/customer/auth/customer_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String? initError;
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize Supabase
    await SupabaseConfig.initialize();
  } catch (e) {
    initError = e.toString();
    print('Initialization error: $e');
  }
  
  runApp(
    ProviderScope(
      child: KGSShopApp(initError: initError),
    ),
  );
}

class KGSShopApp extends StatelessWidget {
  final String? initError;
  
  const KGSShopApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    initError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return MaterialApp(
      title: 'KGS Shop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CustomerLoginScreen(),
    );
  }
}
