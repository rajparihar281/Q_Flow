import 'package:flutter/material.dart';
import 'package:q_flow/core/theme/app_theme.dart';

class GradientScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool safeArea;

  const GradientScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: safeArea ? SafeArea(child: child) : child,
      ),
    );
  }
}
