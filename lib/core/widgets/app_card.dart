import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:q_flow/core/theme/app_theme.dart';

/// Glassmorphic rounded card used throughout the app as per design tech aesthetic.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? shadow;
  final double? borderRadius;
  final bool borderGlow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.shadow,
    this.borderRadius,
    this.borderGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassEffect,
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
            border: Border.all(
              color: borderGlow
                  ? AppColors.borderGlow
                  : AppColors.primary.withOpacity(0.1),
              width: borderGlow ? 1.0 : 0.5,
            ),
            boxShadow: shadow != null
                ? [BoxShadow(color: shadow!, blurRadius: 15, spreadRadius: -5)]
                : [],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Semi-transparent overlay card for use on gradient backgrounds.
class GlassCard extends AppCard {
  const GlassCard({
    super.key,
    required super.child,
    super.padding,
    super.borderRadius,
  }) : super(borderGlow: false);
}
