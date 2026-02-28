import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/app_card.dart';
import 'package:q_flow/data/models/patient_model.dart';
import 'package:q_flow/data/repositories/patient_repository.dart';
import 'package:q_flow/presentation/auth/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _repo = PatientRepository();
  late AnimationController _btnCtrl;
  late Animation<double> _scaleAnim;

  List<PatientModel>? _patients;
  String? _selectedPatientId;
  final TextEditingController _abhaCtrl = TextEditingController();
  bool _loadingPatients = true;
  bool _loadingLogin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _repo.getAllPatients();
      if (!mounted) return;

      // Filter out any duplicates by ID to guarantee unique dropdown values
      final uniquePatients = <String, PatientModel>{};
      for (var p in patients) {
        uniquePatients[p.id] = p;
      }

      setState(() {
        _patients = uniquePatients.values.toList();
        if (_patients!.isNotEmpty) {
          _selectedPatientId = 'ABHA00001'; // Pre-filled for demo
          _abhaCtrl.text = _selectedPatientId!;
        }
        _loadingPatients = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load demo patients: $e';
        _loadingPatients = false;
      });
    }
  }

  @override
  void dispose() {
    _abhaCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_selectedPatientId == null || _patients == null) return;

    if (_abhaCtrl.text.isEmpty) return;

    final inputAbha = _abhaCtrl.text.trim();

    setState(() => _loadingLogin = true);
    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    // Use entered ABHA ID
    await _repo.sendOtp(inputAbha);

    if (!mounted) return;
    setState(() => _loadingLogin = false);

    // Pass the entered abhaId so the OTP screen knows who to verify
    Navigator.of(context).push(slideRoute(OtpScreen(abhaId: inputAbha)));
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                size: 72,
                color: Colors.white,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(AppStrings.appName, style: AppTextStyles.displayLarge),
              const Text(
                AppStrings.appTagline,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your ABHA ID to login',
                      style: AppTextStyles.labelBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_loadingPatients)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.danger),
                      )
                    else if (_patients == null || _patients!.isEmpty)
                      const Text(
                        'Server Issue.',
                        style: TextStyle(color: AppColors.danger),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        child: TextField(
                          controller: _abhaCtrl,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter ABHA ID',
                            hintStyle: TextStyle(color: Colors.white54),
                            icon: Icon(
                              Icons.badge_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_loadingLogin || _abhaCtrl.text.isEmpty)
                              ? null
                              : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            elevation: 0,
                          ),
                          child: _loadingLogin
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  AppStrings.privacyNote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                AppStrings.poweredBy,
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
