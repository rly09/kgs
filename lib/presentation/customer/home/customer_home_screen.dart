import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../providers.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../cart/cart_screen.dart';

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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.padding),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
            ),
          ),

          // Categories
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padding),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: _selectedCategoryId == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                          },
                          backgroundColor: AppColors.surfaceLight,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedCategoryId == null
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }

                    final category = categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                          });
                        },
                        backgroundColor: AppColors.surfaceLight,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedCategoryId == category.id
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppDimensions.space),

          // Products Grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                // Filter products by search query
                final filteredProducts = products.where((product) {
                  if (_searchQuery.isEmpty) return true;
                  return product.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppDimensions.space),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No products available'
                              : 'No products found',
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
                      'Error loading products',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: AppDimensions.spaceSmall),
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_selectedCategoryId == null) {
                          ref.invalidate(productsProvider);
                        } else {
                          ref.invalidate(productsByCategoryProvider(_selectedCategoryId!));
                        }
                      },
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

class _ProductCard extends ConsumerWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final isInCart = cart.items.containsKey(product.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 120,
            width: double.infinity,
            color: AppColors.surfaceLight,
            child: product.imagePath != null
                ? Image.network(
                    'https://kgs-backend-ej2z.onrender.com${product.imagePath}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      );
                    },
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatCurrency(product.price),
                    style: AppTextStyles.price.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  if (product.stock > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isInCart) {
                            cart.removeItem(product.id);
                          } else {
                            cart.addItem(
                              product.id,
                              product.name,
                              product.price,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isInCart ? AppColors.error : AppColors.primary,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: Text(
                          isInCart ? 'Remove' : 'Add to Cart',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Text(
                        'Out of Stock',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
