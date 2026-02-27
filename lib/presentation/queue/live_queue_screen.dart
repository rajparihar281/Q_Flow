import 'dart:async';
import 'package:flutter/material.dart';
import 'package:q_flow/core/constants/app_constants.dart';
import 'package:q_flow/core/theme/app_theme.dart';
import 'package:q_flow/core/widgets/gradient_scaffold.dart';
import 'package:q_flow/core/widgets/app_card.dart';

class LiveQueueScreen extends StatefulWidget {
  final int? initialToken;
  final String severity;

  const LiveQueueScreen({
    super.key,
    this.initialToken,
    this.severity = 'Medium',
  });

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _fadeCtrl;
  late Timer _refreshTimer;

  // [FUTURE BACKEND] These values would come from a WebSocket / polling endpoint:
  //   GET /api/v1/queue/status?patientId=xxx
  //   or  WS  wss://api/queue/live
  final int _myToken = 47;
  late int _currentServing;

  @override
  void initState() {
    super.initState();
    _currentServing = 44;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.94,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Simulate real-time queue updates via Timer
    _refreshTimer = Timer.periodic(AppDurations.queueRefresh, (_) {
      if (!mounted) return;
      setState(() {
        if (_currentServing < _myToken - 1) _currentServing++;
      });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _refreshTimer.cancel();
    super.dispose();
  }

  int get _ahead => (_myToken - _currentServing).clamp(0, _myToken);
  int get _waitMins => _ahead * 7;

  Color get _sevColor {
    switch (widget.severity) {
      case 'High':
        return AppColors.danger;
      case 'Low':
        return AppColors.secondary;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: FadeTransition(
        opacity: _fadeCtrl,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    _buildTokenBadge(),
                    const SizedBox(height: AppSpacing.md),
                    _buildStatsCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildProgressBar(),
                    const SizedBox(height: AppSpacing.md),
                    _buildStatusCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildAiCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildPrivacyNote(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            'Queue Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (widget.severity == 'High')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.priority_high, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Priority',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTokenBadge() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.25),
              blurRadius: 28,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'YOUR TOKEN',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            Text(
              '$_myToken',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return AppCard(
      child: Column(
        children: [
          _statRow(
            Icons.play_circle_outline_rounded,
            'Currently Serving',
            '$_currentServing',
            AppColors.secondary,
          ),
          const Divider(height: 20),
          _statRow(
            Icons.people_outline_rounded,
            'People Ahead',
            '$_ahead',
            AppColors.warning,
          ),
          const Divider(height: 20),
          _statRow(
            Icons.timer_outlined,
            'Estimated Wait',
            '$_waitMins min',
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: LinearProgressIndicator(
            value: _currentServing / _myToken,
            minHeight: 10,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            Text(
              'Your Token',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final isHigh = widget.severity == 'High';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _sevColor.withOpacity(0.15),
        border: Border.all(color: _sevColor.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(
            isHigh ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: _sevColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isHigh
                  ? 'You have been prioritized due to high severity.'
                  : 'Your queue position is confirmed. Please stay nearby.',
              style: TextStyle(
                color: _sevColor.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_outlined, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(
                'AI Wait Estimate',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Based on $_ahead people × 7 min avg consultation, estimated wait is $_waitMins minutes. Updates every ~8 seconds.',
            style: AppTextStyles.bodyMedium,
          ),
          // [FUTURE BACKEND] Replace with real ML-based wait time from:
          //   GET /api/v1/queue/estimate?token=$_myToken
        ],
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Colors.white54, size: 14),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Queue data is anonymized. Your identity is not shared with other patients.',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
