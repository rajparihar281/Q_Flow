import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/state_widgets.dart';
import 'package:q_flow/data/models/appointment_model.dart';
import 'package:q_flow/data/repositories/appointment_repository.dart';

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _repo = AppointmentRepository();
  late AnimationController _ctrl;
  List<AppointmentModel>? _appointments;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getAppointmentHistory();
      if (!mounted) return;
      setState(() {
        _appointments = data;
        _loading = false;
      });
      _ctrl.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppStrings.errorGeneric;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          const Text(
            'Appointment History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingWidget(message: 'Loading history...');
    }
    if (_error != null) {
      return ErrorStateWidget(message: _error!, onRetry: _load);
    }
    if (_appointments == null || _appointments!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history_rounded,
        title: AppStrings.emptyAppointments,
        subtitle: 'Your past appointments will appear here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      itemCount: _appointments!.length,
      itemBuilder: (ctx, i) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _ctrl,
                curve: Interval(
                  (i * 0.10).clamp(0, 0.6),
                  ((i * 0.10) + 0.5).clamp(0.0, 1.0),
                  curve: Curves.easeOut,
                ),
              ),
            );
        return SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: _ctrl,
            child: _AppointmentCard(appointment: _appointments![i]),
          ),
        );
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentCard({required this.appointment});

  Color get _statusColor {
    switch (appointment.status.toLowerCase()) {
      case 'completed':
        return AppColors.secondary;
      case 'cancelled':
        return AppColors.danger;
      case 'scheduled':
      case 'confirmed':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final apt = appointment;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  apt.doctorName ?? 'Doctor',
                  style: AppTextStyles.headlineSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  apt.label,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            apt.specialization ?? '',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          Text(apt.hospitalName ?? '', style: AppTextStyles.bodySmall),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${AppUtils.formatDate(apt.dateTime)}  •  ${AppUtils.formatTime(apt.dateTime)}',
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              if (apt.tokenNumber != null)
                Text(
                  'Token #${apt.tokenNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              'Symptoms: ${apt.symptoms}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${apt.id.length > 8 ? apt.id.substring(0, 8) : apt.id}',
                style: AppTextStyles.bodySmall,
              ),
              if (apt.estimatedWaitMinutes > 0)
                Text(
                  '~${apt.estimatedWaitMinutes} min wait',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
