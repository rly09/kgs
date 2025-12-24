import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../providers.dart';
import '../../role_selection/role_selection_screen.dart';
import '../orders/order_management_screen.dart';
import '../analytics/analytics_dashboard_screen.dart';

// Provider for total revenue from API
final totalRevenueProvider = FutureProvider.autoDispose<double>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  final orders = await orderService.getOrders();
  
  return orders
      .where((o) => o.status == 'DELIVERED')
      .fold<double>(0.0, (sum, order) => sum + order.totalAmount);
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(totalRevenueProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
            onPressed: () async {
              await ref.read(adminAuthProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: ResponsiveHelper.constrainedContent(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Card - Minimal
            revenueAsync.when(
              data: (revenue) => InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsDashboardScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.currency_rupee_rounded,
                          size: 28,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Revenue',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(revenue),
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textTertiary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppDimensions.space),

            // Discount Card - Minimal
            const _DiscountCard(),

            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context) * 2),

            // Quick Actions Griders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Orders', style: AppTextStyles.heading3),
                TextButton(
                  onPressed: () {
                     Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrderManagementScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space),

            // Orders List
            const _OrdersList(),
          ],
        ),
        ),
      ),
    );
  }
}

// Provider for recent orders from API
final recentOrdersProvider = FutureProvider.autoDispose((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  final orders = await orderService.getOrders();
  // Return only the 5 most recent orders
  orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return orders.take(5).toList();
});

class _OrdersList extends ConsumerWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(recentOrdersProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Text(
                'No orders yet',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrderManagementScreen(),
                    // Ideally pass filter/focus to order
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.padding),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: _getStatusColor(order.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            order.customerName,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatCurrency(order.totalAmount),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDate(order.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error loading orders'),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return AppColors.warning;
      case 'ACCEPTED': return AppColors.info;
      case 'OUT_FOR_DELIVERY': return AppColors.primary;
      case 'DELIVERED': return AppColors.success;
      case 'CANCELLED': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }
}

class _DiscountCard extends ConsumerStatefulWidget {
  const _DiscountCard();

  @override
  ConsumerState<_DiscountCard> createState() => _DiscountCardState();
}

class _DiscountCardState extends ConsumerState<_DiscountCard> {
  final _discountController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _saveDiscount() async {
    final value = double.tryParse(_discountController.text);
    if (value == null || value < 0 || value > 100) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(discountNotifierProvider).updateDiscount(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: const Text('Discount updated'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {} finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountAsync = ref.watch(discountProvider);

    return discountAsync.when(
      data: (currentDiscount) {
        if (_discountController.text.isEmpty) {
          _discountController.text = currentDiscount.toStringAsFixed(0);
        }
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.discount_outlined, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text('Global Discount', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(
                    '${currentDiscount.toStringAsFixed(0)}%',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: '0-100',
                          suffixText: '%',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                             borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            borderSide: const BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveDiscount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Set'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
