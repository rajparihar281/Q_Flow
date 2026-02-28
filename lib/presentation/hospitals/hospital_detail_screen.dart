import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/state_widgets.dart';
import 'package:q_flow/data/models/hospital_model.dart';
import 'package:q_flow/data/repositories/appointment_repository.dart';
import 'package:q_flow/presentation/booking/book_appointment_screen.dart';

class HospitalDetailScreen extends StatefulWidget {
  final HospitalModel hospital;
  const HospitalDetailScreen({super.key, required this.hospital});

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _repo = AppointmentRepository();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.hospital;
    return GradientScaffold(
      child: Column(
        children: [
          _buildHeader(h),
          _buildInfoBanner(h),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Doctors at ${h.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: h.doctors.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.person_search_rounded,
                    title: AppStrings.emptyDoctors,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    itemCount: h.doctors.length,
                    itemBuilder: (ctx, i) {
                      final slide =
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _ctrl,
                              curve: Interval(
                                i * 0.2,
                                (i * 0.2 + 0.55).clamp(0, 1),
                                curve: Curves.easeOut,
                              ),
                            ),
                          );
                      return SlideTransition(
                        position: slide,
                        child: _DoctorCard(
                          doctor: h.doctors[i],
                          onBook: () => Navigator.push(
                            context,
                            slideRoute(
                              BookAppointmentScreen(
                                doctor: h.doctors[i],
                                hospital: h,
                                repo: _repo,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(HospitalModel h) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
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
          Expanded(
            child: Text(
              h.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(HospitalModel h) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 15,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  h.address,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: Colors.white70, size: 15),
              const SizedBox(width: 4),
              Text(
                h.phone,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                h.rating.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final HospitalDoctorModel doctor;
  final VoidCallback onBook;

  const _DoctorCard({required this.doctor, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                child: Text(
                  doctor.initial,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: AppTextStyles.headlineSmall),
                    Text(
                      doctor.specialization,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AvailabilityTag(
                available: doctor.availableToday,
                label: doctor.availability,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.work_outline,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                doctor.experience,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                doctor.rating.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
