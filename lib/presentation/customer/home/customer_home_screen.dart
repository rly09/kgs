import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../providers.dart';
import '../../role_selection/role_selection_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/customer_orders_screen.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int? _selectedCategoryId;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(customerAuthProvider);
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Material(
      color: AppColors.background,
      child: productsAsync.when(
        data: (products) {
          return categoriesAsync.when(
            data: (categories) {
              final filteredProducts = _selectedCategoryId == null
                  ? products
                  : products
                        .where((p) => p.categoryId == _selectedCategoryId)
                        .toList();

              final searchedProducts = _searchQuery.isEmpty
                  ? filteredProducts
                  : filteredProducts
                        .where(
                          (p) => p.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();

              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section - Minimal, no container
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding,
                        vertical: AppDimensions.paddingSmall,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${customer?.name ?? "Customer"}!',
                            style: AppTextStyles.heading2,
                          ),
                          const SizedBox(height: AppDimensions.spaceXSmall),
                          Text(
                            'Find your daily essentials',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar - Clean & Flat
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padding),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.padding,
                            vertical: AppDimensions.paddingMedium,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: AppDimensions.space),

                    // Category Filter - Minimal Pills
                    categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) return const SizedBox.shrink();

                        return SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.padding,
                            ),
                            children: [
                              _CategoryChip(
                                label: 'All',
                                isSelected: _selectedCategoryId == null,
                                onTap: () {
                                  setState(() => _selectedCategoryId = null);
                                },
                              ),
                              ...categories.map((category) {
                                return _CategoryChip(
                                  label: category.name,
                                  isSelected:
                                      _selectedCategoryId == category.id,
                                  onTap: () {
                                    setState(
                                      () => _selectedCategoryId = category.id,
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: AppDimensions.space),

                    // Products Grid - Clean
                    Expanded(
                      child: productsAsync.when(
                        data: (products) {
                          // Filter by category
                          var filteredProducts = _selectedCategoryId == null
                              ? products
                              : products
                                    .where(
                                      (p) =>
                                          p.categoryId == _selectedCategoryId,
                                    )
                                    .toList();

                          // Filter by search query
                          if (_searchQuery.isNotEmpty) {
                            filteredProducts = filteredProducts
                                .where(
                                  (p) => p.name.toLowerCase().contains(
                                    _searchQuery,
                                  ),
                                )
                                .toList();
                          }

                          if (filteredProducts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: AppDimensions.space),
                                  Text(
                                    'No products found',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padding),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: AppDimensions.space,
                                  mainAxisSpacing: AppDimensions.space,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return _ProductCard(product: product);
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading products',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error loading categories',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading products',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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

class _ProductCard extends ConsumerWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Minimal Image Placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_rounded, // Simpler icon
                  size: 32,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall), // Reduced padding inside card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                        product.isAvailable ? 'In Stock' : 'Out of Stock',
                         style: AppTextStyles.bodySmall.copyWith(
                           color: product.isAvailable ? AppColors.success : AppColors.error,
                           fontSize: 10,
                         ),
                      ),
                    ],
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.formatCurrency(product.price),
                        style: AppTextStyles.price,
                      ),
                      
                      // Minimal Add Button
                      Material(
                        color: product.isAvailable ? AppColors.primary : AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: product.isAvailable ? () {
                            ref.read(cartProvider).addItem(
                                  product.id,
                                  product.name,
                                  product.price,
                                );
                             ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.textPrimary,
                                ),
                              );
                          } : null,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
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
    );
  }
}
