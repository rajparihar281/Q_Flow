import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/data/models/appointment_model.dart';
import 'package:q_flow/presentation/queue/live_queue_screen.dart';
import 'package:q_flow/presentation/home/home_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const BookingConfirmationScreen({super.key, required this.appointment});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apt = widget.appointment;
    return GradientScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF12B886),
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                AppStrings.bookingSuccess,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                AppStrings.bookingSubtitle,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildDetailCard(apt),
              const SizedBox(height: AppSpacing.lg),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(AppointmentModel apt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(
            Icons.confirmation_number_outlined,
            'Booking ID',
            apt.bookingId,
            AppColors.primary,
          ),
          const Divider(height: 20),
          _row(
            Icons.format_list_numbered_rounded,
            'Token Number',
            '#${apt.tokenNumber}',
            AppColors.accent,
          ),
          const Divider(height: 20),
          _row(
            Icons.person_outline_rounded,
            'Doctor',
            apt.doctorName ?? '',
            AppColors.secondary,
          ),
          const Divider(height: 20),
          _row(
            Icons.local_hospital_outlined,
            'Hospital',
            apt.hospitalName ?? '',
            AppColors.primary,
          ),
          const Divider(height: 20),
          _row(
            Icons.calendar_month_outlined,
            'Date & Time',
            '${AppUtils.formatDate(apt.dateTime)}  •  ${AppUtils.formatTime(apt.dateTime)}',
            AppColors.warning,
          ),
          const Divider(height: 20),
          _row(
            Icons.warning_amber_outlined,
            'Severity',
            apt.severity,
            AppUtils.severityColor(apt.severity),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(value, style: AppTextStyles.headlineSmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              slideRoute(const LiveQueueScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            icon: const Icon(Icons.queue_rounded),
            label: const Text(
              'View Queue Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            fadeRoute(const HomeScreen()),
            (r) => false,
          ),
          child: const Text(
            'Back to Home',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
