import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../providers.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItems = cart.items.values.toList();

    return cartItems.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppDimensions.space),
                Text(
                  'Your cart is empty',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                Text(
                  'Sort out your daily needs',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ResponsiveHelper.constrainedContent(
                  context,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsivePadding(context),
                      vertical: AppDimensions.paddingSmall,
                    ),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _CartItemRow(item: item);
                    },
                  ),
                ),
              ),
              // Bottom total and checkout - Flat & Minimal with top border
              Container(
                padding: const EdgeInsets.all(AppDimensions.padding),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // shrink wrap
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.heading3,
                          ),
                          Text(
                            Formatters.formatCurrency(cart.totalAmount),
                            style: AppTextStyles.heading2,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space),
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class _CartItemRow extends ConsumerWidget {
  final dynamic item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.image_not_supported_rounded,
              color: AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.space),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(item.price),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock: ${item.maxStock}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Minimal Quantity Control
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      onTap: () {
                        ref.read(cartProvider).decrementQuantity(item.productId);
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.quantity}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      isDisabled: !item.canIncrement,
                      onTap: () {
                        final success = ref.read(cartProvider).incrementQuantity(item.productId);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Maximum stock (${item.maxStock}) reached for ${item.productName}'),
                              backgroundColor: AppColors.error,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove Button
          IconButton(
            onPressed: () {
              ref.read(cartProvider).removeItem(item.productId);
            },
            icon: Icon(Icons.close_rounded, size: 20, color: AppColors.textTertiary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  const _QuantityButton({
    required this.icon, 
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled ? AppColors.border.withOpacity(0.3) : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Icon(
          icon, 
          size: 16, 
          color: isDisabled ? AppColors.textTertiary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
