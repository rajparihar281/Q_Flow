import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/utils/app_utils.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/app_card.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/data/repositories/patient_repository.dart';
import 'package:q_flow/presentation/home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String abhaId;
  const OtpScreen({super.key, required this.abhaId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _repo = PatientRepository();
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;
  bool _verifying = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _autoFill();
  }

  void _autoFill() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final digits = ['4', '2', '7', '8', '9', '1'];
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 110));
      if (!mounted) return;
      setState(() => _otpCtrls[i].text = digits[i]);
    }
  }

  Future<void> _verify() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    setState(() => _verifying = true);
    await _repo.verifyOtp(widget.abhaId, otp);
    if (!mounted) return;
    setState(() {
      _verifying = false;
      _success = true;
    });
    _checkCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushAndRemoveUntil(fadeRoute(const HomeScreen()), (r) => false);
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.phone_android,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'OTP sent to registered mobile number',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_success)
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: 40,
                        child: TextField(
                          controller: _otpCtrls[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (v) {
                            if (v.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Auto-filled OTP: 427891',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!_success)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withOpacity(
                          0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.consentNotice,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
