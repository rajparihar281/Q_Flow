import 'package:flutter/material.dart';
import 'package:q_flow/core/theme/app_theme.dart';

class AppUtils {
  AppUtils._();

  static String formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatTime(DateTime date) {
    final h = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;
    final min = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$h:$min $period';
  }

  static String generateBookingId() {
    final now = DateTime.now();
    return 'QF-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(1000 + now.millisecondsSinceEpoch % 9000)}';
  }

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.danger;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  static IconData availabilityIcon(bool available) =>
      available ? Icons.check_circle_outline : Icons.schedule_outlined;

  static Color availabilityColor(bool available) =>
      available ? AppColors.secondary : AppColors.warning;
}

/// Slide page route used throughout the app.
PageRoute slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, anim, __) => page,
    transitionsBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// Fade page route used for auth transitions.
PageRoute fadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, anim, __) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );
}
