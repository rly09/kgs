import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'categories/category_management_screen.dart';
import 'products/product_management_screen.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    CategoryManagementScreen(),
    ProductManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: AppColors.primary.withOpacity(0.1),
              hoverColor: AppColors.primary.withOpacity(0.1),
              gap: 8,
              activeColor: AppColors.primary,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppColors.primary.withOpacity(0.1),
              color: AppColors.textSecondary,
              tabs: const [
                GButton(
                  icon: Icons.dashboard_rounded,
                  text: 'Dashboard',
                ),
                GButton(
                  icon: Icons.category_rounded,
                  text: 'Categories',
                ),
                GButton(
                  icon: Icons.inventory_rounded,
                  text: 'Products',
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
