import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';

/// Responsive grid widget that adapts to screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.childAspectRatio = 0.75,
    this.padding,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    final spacing = crossAxisSpacing ?? ResponsiveHelper.getResponsiveSpacing(context);

    return GridView.builder(
      padding: padding ?? EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive wrap widget that adapts spacing to screen size
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double? spacing;
  final double? runSpacing;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.spacing,
    this.runSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? ResponsiveHelper.getResponsiveSpacing(context);

    return Wrap(
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: effectiveSpacing,
      runSpacing: runSpacing ?? effectiveSpacing,
      children: children,
    );
  }
}
