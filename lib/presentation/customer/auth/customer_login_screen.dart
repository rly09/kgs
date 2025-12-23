import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../providers.dart';
import '../customer_main_screen.dart';

class CustomerLoginScreen extends ConsumerStatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  ConsumerState<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends ConsumerState<CustomerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginWithPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref
        .read(customerAuthProvider.notifier)
        .loginWithPhone(_phoneController.text, _nameController.text);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CustomerMainScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spaceXXLarge),
                
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 80,
                    color: AppColors.accent,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.spaceXLarge),
                
                Text(
                  'Welcome to KGS',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppDimensions.spaceSmall),
                
                Text(
                  'Start shopping with us',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppDimensions.spaceXXLarge),
                
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: Validators.validateName,
                ),
                
                const SizedBox(height: AppDimensions.space),
                
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    prefixIcon: Icon(Icons.phone_rounded),
                    counterText: '',
                  ),
                  validator: Validators.validatePhone,
                ),
                
                const SizedBox(height: AppDimensions.spaceXLarge),
                
                // Login Button
                SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLoginWithPhone,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
