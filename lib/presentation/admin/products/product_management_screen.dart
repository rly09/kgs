import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../providers.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';

// Provider for products with refresh capability
final adminProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final productService = ref.watch(productServiceProvider);
  return await productService.getProducts();
});

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
      ),
      floatingActionButton: categoriesAsync.when(
        data: (categories) => FloatingActionButton(
          onPressed: () {
            _showProductDialog(context, ref, categories);
          },
          child: const Icon(Icons.add),
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
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
                    'No products yet',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  Text(
                    'Tap + to add a product',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ResponsiveHelper.constrainedContent(
            context,
            child: ListView.builder(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.space),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stock: ${product.stock}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: product.stock > 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      categoriesAsync.when(
                        data: (categories) => IconButton(
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: () {
                            _showProductDialog(context, ref, categories, product: product);
                          },
                          color: AppColors.info,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: () {
                          _showDeleteDialog(context, ref, product);
                        },
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              );
            },
            ));
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
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(adminProductsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryModel> categories, {
    ProductModel? product,
  }) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );
    int? selectedCategoryId = product?.categoryId ?? categories.firstOrNull?.id;
    final formKey = GlobalKey<FormState>();
    XFile? selectedImage;
    String? uploadedImagePath = product?.imagePath;
    bool isUploadingImage = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius),
          ),
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      hintText: 'e.g., Rice (1kg)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Stock is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid stock quantity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.space),
                  // Image preview
                  if (selectedImage != null || uploadedImagePath != null)
                    Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: selectedImage != null
                          ? FutureBuilder<Uint8List>(
                              future: selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            )
                          : uploadedImagePath != null
                              ? Image.network(
                                  uploadedImagePath!, // Already full Supabase URL
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image_not_supported, size: 48),
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                  OutlinedButton.icon(
                    onPressed: isUploadingImage
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              setState(() {
                                selectedImage = pickedFile;
                              });
                            }
                          },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      selectedImage != null || uploadedImagePath != null
                          ? 'Change Image'
                          : 'Add Image (Optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploadingImage
                  ? null
                  : () async {
                      if (formKey.currentState!.validate() && selectedCategoryId != null) {
                        setState(() => isUploadingImage = true);
                        
                        try {
                          final productService = ref.read(productServiceProvider);
                          
                          // Upload image if selected
                          if (selectedImage != null) {
                            final bytes = await selectedImage!.readAsBytes();
                            // Use XFile.name for better cross-platform support
                            final filename = selectedImage!.name;
                            print('Selected image filename: $filename'); // Debug
                            uploadedImagePath = await productService.uploadProductImage(
                              bytes.toList(),
                              filename,
                            );
                          }
                          
                          if (product == null) {
                            // Add new product
                            await productService.createProduct(
                              ProductCreate(
                                categoryId: selectedCategoryId!,
                                name: nameController.text.trim(),
                                price: double.parse(priceController.text),
                                stock: int.parse(stockController.text),
                                isAvailable: true,
                                imagePath: uploadedImagePath,
                              ),
                            );
                          } else {
                            // Update existing product
                            await productService.updateProduct(
                              product.id,
                              ProductUpdate(
                                name: nameController.text.trim(),
                                price: double.parse(priceController.text),
                                stock: int.parse(stockController.text),
                                imagePath: uploadedImagePath,
                              ),
                            );
                          }
                          
                          // Refresh the products list
                          ref.refresh(adminProductsProvider);
                          
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(product == null
                                    ? 'Product added successfully'
                                    : 'Product updated successfully'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        } finally {
                          if (dialogContext.mounted) {
                            setState(() => isUploadingImage = false);
                          }
                        }
                      }
                    },
              child: isUploadingImage
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(product == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ProductModel product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius),
        ),
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final productService = ref.read(productServiceProvider);
                await productService.deleteProduct(product.id);
                
                // Refresh the products list
                ref.refresh(adminProductsProvider);
                
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
