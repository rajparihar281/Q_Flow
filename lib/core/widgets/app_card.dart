import 'package:flutter/material.dart';
import 'package:q_flow/core/theme/app_theme.dart';

/// White rounded card used throughout the app.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? shadow;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.shadow,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: child,
    );
  }
}

/// Semi-transparent overlay card for use on gradient backgrounds.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: child,
    );
  }
}
