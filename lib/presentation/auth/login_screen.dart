import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/app_card.dart';
import 'package:q_flow/data/repositories/patient_repository.dart';
import 'package:q_flow/presentation/auth/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController(text: 'PMJAY-MH-2024-887654');
  final _repo = PatientRepository();
  late AnimationController _btnCtrl;
  late Animation<double> _scaleAnim;
  bool _loading = false;

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
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await _btnCtrl.forward();
    await _btnCtrl.reverse();
    await _repo.sendOtp(_controller.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).push(slideRoute(const OtpScreen()));
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
                      'ABHA ID',
                      style: AppTextStyles.labelBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.credit_card,
                          color: AppColors.primary,
                        ),
                        hintText: 'Enter your ABHA ID',
                        hintStyle: TextStyle(color: AppColors.textHint),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Send OTP',
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
