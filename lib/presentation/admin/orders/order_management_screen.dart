import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers.dart';
import '../../../data/models/order_model.dart';
import '../delivery/delivery_map_screen.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.padding,
                vertical: AppDimensions.paddingSmall,
              ),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'ALL',
                  onTap: () => setState(() => _selectedFilter = 'ALL'),
                ),
                _FilterChip(
                  label: 'Pending',
                  isSelected: _selectedFilter == 'PENDING',
                  onTap: () => setState(() => _selectedFilter = 'PENDING'),
                ),
                _FilterChip(
                  label: 'Confirmed',
                  isSelected: _selectedFilter == 'CONFIRMED',
                  onTap: () => setState(() => _selectedFilter = 'CONFIRMED'),
                ),
                _FilterChip(
                  label: 'Out for Delivery',
                  isSelected: _selectedFilter == 'OUT_FOR_DELIVERY',
                  onTap: () => setState(() => _selectedFilter = 'OUT_FOR_DELIVERY'),
                ),
                _FilterChip(
                  label: 'Delivered',
                  isSelected: _selectedFilter == 'DELIVERED',
                  onTap: () => setState(() => _selectedFilter = 'DELIVERED'),
                ),
                _FilterChip(
                  label: 'Cancelled',
                  isSelected: _selectedFilter == 'CANCELLED',
                  onTap: () => setState(() => _selectedFilter = 'CANCELLED'),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filteredOrders = _selectedFilter == 'ALL'
                    ? orders
                    : orders.where((o) => o.status == _selectedFilter).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppDimensions.space),
                        Text(
                          'No orders found',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.refresh(ordersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.padding),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _OrderCard(order: order);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimensions.space),
                    Text(
                      'Error loading orders',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(ordersProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
        labelStyle: AppTextStyles.label.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          side: BorderSide(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        elevation: 0,
        pressElevation: 0,
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'CONFIRMED':
        return AppColors.info;
      case 'OUT_FOR_DELIVERY':
        return AppColors.primary;
      case 'DELIVERED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.space),
      child: InkWell(
        onTap: () => _showOrderDetails(context, ref),
        borderRadius: BorderRadius.circular(AppDimensions.radius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      order.status,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Text(
                order.customerName,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                order.customerPhone,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.formatCurrency(order.totalAmount),
                    style: AppTextStyles.price,
                  ),
                  Text(
                    Formatters.formatDateTime(order.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: AppTextStyles.heading3,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Details
                    Text(
                      'Customer Details',
                      style: AppTextStyles.heading4,
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    _DetailRow(label: 'Name', value: order.customerName),
                    _DetailRow(label: 'Phone', value: order.customerPhone),
                    _DetailRow(label: 'Address', value: order.deliveryAddress),
                    _DetailRow(label: 'Payment', value: order.paymentMode),
                    if (order.note != null && order.note!.isNotEmpty)
                      _DetailRow(label: 'Note', value: order.note!),

                    const SizedBox(height: AppDimensions.space),

                    // Order Items
                    Text(
                      'Order Items',
                      style: AppTextStyles.heading4,
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    ...order.items.map((item) => Card(
                          margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Qty: ${item.quantity}',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  Formatters.formatCurrency(item.priceAtOrder * item.quantity),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),

                    const SizedBox(height: AppDimensions.space),

                    // Total
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.padding),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTextStyles.heading4,
                          ),
                          Text(
                            Formatters.formatCurrency(order.totalAmount),
                            style: AppTextStyles.price.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.space),

                    // Status Update Buttons
                    if (order.status != 'DELIVERED' && order.status != 'CANCELLED')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (order.status == 'PENDING')
                            ElevatedButton.icon(
                              onPressed: () {
                                _updateStatus(context, ref, 'CONFIRMED', 'Order confirmed');
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Confirm Order'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                              ),
                            ),
                          if (order.status == 'CONFIRMED')
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    // Update status to out_for_delivery
                                    await _updateStatus(context, ref, 'OUT_FOR_DELIVERY', 'Order is out for delivery');
                                    
                                    // Navigate to delivery map
                                    if (context.mounted) {
                                      Navigator.pop(context); // Close bottom sheet
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DeliveryMapScreen(order: order),
                                        ),
                                      ).then((delivered) {
                                        if (delivered == true) {
                                          ref.refresh(ordersProvider);
                                        }
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.delivery_dining),
                                  label: const Text('Out for Delivery'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spaceSmall),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _updateStatus(context, ref, 'DELIVERED', 'Order delivered');
                                  },
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Mark as Delivered'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          if (order.status == 'OUT_FOR_DELIVERY')
                            ElevatedButton.icon(
                              onPressed: () {
                                _updateStatus(context, ref, 'DELIVERED', 'Order delivered');
                              },
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Mark as Delivered'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                              ),
                            ),
                          const SizedBox(height: AppDimensions.spaceSmall),
                          OutlinedButton.icon(
                            onPressed: () {
                              _updateStatus(context, ref, 'CANCELLED', 'Order cancelled', isError: true);
                            },
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel Order'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String status, String message, {bool isError = false}) async {
    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(order.id, status);
      
      // Refresh orders list
      ref.refresh(ordersProvider);
      
      if (context.mounted) {
        // Don't pop if going to delivery map
        if (status != 'OUT_FOR_DELIVERY') {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? AppColors.error : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
