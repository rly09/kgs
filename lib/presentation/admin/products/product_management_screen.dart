import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../providers.dart';
import '../../../data/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

import '../../customer/home/customer_home_screen.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          categoriesAsync.whenData((categories) {
            if (categories.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please add categories first'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              _showProductDialog(context, ref, categories);
            }
          });
        },
        backgroundColor: AppColors.primary,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppDimensions.space),
                  Text(
                    'No products found',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSmall),
                  Text(
                    'Tap + to add your first product',
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
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space),
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.padding),
                  child: Row(
                    children: [
                      // Image Placeholder or Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          image: product.imagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(product.imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: product.imagePath == null
                            ? Icon(Icons.shopping_bag_outlined, color: AppColors.textTertiary)
                            : null,
                      ),
                      const SizedBox(width: AppDimensions.space),
                      
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(product.price),
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status & Actions
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                            child: Text(
                              product.isAvailable ? 'Stock: ${product.stock}' : 'Unavailable',
                              style: AppTextStyles.caption.copyWith(
                                color: product.isAvailable ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  categoriesAsync.whenData((categories) {
                                    _showProductDialog(context, ref, categories, product: product);
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.edit_rounded, size: 20, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _showDeleteDialog(context, ref, product),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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

  void _showProductDialog(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories, {
    Product? product,
  }) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '0');
    int selectedCategoryId = product?.categoryId ?? categories.first.id;
    bool isAvailable = product?.isAvailable ?? true;
    final formKey = GlobalKey<FormState>();
    File? selectedImage;
    final imagePicker = ImagePicker();

    Future<void> pickImage() async {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage = File(image.path);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
          backgroundColor: AppColors.cardBackground,
          title: Text(product == null ? 'Add Product' : 'Edit Product', style: AppTextStyles.heading3),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   GestureDetector(
                    onTap: () async {
                      await pickImage();
                      setState(() {});
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              child: Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                          : product?.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                  child: Image.file(File(product!.imagePath!), fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textTertiary),
                                    const SizedBox(height: 8),
                                    Text('Add Image', style: AppTextStyles.caption),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: categories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                    onChanged: (value) => setState(() => selectedCategoryId = value!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: Validators.validatePrice,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: Validators.validateStock,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Available'),
                    value: isAvailable,
                    onChanged: (v) => setState(() => isAvailable = v),
                    activeColor: AppColors.success,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final database = ref.read(databaseProvider);
                  final now = DateTime.now();

                  if (product == null) {
                    await database.into(database.products).insert(
                      ProductsCompanion.insert(
                        categoryId: selectedCategoryId,
                        name: nameController.text.trim(),
                        price: double.parse(priceController.text),
                        stock: drift.Value(int.parse(stockController.text)),
                        isAvailable: drift.Value(isAvailable),
                        imagePath: drift.Value(selectedImage?.path),
                        createdAt: now,
                        updatedAt: now,
                      ),
                    );
                  } else {
                    await (database.update(database.products)..where((tbl) => tbl.id.equals(product.id))).write(
                      ProductsCompanion(
                        categoryId: drift.Value(selectedCategoryId),
                        name: drift.Value(nameController.text.trim()),
                        price: drift.Value(double.parse(priceController.text)),
                        stock: drift.Value(int.parse(stockController.text)),
                        isAvailable: drift.Value(isAvailable),
                        imagePath: drift.Value(selectedImage?.path ?? product.imagePath),
                        updatedAt: drift.Value(now),
                      ),
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(product == null ? 'Added' : 'Updated'), backgroundColor: AppColors.success),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(product == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final database = ref.read(databaseProvider);
              await database.delete(database.products).delete(product);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleted'), backgroundColor: AppColors.success),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
