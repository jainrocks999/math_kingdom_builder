import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/child_profile_service.dart';
import '../../core/services/parent_pin_service.dart';
import '../../core/services/reward_progress_service.dart';

enum _MasteryLevel { exploring, practicing, confident }

class _ActivityReport {
  const _ActivityReport({
    required this.title,
    required this.emoji,
    required this.completions,
    required this.starsEarned,
  });

  final String title;
  final String emoji;
  final int completions;
  final int starsEarned;

  _MasteryLevel get mastery {
    if (completions >= 8) return _MasteryLevel.confident;
    if (completions >= 3) return _MasteryLevel.practicing;
    return _MasteryLevel.exploring;
  }

  String get masteryLabel {
    switch (mastery) {
      case _MasteryLevel.exploring:
        return 'Exploring';
      case _MasteryLevel.practicing:
        return 'Practicing';
      case _MasteryLevel.confident:
        return 'Confident';
    }
  }

  Color get masteryColor {
    switch (mastery) {
      case _MasteryLevel.exploring:
        return AppColors.info;
      case _MasteryLevel.practicing:
        return AppColors.warning;
      case _MasteryLevel.confident:
        return AppColors.success;
    }
  }
}

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isUnlocked = false;
  bool _needsSetup = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  int _cooldownSeconds = 0;

  RewardProgressSnapshot? _progress;
  ChildProfileSnapshot? _profiles;

  static const _reports = [
    (RewardModuleIds.learnNumbers, 'Learn Numbers', '🔢'),
    (RewardModuleIds.traceNumbers, 'Trace Numbers', '✏️'),
    (RewardModuleIds.countObjects, 'Count Objects', '🍎'),
    (RewardModuleIds.findNumber, 'Find Number', '🎯'),
    (RewardModuleIds.matchNumbers, 'Match Numbers', '🃏'),
    (RewardModuleIds.miniQuiz, 'Mini Quiz', '🧠'),
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final node in _pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final hasPin = await ParentPinService.instance.hasPin();
    if (!mounted) return;
    setState(() {
      _needsSetup = !hasPin;
      _isLoading = false;
    });
    await _refreshCooldown();
  }

  Future<void> _refreshCooldown() async {
    final inCooldown = await ParentPinService.instance.isInCooldown();
    final seconds = inCooldown
        ? await ParentPinService.instance.cooldownSecondsRemaining()
        : 0;
    if (!mounted) return;
    setState(() => _cooldownSeconds = seconds);
  }

  Future<void> _loadDashboardData() async {
    final progress = await RewardProgressService.instance.loadSnapshot();
    final profiles = await ChildProfileService.instance.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _profiles = profiles;
    });
  }

  String get _enteredPin =>
      _pinControllers.map((controller) => controller.text).join();

  Future<void> _submitPin() async {
    final pin = _enteredPin;
    if (pin.length != 4) {
      setState(() => _errorMessage = 'Please enter all 4 digits.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    if (_needsSetup) {
      await ParentPinService.instance.setPin(pin);
      if (!mounted) return;
      setState(() {
        _isUnlocked = true;
        _needsSetup = false;
        _isSubmitting = false;
      });
      await _loadDashboardData();
      return;
    }

    final inCooldown = await ParentPinService.instance.isInCooldown();
    if (inCooldown) {
      await _refreshCooldown();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'Please wait $_cooldownSeconds seconds before trying again.';
      });
      return;
    }

    final valid = await ParentPinService.instance.verifyPin(pin);
    await _refreshCooldown();
    if (!mounted) return;

    if (valid) {
      for (final controller in _pinControllers) {
        controller.clear();
      }
      setState(() {
        _isUnlocked = true;
        _isSubmitting = false;
      });
      await _loadDashboardData();
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = _cooldownSeconds > 0
          ? 'Too many tries. Wait $_cooldownSeconds seconds.'
          : 'That PIN did not match. Try again.';
    });
    for (final controller in _pinControllers) {
      controller.clear();
    }
    _pinFocusNodes.first.requestFocus();
  }

  void _onPinChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _pinFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
    setState(() => _errorMessage = null);
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parentBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isUnlocked
                ? _buildDashboard()
                : _buildPinGate(),
      ),
    );
  }

  Widget _buildPinGate() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.parentAccent,
          ),
          const SizedBox(height: 12),
          Text(
            _needsSetup ? 'Set Parent PIN' : 'Parent Zone',
            style: AppTypography.h1.copyWith(color: const Color(0xFF1E1060)),
          ),
          const SizedBox(height: 8),
          Text(
            _needsSetup
                ? 'Create a 4-digit PIN so only grown-ups can open this area.'
                : 'Enter your parent PIN to view learning progress.',
            style: AppTypography.body.copyWith(
              color: const Color(0xFF5A6B7A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(
                  width: 58,
                  height: 64,
                  child: TextField(
                    controller: _pinControllers[index],
                    focusNode: _pinFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    obscureText: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: (value) => _onPinChanged(index, value),
                    onSubmitted: (_) {
                      if (index == 3) _submitPin();
                    },
                  ),
                ),
              );
            }),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submitPin,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.parentAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isSubmitting
                    ? 'Please wait...'
                    : (_needsSetup ? 'Save PIN' : 'Unlock Dashboard'),
                style: AppTypography.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final progress = _progress;
    final activeProfile = _profiles?.activeProfile;
    final reports = _reports
        .map(
          (entry) => _ActivityReport(
            title: entry.$2,
            emoji: entry.$3,
            completions: progress?.completionCountFor(entry.$1) ?? 0,
            starsEarned: (progress?.completionCountFor(entry.$1) ?? 0) *
                RewardProgressService.instance.starsForModule(entry.$1),
          ),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.parentAccent,
              ),
              Expanded(
                child: Text(
                  'Parent Dashboard',
                  style: AppTypography.h2.copyWith(
                    color: const Color(0xFF1E1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.parentAccent.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeProfile == null
                      ? 'Family Progress'
                      : '${activeProfile.name}\'s Progress',
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF1E1060),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatChip(
                      label: '${progress?.totalStars ?? 0} stars',
                      icon: Icons.star_rounded,
                      color: AppColors.premiumGold,
                    ),
                    _StatChip(
                      label: '${progress?.streakDays ?? 0} day streak',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                    ),
                    _StatChip(
                      label:
                          '${progress?.todayCompletions ?? 0} today',
                      icon: Icons.today_rounded,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Activity Levels',
            style: AppTypography.h3.copyWith(color: const Color(0xFF1E1060)),
          ),
          const SizedBox(height: 4),
          Text(
            'No scores — only gentle progress labels for young learners.',
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF5A6B7A),
            ),
          ),
          const SizedBox(height: 14),
          ...reports.map(_buildReportCard),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.startlearning),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Open Start Learning'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.parentAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(_ActivityReport report) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Text(report.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: AppTypography.bodyStrong),
                const SizedBox(height: 4),
                Text(
                  '${report.completions} sessions • ${report.starsEarned} stars',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: report.masteryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              report.masteryLabel,
              style: AppTypography.caption.copyWith(
                color: report.masteryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF1E1060),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
