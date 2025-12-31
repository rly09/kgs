import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../providers.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/empty_state_widget.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int? _selectedCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = _selectedCategoryId == null
        ? ref.watch(productsProvider)
        : ref.watch(productsByCategoryProvider(_selectedCategoryId!));
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search Bar with modern design
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
            ),
          ),

          // Categories with improved design
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider, width: 1),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsivePadding(context),
                    vertical: AppDimensions.paddingSmall,
                  ),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All Products'),
                          selected: _selectedCategoryId == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                          },
                          backgroundColor: AppColors.surfaceLight,
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _selectedCategoryId == null
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: _selectedCategoryId == null ? 2 : 0,
                        ),
                      );
                    }

                    final category = categories[index - 1];
                    final isSelected = _selectedCategoryId == category.id;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                          });
                        },
                        backgroundColor: AppColors.surfaceLight,
                        selectedColor: AppColors.primary,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: isSelected ? 2 : 0,
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Products Grid with enhanced design
          Expanded(
            child: productsAsync.when(
              data: (products) {
                // Filter products by search query
                final filteredProducts = products.where((product) {
                  if (_searchQuery.isEmpty) return true;
                  return product.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return EmptyStateWidget(
                    icon: _searchQuery.isEmpty
                        ? Icons.inventory_2_outlined
                        : Icons.search_off_rounded,
                    title: _searchQuery.isEmpty
                        ? 'No products available'
                        : 'No products found',
                    subtitle: _searchQuery.isEmpty
                        ? 'Check back later for new products'
                        : 'Try a different search term',
                    iconColor: AppColors.textSecondary,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_selectedCategoryId == null) {
                      ref.invalidate(productsProvider);
                    } else {
                      ref.invalidate(productsByCategoryProvider(_selectedCategoryId!));
                    }
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.getGridColumns(context),
                      childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(context),
                      crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context),
                      mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context),
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _ProductCard(product: product);
                    },
                  ),
                );
              },
              loading: () => ShimmerGrid(
                itemCount: 6,
                crossAxisCount: ResponsiveHelper.getGridColumns(context),
              ),
              error: (error, stack) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Error loading products',
                subtitle: 'Please try again',
                iconColor: AppColors.error,
                actionLabel: 'Retry',
                onAction: () {
                  if (_selectedCategoryId == null) {
                    ref.invalidate(productsProvider);
                  } else {
                    ref.invalidate(productsByCategoryProvider(_selectedCategoryId!));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final isInCart = cart.items.containsKey(product.id);
    final inCartQty = cart.items[product.id]?.quantity ?? 0;
    final remainingStock = product.stock - inCartQty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Image
                  if (product.imagePath != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        product.imagePath!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey),
                    ),
                  // Stock badge (top-left)
                  if (remainingStock <= 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Product Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Price and Add Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Price
                      Text(
                        Formatters.formatCurrency(product.price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Add Button or Counter
                      if (remainingStock > 0)
                        isInCart
                            ? _buildQuantityCounter(cart, inCartQty, remainingStock)
                            : _buildAddButton(cart, context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(cart, BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          final success = cart.addItem(
            product.id,
            product.name,
            product.price,
            product.stock,
          );
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stock limit reached for ${product.name}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: const Text(
            'ADD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityCounter(cart, int quantity, int maxQty) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          InkWell(
            onTap: () => cart.decrementItem(product.id),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          // Quantity
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Plus
          InkWell(
            onTap: quantity < maxQty
                ? () {
                    cart.addItem(
                      product.id,
                      product.name,
                      product.price,
                      product.stock,
                    );
                  }
                : null,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.add,
                color: quantity < maxQty ? Colors.white : Colors.white54,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
