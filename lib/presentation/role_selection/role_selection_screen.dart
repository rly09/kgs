import 'package:flutter/material.dart';
import '../admin/auth/admin_login_screen.dart';
import '../customer/auth/customer_login_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animationVerySlow),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsivePadding(
                            context,
                          ),
                          vertical: isMobile
                              ? AppDimensions.padding
                              : AppDimensions.paddingLarge,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo and Title - More compact
                            Hero(
                              tag: 'app_logo',
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: isMobile ? 90 : 120,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMedium,
                                  ),
                                  child: Image.asset("assets/app_icon.png"),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: isMobile
                                  ? AppDimensions.space
                                  : AppDimensions.spaceLarge,
                            ),

                            // Main Title
                            Text(
                              'KGS Shop',
                              style: AppTextStyles.heading2.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppDimensions.spaceSmall),

                            Text(
                              'at your doorstep',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: isMobile
                                  ? AppDimensions.spaceLarge
                                  : AppDimensions.spaceXLarge,
                            ),

                            // Role Cards - Compact layout
                            if (isDesktop)
                              Row(
                                children: [
                                  Expanded(
                                    child: _RoleCard(
                                      icon: Icons.shopping_bag_rounded,
                                      title: 'Shop',
                                      subtitle: 'Browse & Purchase',
                                      color: AppColors.accent,
                                      gradient: AppColors.accentGradient,
                                      isCompact: false,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CustomerLoginScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _RoleCard(
                                    icon: Icons.shopping_bag_rounded,
                                    title: 'Customer',
                                    subtitle: 'Browse & Purchase',
                                    color: AppColors.accent,
                                    gradient: AppColors.accentGradient,
                                    isCompact: isMobile,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CustomerLoginScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Admin Button - Top Right
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(
                  isMobile ? AppDimensions.padding : AppDimensions.paddingLarge,
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AdminLoginScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile
                                  ? AppDimensions.paddingMedium
                                  : AppDimensions.paddingLarge,
                              vertical: isMobile
                                  ? AppDimensions.paddingSmall
                                  : AppDimensions.padding,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: Colors.white,
                                  size: isMobile ? 20 : 24,
                                ),
                                SizedBox(width: AppDimensions.spaceSmall),
                                Text(
                                  'Admin',
                                  style:
                                      (isMobile
                                              ? AppTextStyles.bodyMedium
                                              : AppTextStyles.heading4)
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isCompact;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppDimensions.animationFast),
    );
    _elevationAnimation = Tween<double>(
      begin: AppDimensions.elevationSmall,
      end: AppDimensions.elevationMedium,
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Material(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            elevation: _elevationAnimation.value,
            shadowColor: widget.color.withOpacity(0.3),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Container(
                padding: EdgeInsets.all(
                  widget.isCompact
                      ? AppDimensions.padding
                      : AppDimensions.paddingLarge,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                  border: Border.all(
                    color: _isHovered
                        ? widget.color.withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        widget.isCompact
                            ? AppDimensions.paddingSmall
                            : AppDimensions.paddingLarge,
                      ),
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: widget.isCompact
                            ? AppDimensions.iconLarge
                            : AppDimensions.iconXLarge,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: widget.isCompact
                          ? AppDimensions.paddingSmall
                          : AppDimensions.space,
                    ),
                    Text(
                      widget.title,
                      style:
                          (widget.isCompact
                                  ? AppTextStyles.heading4
                                  : AppTextStyles.heading3)
                              .copyWith(
                                color: widget.color,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: widget.isCompact ? 4 : AppDimensions.spaceSmall,
                    ),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: widget.isCompact
                          ? AppDimensions.paddingSmall
                          : AppDimensions.space,
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.color,
                      size: widget.isCompact
                          ? AppDimensions.iconSmall
                          : AppDimensions.iconSizeMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
