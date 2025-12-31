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

class _ProductCard extends ConsumerStatefulWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animationFast),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final isInCart = cart.items.containsKey(widget.product.id);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    // Responsive sizing
    final iconSize = isDesktop ? 20.0 : (isMobile ? 18.0 : 19.0);
    final buttonHeight = isDesktop ? 32.0 : (isMobile ? 30.0 : 31.0);
    final textFontSize = isDesktop ? 12.0 : (isMobile ? 11.0 : 11.5);
    final nameFontSize = isDesktop ? 14.0 : (isMobile ? 13.0 : 13.5);
    final priceFontSize = isDesktop ? 15.0 : (isMobile ? 14.0 : 14.5);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? AppDimensions.elevationMedium : AppDimensions.elevationSmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with gradient overlay and floating add button
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: AppColors.surfaceLight,
                    child: widget.product.imagePath != null
                        ? Image.network(
                            widget.product.imagePath!, // Already full Supabase URL
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Stock badge
                  if (widget.product.stock <= 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                          vertical: AppDimensions.paddingXSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Floating Add to Cart Button
                  if (widget.product.stock > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (isInCart) {
                              cart.removeItem(widget.product.id);
                            } else {
                              final success = cart.addItem(
                                widget.product.id,
                                widget.product.name,
                                widget.product.price,
                                widget.product.stock,
                              );
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Stock limit reached for ${widget.product.name}'),
                                    backgroundColor: AppColors.error,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isInCart ? AppColors.error : Colors.green,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isInCart ? AppColors.error : Colors.green).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isInCart ? Icons.remove : Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Product Details
                  // Product info
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.formatCurrency(widget.product.price),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            // Stock display
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: widget.product.stock > 0
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                              child: Builder(
                                builder: (context) {
                                  // Calculate remaining stock (total - in cart)
                                  final inCartQty = cart.items[widget.product.id]?.quantity ?? 0;
                                  final remainingStock = widget.product.stock - inCartQty;
                                  
                                  return Text(
                                    remainingStock > 0
                                        ? 'Stock: $remainingStock'
                                        : 'Out of Stock',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: remainingStock > 0
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
