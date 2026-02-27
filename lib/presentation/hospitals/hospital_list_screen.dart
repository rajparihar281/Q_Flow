import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/state_widgets.dart';
import 'package:q_flow/data/models/hospital_model.dart';
import 'package:q_flow/data/repositories/hospital_repository.dart';
import 'package:q_flow/presentation/hospitals/hospital_detail_screen.dart';

class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen>
    with SingleTickerProviderStateMixin {
  final _repo = HospitalRepository();
  late AnimationController _ctrl;
  List<HospitalModel>? _hospitals;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getNearbyHospitals();
      if (!mounted) return;
      setState(() {
        _hospitals = data;
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
            'Hospitals Near You',
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
    if (_loading) return const LoadingWidget(message: 'Finding hospitals...');
    if (_error != null) {
      return ErrorStateWidget(message: _error!, onRetry: _load);
    }
    if (_hospitals == null || _hospitals!.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.local_hospital_outlined,
        title: AppStrings.emptyHospitals,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      itemCount: _hospitals!.length,
      itemBuilder: (ctx, i) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _ctrl,
                curve: Interval(
                  (i * 0.08).clamp(0, 0.6),
                  ((i * 0.08) + 0.4).clamp(0, 1),
                  curve: Curves.easeOutCubic,
                ),
              ),
            );
        return SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: _ctrl,
            child: TapScaleWidget(
              onTap: () => Navigator.push(
                context,
                slideRoute(HospitalDetailScreen(hospital: _hospitals![i])),
              ),
              child: _HospitalCard(hospital: _hospitals![i]),
            ),
          ),
        );
      },
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.name, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 3),
                Text(
                  hospital.specialities,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(hospital.distance, style: AppTextStyles.bodySmall),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      hospital.rating.toString(),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ],
      ),
    );
  }
}
