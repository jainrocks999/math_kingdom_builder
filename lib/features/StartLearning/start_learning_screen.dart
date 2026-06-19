import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/child_profile_service.dart';
import '../../core/router/app_router.dart';
import '../../core/services/reward_progress_service.dart';
import '../../shared/widgets/celebration_bear.dart';
import '../../shared/widgets/game_back_button.dart';

class _LearningModule {
  const _LearningModule({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.route,
    this.progressId,
    this.unlockStars = 0,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final String route;
  final String? progressId;
  final int unlockStars;
}

class _AdventureShortcut {
  const _AdventureShortcut({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.route,
    required this.color,
    required this.softColor,
    required this.shadowColor,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final String route;
  final Color color;
  final Color softColor;
  final Color shadowColor;
}

class StartLearningScreen extends StatefulWidget {
  const StartLearningScreen({super.key});

  static const List<int> _rewardUnlockThresholds = [
    0,
    6,
    10,
    14,
    4,
    8,
    12,
    16,
    8,
    14,
    20,
    24,
  ];

  static const List<_LearningModule> _modules = [
    _LearningModule(
      title: 'Learn Numbers',
      subtitle: 'Swipe giant number art from 0 to 30',
      emoji: '🔢',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      route: AppRoutes.learnNumbers,
      progressId: RewardModuleIds.learnNumbers,
      unlockStars: 0,
    ),
    _LearningModule(
      title: 'Trace Numbers',
      subtitle: 'Trace and write numbers beautifully',
      emoji: '✏️',
      color: AppColors.pathwayPeach,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFD97A4D),
      route: AppRoutes.tracing,
      progressId: RewardModuleIds.traceNumbers,
      unlockStars: 0,
    ),
    _LearningModule(
      title: 'Count Objects',
      subtitle: 'Count fruits, stars and toys',
      emoji: '🍎',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      route: AppRoutes.counting,
      progressId: RewardModuleIds.countObjects,
      unlockStars: 0,
    ),
    _LearningModule(
      title: 'Find Correct Number',
      subtitle: 'Choose the correct magical number',
      emoji: '🎯',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
      route: AppRoutes.findNumber,
      progressId: RewardModuleIds.findNumber,
      unlockStars: 4,
    ),
    _LearningModule(
      title: 'Match Numbers',
      subtitle: 'Match numbers with correct objects',
      emoji: '🃏',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      route: AppRoutes.matching,
      progressId: RewardModuleIds.matchNumbers,
      unlockStars: 8,
    ),
    _LearningModule(
      title: 'Mini Quiz',
      subtitle: 'Test your brain with fun questions',
      emoji: '🧠',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      route: AppRoutes.miniQuiz,
      progressId: RewardModuleIds.miniQuiz,
      unlockStars: 14,
    ),
    _LearningModule(
      title: 'Rewards',
      subtitle: 'Collect stars and unlock trophies',
      emoji: '🏆',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      route: AppRoutes.stickers,
      unlockStars: 0,
    ),
  ];

  static const List<_AdventureShortcut> _moreAdventures = [
    _AdventureShortcut(
      title: 'Math Ops',
      subtitle: 'Add, subtract, multiply, divide',
      emoji: '➕',
      route: AppRoutes.mathOperations,
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
    _AdventureShortcut(
      title: 'Sequencing',
      subtitle: 'Put numbers in order',
      emoji: '📶',
      route: AppRoutes.sequencing,
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
    ),
    _AdventureShortcut(
      title: 'Patterns',
      subtitle: 'Spot magical repeats',
      emoji: '🔷',
      route: AppRoutes.patterns,
      color: AppColors.success,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF3A9040),
    ),
  ];

  @override
  State<StartLearningScreen> createState() => _StartLearningScreenState();
}

class _StartLearningScreenState extends State<StartLearningScreen>
    with RouteAware {
  int _musicRequestToken = 0;
  bool _isShowingUnlockDialog = false;
  final List<String> _pendingUnlockRoutes = <String>[];
  ChildProfileSnapshot? _profileSnapshot;
  RewardProgressSnapshot _progressSnapshot = const RewardProgressSnapshot(
    totalStars: 0,
    completionCounts: {},
    claimedRewardIds: <String>{},
    todayCompletions: 0,
    streakDays: 0,
  );

  Future<void> _loadProgress() async {
    final snapshot = await RewardProgressService.instance.loadSnapshot();
    final seenUnlockedModules =
        await RewardProgressService.instance.loadSeenUnlockedModules();
    final currentlyUnlockedRoutes = StartLearningScreen._modules
        .where((module) =>
            module.unlockStars > 0 && snapshot.totalStars >= module.unlockStars)
        .map((module) => module.route)
        .toSet();

    if (!mounted) return;

    if (seenUnlockedModules == null) {
      await RewardProgressService.instance.initializeSeenUnlockedModules(
        currentlyUnlockedRoutes,
      );
    } else {
      final newUnlockedRoutes =
          currentlyUnlockedRoutes.difference(seenUnlockedModules);
      if (newUnlockedRoutes.isNotEmpty) {
        final orderedRoutes = StartLearningScreen._modules
            .where((module) => newUnlockedRoutes.contains(module.route))
            .map((module) => module.route)
            .toList(growable: false);
        await RewardProgressService.instance.markUnlockedModulesSeen(
          newUnlockedRoutes,
        );
        _queueUnlockedRoutes(orderedRoutes);
      }
    }

    setState(() {
      _progressSnapshot = snapshot;
    });
  }

  Future<void> _loadProfiles() async {
    final snapshot = await ChildProfileService.instance.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _profileSnapshot = snapshot;
    });
  }

  bool _isUnlocked(_LearningModule module) =>
      _progressSnapshot.totalStars >= module.unlockStars;

  _LearningModule? get _recommendedModule {
    for (final module in StartLearningScreen._modules) {
      if (module.progressId == null || !_isUnlocked(module)) continue;
      if (_progressSnapshot.completionCountFor(module.progressId!) == 0) {
        return module;
      }
    }

    for (final module in StartLearningScreen._modules) {
      if (module.progressId == null || !_isUnlocked(module)) continue;
      if (_progressSnapshot.completionCountFor(module.progressId!) < 3) {
        return module;
      }
    }

    return null;
  }

  _LearningModule? get _nextLockedModule {
    final lockedModules = StartLearningScreen._modules
        .where((module) => !_isUnlocked(module))
        .toList(growable: false)
      ..sort((a, b) => a.unlockStars.compareTo(b.unlockStars));
    return lockedModules.isEmpty ? null : lockedModules.first;
  }

  int get _unlockedRewardsCount => StartLearningScreen._rewardUnlockThresholds
      .where((unlockStars) => _progressSnapshot.totalStars >= unlockStars)
      .length;

  int get _claimableRewardsCount => math.max(
      0, _unlockedRewardsCount - _progressSnapshot.claimedRewardIds.length);

  void _playScreenMusic({bool delayed = false}) {
    final requestToken = ++_musicRequestToken;
    Future<void>.delayed(
      delayed ? const Duration(milliseconds: 180) : Duration.zero,
      () {
        if (!mounted || requestToken != _musicRequestToken) return;
        AppAudioService.instance.playStartCountingMusic();
      },
    );
  }

  void _stopScreenMusic() {
    _musicRequestToken++;
    AppAudioService.instance.stopBackgroundMusic();
  }

  void _openModule(String route) {
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    context.push(route);
  }

  void _queueUnlockedRoutes(List<String> routes) {
    for (final route in routes) {
      if (!_pendingUnlockRoutes.contains(route)) {
        _pendingUnlockRoutes.add(route);
      }
    }
    _showNextUnlockDialog();
  }

  _LearningModule? _moduleForRoute(String route) {
    for (final module in StartLearningScreen._modules) {
      if (module.route == route) return module;
    }
    return null;
  }

  void _showNextUnlockDialog() {
    if (_isShowingUnlockDialog || !mounted || _pendingUnlockRoutes.isEmpty) {
      return;
    }

    final route = _pendingUnlockRoutes.removeAt(0);
    final module = _moduleForRoute(route);
    if (module == null) {
      _showNextUnlockDialog();
      return;
    }

    _showUnlockedModuleDialog(module);
  }

  void _showUnlockedModuleDialog(_LearningModule module) {
    _isShowingUnlockDialog = true;
    _stopScreenMusic();
    AppAudioService.instance.playCelebrationMusic();

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: module.color.withValues(alpha: 0.35),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: module.shadowColor.withValues(alpha: 0.22),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: module.softColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'New Adventure Unlocked',
                    style: AppTypography.bodySmall.copyWith(
                      color: module.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const CelebrationBear(size: 100),
                const SizedBox(height: 12),
                Text(
                  module.emoji,
                  style: const TextStyle(fontSize: 38),
                ),
                const SizedBox(height: 8),
                Text(
                  module.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: const Color(0xFF1E1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You earned enough stars to unlock this new learning adventure.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF5A6B7A),
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Later',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textSecondary,
                        borderColor: AppColors.outlineStrong,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogButton(
                        label: 'Open Now',
                        backgroundColor: module.color,
                        foregroundColor: Colors.white,
                        borderColor: module.shadowColor,
                        onTap: () {
                          Navigator.of(context).pop();
                          _openModule(module.route);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      AppAudioService.instance.stopCelebrationMusic();
      _isShowingUnlockDialog = false;
      if (mounted) {
        _playScreenMusic(delayed: true);
      }
      _showNextUnlockDialog();
    });
  }

  void _handleModuleTap(_LearningModule module) {
    if (_isUnlocked(module)) {
      _openModule(module.route);
      return;
    }
    HapticFeedback.mediumImpact();
    _showLockedModuleDialog(module);
  }

  void _showLockedModuleDialog(_LearningModule module) {
    final starsNeeded =
        math.max(0, module.unlockStars - _progressSnapshot.totalStars);

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: module.color.withValues(alpha: 0.35),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: module.shadowColor.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: module.softColor.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        module.emoji,
                        style: const TextStyle(fontSize: 38),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${module.title} is Locked',
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: const Color(0xFF1E1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Earn $starsNeeded more star${starsNeeded == 1 ? '' : 's'} to open this adventure.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF5A6B7A),
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: module.softColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_progressSnapshot.totalStars} / ${module.unlockStars} stars',
                        style: AppTypography.bodyStrong.copyWith(
                          color: module.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (_progressSnapshot.totalStars /
                                  module.unlockStars)
                              .clamp(0, 1)
                              .toDouble(),
                          minHeight: 10,
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(module.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Keep Learning',
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textSecondary,
                        borderColor: AppColors.outlineStrong,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogButton(
                        label: 'Open Rewards',
                        backgroundColor: module.color,
                        foregroundColor: Colors.white,
                        borderColor: module.shadowColor,
                        onTap: () {
                          Navigator.of(context).pop();
                          _openModule(AppRoutes.stickers);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goBack() {
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
  }

  Future<void> _switchProfile(int index) async {
    await ChildProfileService.instance.setActiveProfileIndex(index);
    await _loadProfiles();
  }

  void _showProfilePicker() {
    final snapshot = _profileSnapshot;
    if (snapshot == null) return;

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.parentAccent.withValues(alpha: 0.25),
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Learner',
                  style: AppTypography.h2.copyWith(
                    color: const Color(0xFF1E1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick who is playing right now.',
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF5A6B7A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(snapshot.profiles.length, (index) {
                  final profile = snapshot.profiles[index];
                  final selected = index == snapshot.activeIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _switchProfile(index);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.parentBackground
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.parentAccent
                                  : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.restBackground,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    profile.avatarPath,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  profile.name,
                                  style: AppTypography.bodyStrong.copyWith(
                                    color: const Color(0xFF1E1060),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.parentAccent,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _playScreenMusic(delayed: true);
    _loadProgress();
    _loadProfiles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.unsubscribe(this);
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _playScreenMusic(delayed: true);
    _loadProgress();
    _loadProfiles();
  }

  @override
  void didPush() {
    _playScreenMusic(delayed: true);
  }

  @override
  void didPushNext() {
    _stopScreenMusic();
  }

  @override
  void dispose() {
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = _profileSnapshot?.activeProfile;
    final completedActivities =
        _progressSnapshot.completionCounts.values.fold<int>(
      0,
      (total, count) => total + count,
    );
    final claimedRewards = _progressSnapshot.claimedRewardIds.length;
    final nextLockedModule = _nextLockedModule;
    final recommendedModule = _recommendedModule;
    const dailyGoal = 3;
    final todayProgress =
        (_progressSnapshot.todayCompletions / dailyGoal).clamp(0, 1).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backround.png',
              fit: BoxFit.cover,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF87CEEB).withValues(alpha: 0.55),
                  const Color(0xFFB8E4FF).withValues(alpha: 0.30),
                  AppColors.background.withValues(alpha: 0.25),
                  AppColors.restBackground.withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    children: [
                      _BackButton(
                        onTap: _goBack,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Learning 🎮',
                              style: AppTypography.hero.copyWith(
                                fontSize: AppTypography.responsiveSize(
                                  MediaQuery.sizeOf(context).width,
                                  min: 27,
                                  max: 32,
                                ),
                                color: const Color(0xFF1A1060),
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  const Shadow(
                                    color: Colors.white,
                                    blurRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                  Shadow(
                                    color: AppColors.parentAccent
                                        .withValues(alpha: 0.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              activeProfile == null
                                  ? 'Choose a fun activity and become a Math Hero!'
                                  : 'Playing as ${activeProfile.name}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFF5A6B7A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activeProfile != null) ...[
                        const SizedBox(width: 12),
                        _ProfileButton(
                          emoji: activeProfile.avatarPath,
                          onTap: _showProfilePicker,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Hero Banner
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.parentAccent,
                          AppColors.bridgeBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2A4AB8),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x6650A0FF),
                          offset: Offset(0, 12),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '🌟',
                              style: TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE664)
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '✦ Today\'s Mission',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0xFF8A6000),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_progressSnapshot.totalStars} Stars Collected!',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.surface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nextLockedModule == null
                                    ? '$completedActivities completed adventures • everything unlocked'
                                    : '$completedActivities completed adventures • unlock ${nextLockedModule.title} at ${nextLockedModule.unlockStars} stars',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color:
                                      AppColors.surface.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MomentumStat(
                                emoji: '🔥',
                                label: 'Streak',
                                value: _progressSnapshot.streakDays == 0
                                    ? 'Start now'
                                    : '${_progressSnapshot.streakDays} days',
                                color: AppColors.primary,
                                softColor: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MomentumStat(
                                emoji: '🎯',
                                label: 'Today',
                                value:
                                    '${_progressSnapshot.todayCompletions}/$dailyGoal adventures',
                                color: AppColors.secondary,
                                softColor: AppColors.secondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Daily goal progress',
                            style: AppTypography.bodyStrong.copyWith(
                              color: const Color(0xFF1E1060),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: todayProgress,
                            minHeight: 10,
                            backgroundColor: AppColors.surfaceMuted,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _progressSnapshot.todayCompletions >= dailyGoal
                                ? 'Daily goal complete. Amazing work today!'
                                : '${dailyGoal - _progressSnapshot.todayCompletions} more adventure${dailyGoal - _progressSnapshot.todayCompletions == 1 ? '' : 's'} to finish today\'s goal',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF5A6B7A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    'Learning Adventures 🗺️',
                    style: AppTypography.h2.copyWith(
                      color: const Color(0xFF2D1B69),
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Tap any activity to start your magical learning journey!',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF5A6B7A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Learning Cards
                  ...StartLearningScreen._modules.map(
                    (module) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _LearningCard(
                        module: module,
                        isUnlocked: _isUnlocked(module),
                        isRecommended: recommendedModule?.route == module.route,
                        starsRemainingToUnlock: math.max(
                          0,
                          module.unlockStars - _progressSnapshot.totalStars,
                        ),
                        completionCount: module.progressId == null
                            ? _progressSnapshot.claimedRewardIds.length
                            : _progressSnapshot.completionCountFor(
                                module.progressId!,
                              ),
                        earnedStars: module.progressId == null
                            ? _progressSnapshot.totalStars
                            : (_progressSnapshot.completionCountFor(
                                  module.progressId!,
                                ) *
                                RewardProgressService.instance
                                    .starsForModule(module.progressId!)),
                        customProgressValue: module.progressId == null
                            ? (_unlockedRewardsCount /
                                    StartLearningScreen
                                        ._rewardUnlockThresholds.length)
                                .clamp(0, 1)
                                .toDouble()
                            : null,
                        customStatusLabel: module.progressId == null
                            ? _claimableRewardsCount > 0
                                ? '$_claimableRewardsCount reward${_claimableRewardsCount == 1 ? '' : 's'} ready to claim'
                                : claimedRewards == 0
                                    ? 'Open the reward room'
                                    : '$claimedRewards reward${claimedRewards == 1 ? '' : 's'} collected'
                            : null,
                        metricLabel: module.progressId == null
                            ? '$_unlockedRewardsCount/${StartLearningScreen._rewardUnlockThresholds.length}'
                            : null,
                        onTap: () => _handleModuleTap(module),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'More Adventures ✨',
                    style: AppTypography.h2.copyWith(
                      color: const Color(0xFF2D1B69),
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Try extra math quests outside the main learning path.',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF5A6B7A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        for (var i = 0;
                            i < StartLearningScreen._moreAdventures.length;
                            i++)
                          Padding(
                            padding: EdgeInsets.only(
                              right: i ==
                                      StartLearningScreen
                                              ._moreAdventures.length -
                                          1
                                  ? 0
                                  : 12,
                            ),
                            child: SizedBox(
                              width: 170,
                              child: _AdventureShortcutCard(
                                adventure:
                                    StartLearningScreen._moreAdventures[i],
                                onTap: () => _openModule(
                                  StartLearningScreen._moreAdventures[i].route,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bottom Rewards Banner
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.premiumGold.withValues(alpha: 0.4),
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFD4A000),
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x66FFD54F),
                          offset: Offset(0, 10),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.premiumGoldLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              '🏆',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_progressSnapshot.totalStars} Stars Earned!',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E1060),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _claimableRewardsCount > 0
                                    ? '$_claimableRewardsCount reward${_claimableRewardsCount == 1 ? '' : 's'} ready in Rewards'
                                    : '$claimedRewards reward${claimedRewards == 1 ? '' : 's'} collected so far',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFF7A849A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  math.min(5, _progressSnapshot.totalStars),
                                  (index) => const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: AppColors.premiumGold,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GameBackButton(onTap: onTap);
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({
    required this.module,
    required this.isUnlocked,
    required this.isRecommended,
    required this.starsRemainingToUnlock,
    required this.completionCount,
    required this.earnedStars,
    required this.onTap,
    this.customProgressValue,
    this.customStatusLabel,
    this.metricLabel,
  });

  final _LearningModule module;
  final bool isUnlocked;
  final bool isRecommended;
  final int starsRemainingToUnlock;
  final int completionCount;
  final int earnedStars;
  final VoidCallback? onTap;
  final double? customProgressValue;
  final String? customStatusLabel;
  final String? metricLabel;

  double get _progressValue {
    if (customProgressValue != null) return customProgressValue!;
    if (module.progressId == null) {
      return (completionCount / 6).clamp(0, 1).toDouble();
    }
    return (completionCount / 3).clamp(0, 1).toDouble();
  }

  String get _statusLabel {
    if (customStatusLabel != null) return customStatusLabel!;
    if (!isUnlocked) {
      return 'Earn $starsRemainingToUnlock more star${starsRemainingToUnlock == 1 ? '' : 's'}';
    }
    if (module.progressId == null) {
      return completionCount == 0
          ? 'Open rewards'
          : '$completionCount claimed rewards';
    }
    if (completionCount == 0) return 'Start adventure';
    if (completionCount >= 3) return 'Mastered';
    return '$completionCount wins';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.surface
                : AppColors.surfaceMuted.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isUnlocked
                  ? module.color.withValues(alpha: 0.45)
                  : AppColors.disabled.withValues(alpha: 0.7),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isUnlocked
                    ? module.shadowColor.withValues(alpha: 0.8)
                    : AppColors.disabled.withValues(alpha: 0.8),
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: isUnlocked
                    ? module.color.withValues(alpha: 0.18)
                    : AppColors.shadow,
                offset: const Offset(0, 10),
                blurRadius: 22,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 340;
                final iconSize = isCompact ? 64.0 : 74.0;
                final arrowSize = isCompact ? 40.0 : 44.0;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? module.softColor.withValues(alpha: 0.7)
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isUnlocked
                                  ? module.color.withValues(alpha: 0.35)
                                  : AppColors.disabled.withValues(alpha: 0.55),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              module.emoji,
                              style: TextStyle(
                                fontSize: isCompact ? 31 : 36,
                                color: isUnlocked ? null : AppColors.disabled,
                              ),
                            ),
                          ),
                        ),
                        if (!isUnlocked)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      AppColors.disabled.withValues(alpha: 0.7),
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isRecommended) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: module.softColor.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: module.color.withValues(alpha: 0.24),
                                ),
                              ),
                              child: Text(
                                'Recommended next',
                                style: AppTypography.bodySmall.copyWith(
                                  color: module.color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                          Text(
                            module.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.cardTitle.copyWith(
                              color: isUnlocked
                                  ? const Color(0xFF1E1060)
                                  : AppColors.textSecondary,
                              fontSize: isCompact ? 18 : 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            module.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: isUnlocked
                                  ? const Color(0xFF7A849A)
                                  : AppColors.disabled,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: _progressValue,
                                    minHeight: 8,
                                    backgroundColor: module.softColor
                                        .withValues(alpha: 0.55),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isUnlocked
                                          ? module.color
                                          : AppColors.disabled,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                metricLabel ??
                                    (isUnlocked ? '$earnedStars⭐' : '🔒'),
                                style: AppTypography.bodySmall.copyWith(
                                  color: isUnlocked
                                      ? module.color
                                      : AppColors.disabled,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? module.color.withValues(alpha: 0.12)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodySmall.copyWith(
                                color: isUnlocked
                                    ? module.color
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: arrowSize,
                      height: arrowSize,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? module.color.withValues(alpha: 0.16)
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnlocked
                              ? module.color.withValues(alpha: 0.4)
                              : AppColors.disabled.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isUnlocked
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.lock_rounded,
                        size: 18,
                        color: isUnlocked ? module.color : AppColors.disabled,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.bodyStrong.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MomentumStat extends StatelessWidget {
  const _MomentumStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.softColor,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: softColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: const Color(0xFF1E1060),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdventureShortcutCard extends StatelessWidget {
  const _AdventureShortcutCard({
    required this.adventure,
    required this.onTap,
  });

  final _AdventureShortcut adventure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: adventure.color.withValues(alpha: 0.42),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: adventure.shadowColor.withValues(alpha: 0.8),
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: adventure.color.withValues(alpha: 0.16),
                offset: const Offset(0, 10),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: adventure.softColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    adventure.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                adventure.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyStrong.copyWith(
                  color: const Color(0xFF1E1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                adventure.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF7A849A),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({
    required this.emoji,
    required this.onTap,
  });

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.parentAccent.withValues(alpha: 0.24),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.parentAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
