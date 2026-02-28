import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/app_card.dart';
import 'package:q_flow/data/models/patient_model.dart';
import 'package:q_flow/data/repositories/patient_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PatientModel? _patient;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final patient = await PatientRepository().getPatientProfile();
      if (!mounted) return;
      setState(() {
        _patient = patient;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_patient == null)
            const SliverFillRemaining(
              child: Center(child: Text('Failed to load profile.')),
            )
          else
            SliverToBoxAdapter(child: _buildContent(_patient!)),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      title: const Text('My Profile'),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: _patient == null
              ? const SizedBox()
              : _ProfileHero(patient: _patient!),
        ),
      ),
    );
  }

  Widget _buildContent(PatientModel patient) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Identity (Non-Editable)'),
          _buildIdentityCard(patient),
          _sectionHeader('Medical Information'),
          _buildMedicalCard(patient),
          _sectionHeader('Medical Alerts'),
          _buildAlertsCard(patient),
          _sectionHeader('Emergency Contact'),
          _buildEmergencyCard(patient),
          _buildPrivacyNote(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildIdentityCard(PatientModel patient) {
    return AppCard(
      child: Column(
        children: [
          _fieldRow(
            'ABHA / Ayushman ID',
            patient.abhaId,
            Icons.credit_card_rounded,
            locked: true,
          ),
          const Divider(height: 20),
          _fieldRow(
            'Full Name',
            patient.fullName,
            Icons.person_outline_rounded,
            locked: true,
          ),
          const Divider(height: 20),
          _fieldRow(
            'Date of Birth',
            AppUtils.formatDate(
              DateTime.tryParse(patient.dateOfBirth) ?? DateTime.now(),
            ), // Corrected to use AppUtils.formatDate
            Icons.cake_outlined,
            locked: true,
          ),
          const Divider(height: 20),
          _fieldRow(
            'Age',
            '${patient.age} years',
            Icons.hourglass_empty_rounded,
            locked: true,
          ),
          const Divider(height: 20),
          _fieldRow('Gender', patient.gender, Icons.wc_rounded, locked: true),
        ],
      ),
    );
  }

  Widget _buildMedicalCard(PatientModel patient) {
    return AppCard(
      child: Column(
        children: [
          _fieldRow(
            'Blood Group',
            patient.bloodGroup,
            Icons.bloodtype_outlined,
          ),
          const Divider(height: 20),
          _fieldRow('Phone', patient.phone, Icons.phone_outlined),
          const Divider(height: 20),
          _fieldRow('Address', patient.address, Icons.home_outlined),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(PatientModel patient) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (patient.medicalAlerts.isEmpty)
            const Text(
              'No active medical alerts.',
              style: AppTextStyles.bodyMedium,
            )
          else
            ...patient.alertTypes.map(
              (alertType) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.danger,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      alertType,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (patient.allergies.isNotEmpty) ...[
            const Divider(height: 20),
            const Text(
              'Allergies',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: patient.allergies
                  .map(
                    (a) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        a,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(PatientModel patient) {
    return AppCard(
      child: Column(
        children: [
          _fieldRow(
            'Contact',
            patient.emergencyContact,
            Icons.contact_emergency_outlined,
          ),
          const Divider(height: 20),
          _fieldRow(
            'Phone',
            patient.emergencyPhone,
            Icons.phone_in_talk_outlined,
          ),
        ],
      ),
    );
  }

  Widget _fieldRow(
    String label,
    String value,
    IconData icon, {
    bool locked = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
              Text(value, style: AppTextStyles.headlineSmall),
            ],
          ),
        ),
        if (locked)
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textHint,
            size: 16,
          ),
      ],
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.privacyNote,
              style: TextStyle(color: AppColors.primary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final PatientModel patient;
  const _ProfileHero({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white30,
            child: Text(
              patient.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            patient.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${patient.bloodGroup}  •  Age ${patient.age}  •  ${patient.gender}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
