import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers.dart';
import '../../../data/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

// Provider for customer orders
final customerOrdersProvider = StreamProvider.family<List<Order>, int>((ref, customerId) {
  final database = ref.watch(databaseProvider);
  return (database.select(database.orders)
        ..where((tbl) => tbl.customerId.equals(customerId))
        ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
      .watch();
});

class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerAuthProvider);
    
    if (customer == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Orders'), backgroundColor: AppColors.background),
        body: const Center(child: Text('Please login to view orders')),
      );
    }

    final ordersAsync = ref.watch(customerOrdersProvider(customer.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppDimensions.space),
                  Text(
                    'No orders yet',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  Text(
                    'Your order history will appear here',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.padding),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(
                order: order,
                statusColor: _getStatusColor(order.status),
                statusIcon: _getStatusIcon(order.status),
                statusText: _getStatusText(order.status),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading orders',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          _showOrderDetails(context, ref);
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatDateTime(order.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: AppTextStyles.label.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    Formatters.formatCurrency(order.totalAmount),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
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

  void _showOrderDetails(BuildContext context, WidgetRef ref) async {
    final database = ref.read(databaseProvider);
    final orderItems = await (database.select(database.orderItems)
          ..where((tbl) => tbl.orderId.equals(order.id)))
        .get();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.padding),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: AppTextStyles.heading3,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppDimensions.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Timeline
                    _OrderTimeline(status: order.status),

                    const SizedBox(height: AppDimensions.spaceLarge),

                    // Order Items
                    Text('Items', style: AppTextStyles.heading3), // Mapped heading4->heading3 usage check? heading4 is alias now so OK.
                    const SizedBox(height: AppDimensions.space),
                    ...orderItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.textTertiary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Qty: ${item.quantity}',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                      );
                    }),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: AppTextStyles.heading3),
                        Text(
                          Formatters.formatCurrency(order.totalAmount),
                          style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.spaceLarge),

                    // Delivery & Payment
                    Text('Information', style: AppTextStyles.heading3),
                    const SizedBox(height: AppDimensions.space),
                    _DetailRow('Address', order.deliveryAddress),
                    _DetailRow('Phone', Formatters.formatPhone(order.customerPhone)),
                    _DetailRow('Payment', order.paymentMode == 'COD' ? 'Cash by Hand' : 'Online'),
                    if (order.note != null) _DetailRow('Note', order.note!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final String status;

  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'status': 'PENDING', 'label': 'Pending', 'icon': Icons.schedule_rounded},
      {'status': 'ACCEPTED', 'label': 'Accepted', 'icon': Icons.check_circle_outline_rounded},
      {'status': 'OUT_FOR_DELIVERY', 'label': 'In Transit', 'icon': Icons.local_shipping_outlined},
      {'status': 'DELIVERED', 'label': 'Delivered', 'icon': Icons.done_all_rounded},
    ];

    final currentIndex = status == 'CANCELLED' 
        ? -1 
        : steps.indexWhere((s) => s['status'] == status);

    if (status == 'CANCELLED') {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.padding),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error),
            const SizedBox(width: 12),
            Text(
              'This order was cancelled',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Row(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0 ? Colors.transparent : (isCompleted ? AppColors.primary : AppColors.divider),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primary : AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isLast ? Colors.transparent : (index < currentIndex ? AppColors.primary : AppColors.divider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step['label'] as String,
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: isCompleted ? AppColors.textPrimary : AppColors.textTertiary,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
