import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers.dart';
import '../../../data/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

// Provider for orders with items
final ordersProvider = StreamProvider<List<Order>>((ref) {
  final database = ref.watch(databaseProvider);
  return (database.select(database.orders)
    ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).watch();
});

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
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter tabs - Minimal
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padding),
              children: [
                _FilterChip('All', 'ALL', _selectedFilter, (val) => setState(() => _selectedFilter = val)),
                const SizedBox(width: 8),
                _FilterChip('Pending', 'PENDING', _selectedFilter, (val) => setState(() => _selectedFilter = val)),
                const SizedBox(width: 8),
                _FilterChip('Accepted', 'ACCEPTED', _selectedFilter, (val) => setState(() => _selectedFilter = val)),
                 const SizedBox(width: 8),
                _FilterChip('In Transit', 'OUT_FOR_DELIVERY', _selectedFilter, (val) => setState(() => _selectedFilter = val)),
                 const SizedBox(width: 8),
                _FilterChip('Delivered', 'DELIVERED', _selectedFilter, (val) => setState(() => _selectedFilter = val)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Orders list
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
                          Icons.inbox_rounded,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppDimensions.space),
                        Text(
                          'No orders found',
                          style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.padding),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderCard(order: order);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error loading orders')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Function(String) onChanged;

  const _FilterChip(this.label, this.value, this.groupValue, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
             fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;

  const _OrderCard({required this.order});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(context, ref),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
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
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                       color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      order.status.replaceAll('_', ' '),
                      style: AppTextStyles.label.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textTertiary),
                   const SizedBox(width: 4),
                   Text(order.customerName, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Formatters.formatDateTime(order.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                  ),
                  Text(
                    Formatters.formatCurrency(order.totalAmount),
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.padding),
               decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Details', style: AppTextStyles.heading3),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
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
                    // Customer
                    Text('Customer', style: AppTextStyles.heading3), // heading4->3
                    const SizedBox(height: 8),
                    _DetailRow('Name', order.customerName),
                    _DetailRow('Phone', Formatters.formatPhone(order.customerPhone)),
                    _DetailRow('Address', order.deliveryAddress),
                    if (order.note != null) _DetailRow('Note', order.note!),

                    const SizedBox(height: 24),

                    // Items
                    Text('Items', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    ...orderItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${item.productName} x${item.quantity}', style: AppTextStyles.bodyMedium),
                          ),
                          Text(
                            Formatters.formatCurrency(item.priceAtOrder * item.quantity),
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
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
                    const SizedBox(height: 32),

                    // Actions
                    if (order.status == 'PENDING') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                 await _updateStatus(context, ref, 'CANCELLED', 'Order cancelled', isError: true);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(color: AppColors.error),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _updateStatus(context, ref, 'ACCEPTED', 'Order accepted');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors.success,
                                elevation: 0,
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (order.status == 'ACCEPTED') ...[
                       SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _updateStatus(context, ref, 'OUT_FOR_DELIVERY', 'Marked as In Transit');
                          },
                           style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                           ),
                          child: const Text('Dispatch Order'),
                        ),
                      ),
                    ] else if (order.status == 'OUT_FOR_DELIVERY') ...[
                       SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                             await _updateStatus(context, ref, 'DELIVERED', 'Order Delivered');
                          },
                           style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.success,
                              elevation: 0,
                           ),
                          child: const Text('Complete Delivery'),
                        ),
                      ),
                    ],
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
    final database = ref.read(databaseProvider);
    await database.update(database.orders).replace(
      order.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      ),
    );
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
