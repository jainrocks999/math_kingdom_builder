import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/audio_settings_service.dart';
import '../../core/services/child_profile_service.dart';
import '../../core/services/parent_pin_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../core/utils/audio_service.dart';
import '../../shared/widgets/game_back_button.dart';
import '../../shared/widgets/kid_loading_view.dart';

enum _MasteryLevel { exploring, practicing, confident }

class _ActivityReport {
  const _ActivityReport({
    required this.moduleId,
    required this.title,
    required this.emoji,
    required this.completions,
    required this.starsEarned,
  });

  final String moduleId;
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
  Timer? _cooldownTicker;

  RewardProgressSnapshot? _progress;
  ChildProfileSnapshot? _profiles;
  AudioSettingsSnapshot _audioSettings = const AudioSettingsSnapshot(
    musicEnabled: true,
    sfxEnabled: true,
    speechRateMode: 'normal',
  );

  static const _reports = [
    (RewardModuleIds.addition, 'Addition', '➕'),
    (RewardModuleIds.subtraction, 'Subtraction', '➖'),
    (RewardModuleIds.multiplication, 'Multiplication', '✖️'),
    (RewardModuleIds.division, 'Division', '➗'),
    (RewardModuleIds.sequencing, 'Sequencing', '🪜'),
    (RewardModuleIds.patterns, 'Patterns', '🔷'),
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

  String _moduleTitle(String moduleId, String fallback) {
    final key = 'parent_dashboard.modules.$moduleId';
    final translated = context.tr(key);
    return translated == key ? fallback : translated;
  }

  String _masteryLabel(_MasteryLevel mastery) {
    switch (mastery) {
      case _MasteryLevel.exploring:
        return context.tr('parent_dashboard.mastery.exploring');
      case _MasteryLevel.practicing:
        return context.tr('parent_dashboard.mastery.practicing');
      case _MasteryLevel.confident:
        return context.tr('parent_dashboard.mastery.confident');
    }
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
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
    final audioSettings = await AudioSettingsService.instance.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _needsSetup = !hasPin;
      _audioSettings = audioSettings;
      _isLoading = false;
    });
    await _refreshCooldown();
  }

  Future<int> _refreshCooldown() async {
    final inCooldown = await ParentPinService.instance.isInCooldown();
    final seconds = inCooldown
        ? await ParentPinService.instance.cooldownSecondsRemaining()
        : 0;
    if (!mounted) return seconds;
    setState(() => _cooldownSeconds = seconds);
    _cooldownTicker?.cancel();
    if (seconds > 0) {
      _cooldownTicker =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        final remaining =
            await ParentPinService.instance.cooldownSecondsRemaining();
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _cooldownSeconds = remaining);
        if (remaining <= 0) {
          timer.cancel();
        }
      });
    }
    return seconds;
  }

  Future<void> _loadDashboardData() async {
    final progress = await RewardProgressService.instance.loadSnapshot();
    final profiles = await ChildProfileService.instance.loadSnapshot();
    final audioSettings = await AudioSettingsService.instance.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _profiles = profiles;
      _audioSettings = audioSettings;
    });
  }

  String get _enteredPin =>
      _pinControllers.map((controller) => controller.text).join();

  Future<void> _submitPin() async {
    final pin = _enteredPin;
    if (pin.length != 4) {
      setState(
          () => _errorMessage = context.tr('parent_dashboard.pin_enter_all'));
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
      final seconds = await _refreshCooldown();
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = context.tr(
          'parent_dashboard.pin_wait_before_retry',
          namedArgs: {
            'seconds': context.plural('common.seconds', seconds),
          },
        );
      });
      return;
    }

    final valid = await ParentPinService.instance.verifyPin(pin);
    final seconds = await _refreshCooldown();
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
      _errorMessage = seconds > 0
          ? context.tr(
              'parent_dashboard.pin_too_many_tries',
              namedArgs: {
                'seconds': context.plural('common.seconds', seconds),
              },
            )
          : context.tr('parent_dashboard.pin_did_not_match');
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

  Future<void> _updateMusicEnabled(bool enabled) async {
    await AudioSettingsService.instance.setMusicEnabled(enabled);
    if (!enabled) {
      await AppAudioService.instance.stopBackgroundMusic();
    }
    if (!mounted) return;
    setState(() {
      _audioSettings = AudioSettingsSnapshot(
        musicEnabled: enabled,
        sfxEnabled: _audioSettings.sfxEnabled,
        speechRateMode: _audioSettings.speechRateMode,
      );
    });
  }

  Future<void> _updateSfxEnabled(bool enabled) async {
    await AudioSettingsService.instance.setSfxEnabled(enabled);
    AudioService().setSfxEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _audioSettings = AudioSettingsSnapshot(
        musicEnabled: _audioSettings.musicEnabled,
        sfxEnabled: enabled,
        speechRateMode: _audioSettings.speechRateMode,
      );
    });
  }

  Future<void> _updateSpeechRateMode(String mode) async {
    await AudioSettingsService.instance.setSpeechRateMode(mode);
    AudioService().setSpeechRate(mode);
    if (!mounted) return;
    setState(() {
      _audioSettings = AudioSettingsSnapshot(
        musicEnabled: _audioSettings.musicEnabled,
        sfxEnabled: _audioSettings.sfxEnabled,
        speechRateMode: mode,
      );
    });
  }

  Future<void> _switchProfile(int index) async {
    await ChildProfileService.instance.setActiveProfileIndex(index);
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parentBackground,
      body: SafeArea(
        child: _isLoading
            ? KidLoadingView(
                title: context.tr('parent_dashboard.title'),
                subtitle: context.tr('parent_dashboard.loading_subtitle'),
                color: AppColors.parentAccent,
                compact: true,
              )
            : _isUnlocked
                ? _buildDashboard()
                : _buildPinGate(),
      ),
    );
  }

  Widget _buildPinGate() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tablet = constraints.maxWidth >= 700;
        final pinWidth = tablet ? 72.0 : 58.0;
        final pinHeight = tablet ? 78.0 : 64.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: tablet ? 520 : 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameBackButton(
                    onTap: _goBack,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _needsSetup
                        ? context.tr('parent_dashboard.set_pin_title')
                        : context.tr('parent_dashboard.zone_title'),
                    style: AppTypography.h1
                        .copyWith(color: const Color(0xFF1E1060)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _needsSetup
                        ? context.tr('parent_dashboard.set_pin_subtitle')
                        : context.tr('parent_dashboard.zone_subtitle'),
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
                          width: pinWidth,
                          height: pinHeight,
                          child: TextField(
                            controller: _pinControllers[index],
                            focusNode: _pinFocusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
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
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                  if (_cooldownSeconds > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      context.tr(
                        'parent_dashboard.pin_locked',
                        namedArgs: {
                          'seconds': context.plural(
                              'common.seconds', _cooldownSeconds),
                        },
                      ),
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF7A4A00),
                        fontWeight: FontWeight.w700,
                      ),
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
                            ? context.tr('parent_dashboard.please_wait')
                            : (_needsSetup
                                ? context.tr('parent_dashboard.save_pin')
                                : context.tr(
                                    'parent_dashboard.unlock_dashboard',
                                  )),
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboard() {
    final progress = _progress;
    final activeProfile = _profiles?.activeProfile;
    final reports = _reports
        .map(
          (entry) => _ActivityReport(
            moduleId: entry.$1,
            title: _moduleTitle(entry.$1, entry.$2),
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
              GameBackButton(
                onTap: _goBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('parent_dashboard.title'),
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
                      ? context.tr('parent_dashboard.family_progress')
                      : context.tr(
                          'parent_dashboard.child_progress',
                          namedArgs: {'name': activeProfile.name},
                        ),
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
                      label: context.plural(
                        'common.stars',
                        progress?.totalStars ?? 0,
                      ),
                      icon: Icons.star_rounded,
                      color: AppColors.premiumGold,
                    ),
                    _StatChip(
                      label: context.tr(
                        'parent_dashboard.streak_label',
                        namedArgs: {'count': '${progress?.streakDays ?? 0}'},
                      ),
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.primary,
                    ),
                    _StatChip(
                      label:
                          '${progress?.todayCompletions ?? 0} ${context.tr('common.today')}',
                      icon: Icons.today_rounded,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(
            context.tr('parent_dashboard.child_profile_title'),
            context.tr('parent_dashboard.child_profile_subtitle'),
          ),
          const SizedBox(height: 12),
          _buildProfileSwitcher(),
          const SizedBox(height: 20),
          _buildSectionHeader(
            context.tr('parent_dashboard.audio_title'),
            context.tr('parent_dashboard.audio_subtitle'),
          ),
          const SizedBox(height: 12),
          _buildSettingsSection(),
          const SizedBox(height: 20),
          _buildSectionHeader(
            context.tr('parent_dashboard.summary_title'),
            context.tr('parent_dashboard.summary_subtitle'),
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(progress),
          const SizedBox(height: 20),
          Text(
            context.tr('parent_dashboard.activity_levels_title'),
            style: AppTypography.h3.copyWith(color: const Color(0xFF1E1060)),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('parent_dashboard.activity_levels_subtitle'),
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
              label: Text(context.tr('parent_dashboard.open_start_learning')),
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
                  context.tr(
                    'parent_dashboard.sessions_and_stars',
                    namedArgs: {
                      'sessions': '${report.completions}',
                      'stars': '${report.starsEarned}',
                    },
                  ),
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
              _masteryLabel(report.mastery),
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(color: const Color(0xFF1E1060)),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: const Color(0xFF5A6B7A),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSwitcher() {
    final profiles = _profiles;
    if (profiles == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(profiles.profiles.length, (index) {
          final profile = profiles.profiles[index];
          final selected = index == profiles.activeIndex;
          return ChoiceChip(
            label: Text('${profile.avatarPath} ${profile.name}'),
            selected: selected,
            onSelected: (_) => _switchProfile(index),
            selectedColor: AppColors.parentAccent.withValues(alpha: 0.18),
            labelStyle: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF1E1060),
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: selected ? AppColors.parentAccent : AppColors.outline,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _audioSettings.musicEnabled,
                onChanged: _updateMusicEnabled,
                title: Text(context.tr('common.music')),
                subtitle: Text(context.tr('settings.music_subtitle')),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _audioSettings.sfxEnabled,
                onChanged: _updateSfxEnabled,
                title: Text(context.tr('common.sound_effects')),
                subtitle: Text(context.tr('settings.sfx_subtitle')),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr('common.speech_rate'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: const Color(0xFF1E1060),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment<String>(
                    value: 'normal',
                    label: Text(context.tr('common.normal')),
                  ),
                  ButtonSegment<String>(
                    value: 'slow',
                    label: Text(context.tr('common.slow')),
                  ),
                ],
                selected: {_audioSettings.speechRateMode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  _updateSpeechRateMode(selection.first);
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.push('${AppRoutes.settings}?source=parent');
                    await _loadDashboardData();
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label:
                      Text(context.tr('parent_dashboard.open_full_settings')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.parentAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(RewardProgressSnapshot? progress) {
    final today = progress?.todayCompletions ?? 0;
    final streak = progress?.streakDays ?? 0;
    final stars = progress?.totalStars ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        context.tr(
          'parent_dashboard.summary_body',
          namedArgs: {
            'streak': _streakLabel(streak),
            'today': '$today',
            'stars': '$stars',
          },
        ),
        style: AppTypography.body.copyWith(
          color: const Color(0xFF1E1060),
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  String _streakLabel(int streak) => context.tr(
        'parent_dashboard.streak_label',
        namedArgs: {'count': '$streak'},
      );
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
