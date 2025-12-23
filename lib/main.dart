import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/role_selection/role_selection_screen.dart';
import 'presentation/admin/admin_main_screen.dart';
import 'presentation/customer/customer_main_screen.dart';
import 'providers.dart';

void main() {
  runApp(const ProviderScope(child: KGSApp()));
}

class KGSApp extends ConsumerWidget {
  const KGSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminAuthProvider);
    final customer = ref.watch(customerAuthProvider);

    return MaterialApp(
      title: 'KGS Shop',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: admin != null
          ? const AdminMainScreen()
          : customer != null
              ? const CustomerMainScreen()
              : const RoleSelectionScreen(),
    );
  }
}
