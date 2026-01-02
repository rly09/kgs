import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../providers.dart';
import '../../../data/models/order_model.dart';
import '../widgets/location_picker_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _paymentMode = 'COD';
  File? _paymentProof;
  bool _isPlacingOrder = false;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Pre-fill customer details if logged in
    final customer = ref.read(customerAuthProvider);
    if (customer != null) {
      _nameController.text = customer.name ?? '';
      _phoneController.text = customer.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location services'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Please enable in settings.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location captured: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickPaymentProof() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _paymentProof = File(image.path);
      });
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_paymentMode == 'ONLINE' && _paymentProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload payment proof'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final cart = ref.read(cartProvider);
      final customer = ref.read(customerAuthProvider);
      final orderService = ref.read(orderServiceProvider);
      
      // Get current discount
      final discountPercentage = await ref.read(discountProvider.future);
      final subtotal = cart.totalAmount;
      final discountAmount = subtotal * (discountPercentage / 100);
      final finalTotal = subtotal - discountAmount;

      // Create order via API
      final orderCreate = OrderCreate(
        customerId: customer!.id,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        deliveryAddress: _addressController.text,
        deliveryLatitude: _selectedLocation?.latitude,
        deliveryLongitude: _selectedLocation?.longitude,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        paymentMode: _paymentMode,
        totalAmount: finalTotal,
        items: cart.items.values.map((item) => OrderItemModel(
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          priceAtOrder: item.price,
        )).toList(),
      );

      final order = await orderService.createOrder(orderCreate);

      // Clear cart
      cart.clear();

      setState(() => _isPlacingOrder = false);

      if (mounted) {
        // Show success dialog - Minimal
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            contentPadding: const EdgeInsets.all(AppDimensions.paddingLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: AppDimensions.space),
                Text(
                  'Order Placed!',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Order #${order.id}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.space),
                Text(
                  'We have received your order and will process it soon.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceLarge),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.of(dialogContext).pop();
                      // Navigate back to the main screen (CustomerMainScreen)
                      // This will pop all routes until we reach the main screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final discountAsync = ref.watch(discountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
        child: ResponsiveHelper.constrainedContent(
          context,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Details
                Text('Delivery Details', style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.space),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                validator: Validators.validateName,
              ),
              const SizedBox(height: AppDimensions.space),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: AppDimensions.space),
              _buildTextField(
                controller: _addressController,
                label: 'Delivery Address',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: Validators.validateAddress,
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              
              // Location Buttons Row
              Row(
                children: [
                  // GPS Auto-Capture Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location, size: 20),
                      label: const Text('Use GPS'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  // Map Picker Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final location = await Navigator.push<LatLng>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationPickerScreen(
                              initialLocation: _selectedLocation,
                            ),
                          ),
                        );
                        
                        if (location != null) {
                          setState(() {
                            _selectedLocation = location;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Location selected: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.map_outlined, size: 20),
                      label: const Text('Pick on Map'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Location Status
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.spaceSmall),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Location set: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: AppDimensions.space),
              _buildTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                icon: Icons.note_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // Payment Mode
              Text('Payment Method', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.space),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildPaymentOption(
                      title: 'Cash on Delivery',
                      subtitle: 'Pay when you receive',
                      value: 'COD',
                      icon: Icons.money_rounded,
                    ),
                    const Divider(height: 1),
                    _buildPaymentOption(
                      title: 'Online Payment',
                      subtitle: 'Upload payment proof',
                      value: 'ONLINE',
                      icon: Icons.payment_rounded,
                    ),
                  ],
                ),
              ),


              if (_paymentMode == 'ONLINE') ...[ 
                const SizedBox(height: AppDimensions.space),
                
                // Payment QR Code Display
                FutureBuilder<String?>(
                  future: ref.read(settingsServiceProvider).getPaymentQrUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return Container(
                        padding: const EdgeInsets.all(AppDimensions.padding),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Payment QR code not available. Please contact the shop or choose Cash on Delivery.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Display QR Code
                    return Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.qr_code_2, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Scan to Pay',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.space),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            child: Image.network(
                              snapshot.data!,
                              height: 250,
                              width: 250,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 250,
                                  width: 250,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 250,
                                  width: 250,
                                  color: AppColors.surfaceLight,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load QR code',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.info, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Scan this QR code to make payment, then upload proof below',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppDimensions.space),
                
                // Payment Proof Upload
                InkWell(
                  onTap: _pickPaymentProof,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.padding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: _paymentProof != null ? AppColors.success : AppColors.border,
                        style: _paymentProof != null ? BorderStyle.solid : BorderStyle.none,
                      ),
                    ),
                child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _paymentProof != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                          color: _paymentProof != null ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _paymentProof != null ? 'Payment Proof Uploaded' : 'Upload Payment Proof',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _paymentProof != null ? AppColors.success : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],


              const SizedBox(height: AppDimensions.spaceLarge),

              // Order Summary
              Text('Order Summary', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.space),

              discountAsync.when(
                data: (discountPercentage) {
                  final subtotal = cart.totalAmount;
                  final discountAmount = subtotal * (discountPercentage / 100);
                  final finalTotal = subtotal - discountAmount;

                  return Container(
                    padding: const EdgeInsets.all(AppDimensions.padding),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.values.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName} x${item.quantity}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                              Text(
                                Formatters.formatCurrency(item.total),
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )),
                        const Divider(height: 24),
                        _buildSummaryRow('Subtotal', subtotal),
                        if (discountPercentage > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Discount (${discountPercentage.toStringAsFixed(0)}%)',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                              ),
                              Text(
                                '-${Formatters.formatCurrency(discountAmount)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: AppTextStyles.heading3),
                            Text(
                              Formatters.formatCurrency(finalTotal),
                              style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading summary'),
              ),

              const SizedBox(height: AppDimensions.spaceXLarge),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Place Order'),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXLarge),
            ],
          ),
        ),
      ),
      ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        counterText: '',
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.padding),
      ),
      validator: validator,
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _paymentMode == value;
    return InkWell(
      onTap: () => setState(() => _paymentMode = value),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.space),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary)
            else
              Icon(Icons.circle_outlined, color: AppColors.border),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          Formatters.formatCurrency(amount),
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

