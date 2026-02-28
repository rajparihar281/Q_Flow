import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/app_card.dart';
import 'package:q_flow/core/widgets/state_widgets.dart';
import 'package:q_flow/data/models/hospital_model.dart';
import 'package:q_flow/data/repositories/appointment_repository.dart';
import 'package:q_flow/presentation/booking/booking_confirmation_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final HospitalDoctorModel doctor;
  final HospitalModel hospital;
  final AppointmentRepository repo;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
    required this.hospital,
    required this.repo,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _symptomsCtrl = TextEditingController();
  String _severity = 'Medium';
  String _gender = 'Male';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  bool _confirming = false;
  bool _consented = false;

  final _times = ['09:00 AM', '10:00 AM', '11:30 AM', '02:00 PM', '04:00 PM'];
  final _severities = ['Low', 'Medium', 'High'];
  final _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_consented) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide consent before booking.')),
      );
      return;
    }
    setState(() => _confirming = true);
    final appointment = await widget.repo.bookAppointment(
      doctorName: widget.doctor.name,
      doctorId: widget.doctor.id,
      specialization: widget.doctor.specialization,
      dateTime: _selectedDate,
      reason: _symptomsCtrl.text.trim().isEmpty
          ? 'Not specified'
          : _symptomsCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _confirming = false);
    Navigator.pushReplacement(
      context,
      slideRoute(BookingConfirmationScreen(appointment: appointment)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorBanner(),
                  const SizedBox(height: AppSpacing.md),
                  _buildSection('Select Date', _buildDatePicker()),
                  _buildSection('Select Time', _buildTimeChips()),
                  _buildSection('Symptoms / Reason', _buildSymptomsField()),
                  _buildSection('Gender', _buildGenderSelector()),
                  _buildSection('Severity', _buildSeveritySelector()),
                  _buildConsentCheckbox(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildConfirmButton(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.disclaimer,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      title: const Text('Book Appointment'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDoctorBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.xl,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Text(
              widget.doctor.initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.doctor.specialization,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  widget.hospital.name,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          AvailabilityTag(
            available: widget.doctor.availableToday,
            label: widget.doctor.availability,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelBold),
          const SizedBox(height: AppSpacing.sm),
          content,
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppUtils.formatDate(_selectedDate),
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _times.map((t) {
        final sel = t == _selectedTime;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = t),
          child: AnimatedContainer(
            duration: AppDurations.normal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.inputFill,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: sel ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Text(
              t,
              style: TextStyle(
                color: sel ? Colors.white : AppColors.textSecondary,
                fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomsField() {
    return TextFormField(
      controller: _symptomsCtrl,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Briefly describe your symptoms or reason for visit...',
        hintStyle: AppTextStyles.bodyMedium,
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: _genders.map((g) {
        final sel = g == _gender;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: AnimatedContainer(
              duration: AppDurations.normal,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.inputFill,
                border: Border.all(
                  color: sel ? AppColors.primary : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  g,
                  style: TextStyle(
                    color: sel ? Colors.white : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeveritySelector() {
    return Row(
      children: _severities.map((s) {
        final sel = s == _severity;
        final color = AppUtils.severityColor(s);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _severity = s),
            child: AnimatedContainer(
              duration: AppDurations.normal,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: sel ? color.withOpacity(0.12) : AppColors.inputFill,
                border: Border.all(
                  color: sel ? color : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  s,
                  style: TextStyle(
                    color: sel ? color : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConsentCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _consented,
          onChanged: (v) => setState(() => _consented = v ?? false),
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: Text(
            'I consent to share my health information with the doctor and hospital for this appointment.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _confirming ? null : _confirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 4,
        ),
        child: _confirming
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Confirm Appointment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
