import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../providers.dart';
import '../role_selection/role_selection_screen.dart';
import 'home/customer_home_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/customer_orders_screen.dart';

class CustomerMainScreen extends ConsumerStatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CustomerHomeScreen(),
    CartScreen(),
    CustomerOrdersScreen(),
  ];

  final List<String> _titles = const [
    'KGS Shop',
    'My Cart',
    'My Orders',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(customerAuthProvider.notifier).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
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
              tabs: [
                const GButton(
                  icon: Icons.home_rounded,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.shopping_cart_rounded,
                  text: 'Cart',
                  leading: _buildCartIconWithBadge(),
                ),
                const GButton(
                  icon: Icons.receipt_long_rounded,
                  text: 'Orders',
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

  Widget _buildCartIconWithBadge() {
    final cart = ref.watch(cartProvider);
    final itemCount = cart.itemCount;

    return Badge(
      label: Text('$itemCount'),
      isLabelVisible: itemCount > 0,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      child: Icon(
        Icons.shopping_cart_rounded,
        color: _currentIndex == 1 ? AppColors.primary : AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
