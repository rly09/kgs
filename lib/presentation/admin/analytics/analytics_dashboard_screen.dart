import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';

// Analytics data provider using API
final analyticsDataProvider = FutureProvider<AnalyticsData>((ref) async {
  final orderService = ref.watch(orderServiceProvider);
  final productService = ref.watch(productServiceProvider);
  
  // Get all orders and products from API
  final orders = await orderService.getOrders();
  final products = await productService.getProducts();
  
  // Calculate metrics
  final totalRevenue = orders
      .where((o) => o.status == 'DELIVERED')
      .fold(0.0, (sum, order) => sum + order.totalAmount);
  
  final totalOrders = orders.length;
  final pendingOrders = orders.where((o) => o.status == 'PENDING').length;
  final deliveredOrders = orders.where((o) => o.status == 'DELIVERED').length;
  final cancelledOrders = orders.where((o) => o.status == 'CANCELLED').length;
  
  // Calculate top products from order items
  final productSales = <int, int>{};
  final productRevenue = <int, double>{};
  
  for (var order in orders) {
    for (var item in order.items) {
      productSales[item.productId] = (productSales[item.productId] ?? 0) + item.quantity;
      productRevenue[item.productId] = (productRevenue[item.productId] ?? 0) + (item.priceAtOrder * item.quantity);
    }
  }
  
  final topProductIds = productSales.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final topProducts = <ProductSales>[];
  for (var entry in topProductIds.take(5)) {
    final product = products.where((p) => p.id == entry.key).firstOrNull;
    if (product != null) {
      topProducts.add(ProductSales(
        productName: product.name,
        quantitySold: entry.value,
        revenue: productRevenue[entry.key] ?? 0,
      ));
    }
  }
  
  // Recent orders (already sorted by createdAt desc from API)
  final recentOrders = orders.take(5).toList();
  
  return AnalyticsData(
    totalRevenue: totalRevenue,
    totalOrders: totalOrders,
    pendingOrders: pendingOrders,
    deliveredOrders: deliveredOrders,
    cancelledOrders: cancelledOrders,
    totalProducts: products.length,
    lowStockProducts: products.where((p) => p.stock < 10).length,
    topProducts: topProducts,
    recentOrders: recentOrders,
  );
});

class AnalyticsData {
  final double totalRevenue;
  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final int totalProducts;
  final int lowStockProducts;
  final List<ProductSales> topProducts;
  final List<OrderModel> recentOrders;

  AnalyticsData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.topProducts,
    required this.recentOrders,
  });
}

class ProductSales {
  final String productName;
  final int quantitySold;
  final double revenue;

  ProductSales({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: analyticsAsync.when(
        data: (analytics) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Card
              _MetricCard(
                title: 'Total Revenue',
                value: Formatters.formatCurrency(analytics.totalRevenue),
                icon: Icons.currency_rupee_rounded,
                color: AppColors.success,
                subtitle: 'From delivered orders',
              ),
              
              const SizedBox(height: AppDimensions.space),
              
              // Order Statistics Grid
              Row(
                children: [
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Total Orders',
                      value: analytics.totalOrders.toString(),
                      icon: Icons.shopping_bag_rounded,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space),
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Pending',
                      value: analytics.pendingOrders.toString(),
                      icon: Icons.schedule_rounded,
                      color: AppColors.statusPending,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.space),
              
              Row(
                children: [
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Delivered',
                      value: analytics.deliveredOrders.toString(),
                      icon: Icons.done_all_rounded,
                      color: AppColors.statusDelivered,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space),
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Cancelled',
                      value: analytics.cancelledOrders.toString(),
                      icon: Icons.cancel_rounded,
                      color: AppColors.statusCancelled,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.space),
              
              // Product Statistics
              Row(
                children: [
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Total Products',
                      value: analytics.totalProducts.toString(),
                      icon: Icons.inventory_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space),
                  Expanded(
                    child: _SmallMetricCard(
                      title: 'Low Stock',
                      value: analytics.lowStockProducts.toString(),
                      icon: Icons.warning_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceLarge),
              
              // Top Products Section
              Text(
                'Top Selling Products',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppDimensions.space),
              
              if (analytics.topProducts.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Center(
                      child: Text(
                        'No sales data yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...analytics.topProducts.map((product) => Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      product.productName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${product.quantitySold} units sold',
                      style: AppTextStyles.caption,
                    ),
                    trailing: Text(
                      Formatters.formatCurrency(product.revenue),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
              
              const SizedBox(height: AppDimensions.spaceLarge),
              
              // Recent Orders Section
              Text(
                'Recent Orders',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppDimensions.space),
              
              if (analytics.recentOrders.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Center(
                      child: Text(
                        'No orders yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...analytics.recentOrders.map((order) => Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Icon(
                        _getStatusIcon(order.status),
                        color: _getStatusColor(order.status),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Order #${order.id}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      Formatters.formatDateTime(order.createdAt),
                      style: AppTextStyles.caption,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatCurrency(order.totalAmount),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(order.status),
                            style: AppTextStyles.caption.copyWith(
                              color: _getStatusColor(order.status),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimensions.space),
              Text(
                'Error loading analytics',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.statusPending;
      case 'ACCEPTED':
        return AppColors.statusConfirmed;
      case 'OUT_FOR_DELIVERY':
        return AppColors.statusPreparing;
      case 'DELIVERED':
        return AppColors.statusDelivered;
      case 'CANCELLED':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule_rounded;
      case 'ACCEPTED':
        return Icons.check_circle_outline_rounded;
      case 'OUT_FOR_DELIVERY':
        return Icons.local_shipping_rounded;
      case 'DELIVERED':
        return Icons.done_all_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status.substring(0, 1) + status.substring(1).toLowerCase();
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.padding),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: AppDimensions.space),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXSmall),
                  Text(
                    value,
                    style: AppTextStyles.heading2.copyWith(
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppDimensions.spaceXSmall),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
                Text(
                  value,
                  style: AppTextStyles.heading3.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
