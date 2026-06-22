import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localization.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../shared/widgets/celebration_bear.dart';
import '../../shared/widgets/game_back_button.dart';
import '../../shared/widgets/kid_loading_view.dart';

enum _RewardCategory { stickers, badges, trophies }

class _RewardItem {
  const _RewardItem({
    required this.id,
    required this.category,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.unlockStars,
  });

  final String id;
  final _RewardCategory category;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final int unlockStars;
}

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with RouteAware, SingleTickerProviderStateMixin {
  static const List<_RewardItem> _rewards = [
    _RewardItem(
      id: 'sticker-sun',
      category: _RewardCategory.stickers,
      emoji: '🌞',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      unlockStars: 0,
    ),
    _RewardItem(
      id: 'sticker-rainbow',
      category: _RewardCategory.stickers,
      emoji: '🌈',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      unlockStars: 6,
    ),
    _RewardItem(
      id: 'sticker-balloon',
      category: _RewardCategory.stickers,
      emoji: '🎈',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      unlockStars: 10,
    ),
    _RewardItem(
      id: 'sticker-crown',
      category: _RewardCategory.stickers,
      emoji: '👑',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
      unlockStars: 14,
    ),
    _RewardItem(
      id: 'badge-counter',
      category: _RewardCategory.badges,
      emoji: '🔢',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      unlockStars: 4,
    ),
    _RewardItem(
      id: 'badge-tracer',
      category: _RewardCategory.badges,
      emoji: '✏️',
      color: AppColors.pathwayPeach,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFD97A4D),
      unlockStars: 8,
    ),
    _RewardItem(
      id: 'badge-matcher',
      category: _RewardCategory.badges,
      emoji: '🃏',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      unlockStars: 12,
    ),
    _RewardItem(
      id: 'badge-quiz',
      category: _RewardCategory.badges,
      emoji: '🧠',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      unlockStars: 16,
    ),
    _RewardItem(
      id: 'trophy-bronze',
      category: _RewardCategory.trophies,
      emoji: '🏆',
      color: AppColors.pathwayPeach,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFD97A4D),
      unlockStars: 8,
    ),
    _RewardItem(
      id: 'trophy-silver',
      category: _RewardCategory.trophies,
      emoji: '🥈',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      unlockStars: 14,
    ),
    _RewardItem(
      id: 'trophy-gold',
      category: _RewardCategory.trophies,
      emoji: '🥇',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      unlockStars: 20,
    ),
    _RewardItem(
      id: 'trophy-royal',
      category: _RewardCategory.trophies,
      emoji: '👑',
      color: AppColors.parentAccent,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFF3A58C8),
      unlockStars: 24,
    ),
  ];

  Set<String> _claimedRewardIds = <String>{};
  Map<String, int> _completionCounts = <String, int>{};
  int _musicRequestToken = 0;
  int _currentStars = 0;
  late final FlutterTts _detailTts;
  late Future<void> _detailTtsReady;
  bool _detailTtsConfigured = false;
  _RewardCategory _selectedCategory = _RewardCategory.stickers;
  int _selectedIndex = 0;
  bool _showClaimCelebration = false;
  bool _isLoadingProgress = true;
  bool _isClaimingReward = false;
  String? _animatingRewardId;
  late final AnimationController _collectAnimationController;

  List<_RewardItem> get _visibleRewards => _rewards
      .where((reward) => reward.category == _selectedCategory)
      .toList(growable: false);

  _RewardItem get _selectedReward {
    final rewards = _visibleRewards;
    final safeIndex = math.min(
      math.max(_selectedIndex, 0),
      math.max(0, rewards.length - 1),
    );
    return rewards[safeIndex];
  }

  int get _unlockedCount =>
      _rewards.where((reward) => reward.unlockStars <= _currentStars).length;

  int get _claimedCount => _claimedRewardIds.length;

  int get _completedActivityCount => _completionCounts.values.fold(
        0,
        (total, count) => total + count,
      );

  int get _nextUnlockStars {
    final nextReward = _nextUnlockReward;
    return nextReward?.unlockStars ?? _currentStars;
  }

  double get _progressToNextUnlock {
    if (_nextUnlockStars <= _currentStars) return 1;
    final base = _previousUnlockStars;
    final range = math.max(1, _nextUnlockStars - base);
    return ((_currentStars - base) / range).clamp(0, 1).toDouble();
  }

  _RewardItem? get _nextUnlockReward {
    final locked = _rewards
        .where((reward) => reward.unlockStars > _currentStars)
        .toList(growable: false)
      ..sort((a, b) => a.unlockStars.compareTo(b.unlockStars));
    return locked.isEmpty ? null : locked.first;
  }

  int get _previousUnlockStars {
    final unlockedThresholds = _rewards
        .where((reward) => reward.unlockStars <= _currentStars)
        .map((reward) => reward.unlockStars)
        .toSet()
        .toList(growable: false)
      ..sort();
    return unlockedThresholds.isEmpty ? 0 : unlockedThresholds.last;
  }

  double get _collectPulse {
    final pulseTween = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 45,
      ),
    ]);
    return pulseTween.transform(_collectAnimationController.value);
  }

  double get _collectBurstProgress =>
      Curves.easeOutCubic.transform(_collectAnimationController.value);

  bool _isUnlocked(_RewardItem reward) => reward.unlockStars <= _currentStars;

  bool _isClaimed(_RewardItem reward) => _claimedRewardIds.contains(reward.id);

  Future<void> _loadProgress() async {
    final snapshot = await RewardProgressService.instance.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _currentStars = snapshot.totalStars;
      _claimedRewardIds = snapshot.claimedRewardIds;
      _completionCounts = snapshot.completionCounts;
      _isLoadingProgress = false;
    });
  }

  Future<void> _configureDetailTts() async {
    await AppLocalization.configureTts(_detailTts, context);
    await _detailTts.setPitch(1.04);
    await _detailTts.setVolume(1.0);
  }

  Future<void> _speakRewardDetail(_RewardItem reward) async {
    await _detailTtsReady;
    await _detailTts.stop();
    if (!mounted) return;
    await _detailTts.speak(
      '${AppLocalization.rewardItem(context, reward.id, 'title')}. '
      '${AppLocalization.rewardItem(context, reward.id, 'subtitle')}. '
      '${AppLocalization.rewardItem(context, reward.id, 'description')}',
    );
  }

  Future<void> _openRewardDetailSheet(_RewardItem reward) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final unlocked = _isUnlocked(reward);
        final claimed = _isClaimed(reward);
        return _RewardDetailSheet(
          reward: reward,
          unlocked: unlocked,
          claimed: claimed,
          onSpeakTap: () {
            HapticFeedback.selectionClick();
            _speakRewardDetail(reward);
          },
        );
      },
    );
    await _detailTts.stop();
  }

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

  void _goBack() {
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    context.pop();
  }

  void _selectCategory(_RewardCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedIndex = 0;
      _showClaimCelebration = false;
    });
  }

  void _selectReward(int index) {
    setState(() {
      _selectedIndex = index;
      _showClaimCelebration = false;
    });
  }

  Future<void> _claimSelectedReward() async {
    final reward = _selectedReward;
    if (!_isUnlocked(reward) || _isClaimed(reward) || _isClaimingReward) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isClaimingReward = true;
    });
    AppAudioService.instance.playCelebrationMusic();
    await RewardProgressService.instance.claimReward(reward.id);
    if (!mounted) return;
    setState(() {
      _claimedRewardIds.add(reward.id);
      _showClaimCelebration = true;
      _isClaimingReward = false;
      _animatingRewardId = reward.id;
    });
    _collectAnimationController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _detailTts = FlutterTts();
    _detailTtsReady = Future<void>.value();
    _collectAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _playScreenMusic(delayed: true);
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.unsubscribe(this);
      appRouteObserver.subscribe(this, route);
    }
    if (!_detailTtsConfigured) {
      _detailTtsConfigured = true;
      _detailTtsReady = _configureDetailTts();
    }
  }

  @override
  void didPush() {
    _playScreenMusic(delayed: true);
    _loadProgress();
  }

  @override
  void didPopNext() {
    _playScreenMusic(delayed: true);
    _loadProgress();
  }

  @override
  void didPushNext() {
    _stopScreenMusic();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    AppAudioService.instance.stopCelebrationMusic();
    _stopScreenMusic();
    _detailTts.stop();
    _collectAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProgress) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: KidLoadingView(
          title: context.tr('rewards.title'),
          subtitle: context.tr('rewards.loading'),
        ),
      );
    }

    final reward = _selectedReward;
    final unlocked = _isUnlocked(reward);
    final claimed = _isClaimed(reward);

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    constraints.maxWidth < 860 || constraints.maxHeight < 760;

                if (isCompact) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      18 + (MediaQuery.of(context).padding.bottom * 0.25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 16),
                        _buildSummaryRow(),
                        const SizedBox(height: 16),
                        _buildCategoryTabs(),
                        const SizedBox(height: 14),
                        _buildRewardGrid(shrinkWrap: true),
                        const SizedBox(height: 14),
                        _buildDetailPanel(
                          reward: reward,
                          unlocked: unlocked,
                          claimed: claimed,
                          scrollable: false,
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 16),
                      _buildSummaryRow(),
                      const SizedBox(height: 16),
                      _buildCategoryTabs(),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildRewardGrid(),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 4,
                              child: _buildDetailPanel(
                                reward: reward,
                                unlocked: unlocked,
                                claimed: claimed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final nextReward = _nextUnlockReward;
    final starsLeft =
        nextReward == null ? 0 : (nextReward.unlockStars - _currentStars);

    return Row(
      children: [
        GameBackButton(onTap: _goBack),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('rewards.title'),
                style: AppTypography.hero.copyWith(
                  fontSize: AppTypography.responsiveSize(
                    MediaQuery.sizeOf(context).width,
                    min: 26,
                    max: 31,
                  ),
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                nextReward == null
                    ? context.tr('rewards.all_claimed')
                    : context.tr(
                        'rewards.next_reward',
                        namedArgs: {'count': '$starsLeft'},
                      ),
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF586374),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final cards = [
      _SummaryCard(
        title: context.tr('math_operations.math_stars'),
        value: '$_currentStars',
        emoji: '⭐',
        color: AppColors.warning,
        softColor: AppColors.premiumGoldLight,
      ),
      _SummaryCard(
        title: context.tr('rewards.unlocked'),
        value: '$_unlockedCount',
        emoji: '🎁',
        color: AppColors.secondary,
        softColor: AppColors.secondaryLight,
      ),
      AnimatedBuilder(
        animation: _collectAnimationController,
        builder: (context, _) {
          return _SummaryCard(
            title: context.tr('rewards.claimed'),
            value: '$_claimedCount',
            emoji: '🏆',
            color: AppColors.parentAccent,
            softColor: AppColors.restBackground,
            pulse: _animatingRewardId == null ? 0 : _collectPulse,
          );
        },
      ),
      _SummaryCard(
        title: context.tr('learning.learning_adventures'),
        value: '$_completedActivityCount',
        emoji: '🎮',
        color: AppColors.primary,
        softColor: AppColors.primaryLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 760 ? 4 : 2;
        final totalSpacing = 12.0 * (crossAxisCount - 1);
        final cardWidth =
            (constraints.maxWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    final tabs = [
      _CategoryTab(
        label: context.tr('rewards.categories.stickers'),
        emoji: '✨',
        selected: _selectedCategory == _RewardCategory.stickers,
        color: AppColors.primary,
        onTap: () => _selectCategory(_RewardCategory.stickers),
      ),
      _CategoryTab(
        label: context.tr('rewards.categories.badges'),
        emoji: '🎖️',
        selected: _selectedCategory == _RewardCategory.badges,
        color: AppColors.bridgeBlue,
        onTap: () => _selectCategory(_RewardCategory.badges),
      ),
      _CategoryTab(
        label: context.tr('rewards.categories.trophies'),
        emoji: '🏆',
        selected: _selectedCategory == _RewardCategory.trophies,
        color: AppColors.premiumGold,
        onTap: () => _selectCategory(_RewardCategory.trophies),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 560 ? 3 : 2;
        final totalSpacing = 10.0 * (crossAxisCount - 1);
        final tabWidth = constraints.maxWidth < 360
            ? constraints.maxWidth
            : (constraints.maxWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tabs
              .map((tab) => SizedBox(width: tabWidth, child: tab))
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildRewardGrid({bool shrinkWrap = false}) {
    final rewards = _visibleRewards;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;
          final isTablet = constraints.maxWidth >= 720;
          final isTightGrid = constraints.maxWidth < 430;
          final tileHeight = isTablet ? 196.0 : (isTightGrid ? 186.0 : 192.0);

          return GridView.builder(
            shrinkWrap: shrinkWrap,
            padding: const EdgeInsets.fromLTRB(2, 2, 2, 10),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rewards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: tileHeight,
            ),
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final selected = index == _selectedIndex;
              final unlocked = _isUnlocked(reward);
              final claimed = _isClaimed(reward);
              final animateCollect = _animatingRewardId == reward.id;

              return AnimatedBuilder(
                animation: _collectAnimationController,
                builder: (context, child) {
                  final pulse = animateCollect ? _collectPulse : 0.0;
                  return Transform.scale(
                    scale: 1 + pulse * 0.08,
                    child: child,
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectReward(index),
                    borderRadius: BorderRadius.circular(24),
                    child: LayoutBuilder(
                      builder: (context, cardConstraints) {
                        final compactTile = cardConstraints.maxWidth < 150 ||
                            cardConstraints.maxHeight < 150;
                        final iconBoxSize = compactTile ? 40.0 : 46.0;
                        final grayscale = !unlocked && !claimed;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.all(compactTile ? 12 : 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? reward.softColor.withValues(alpha: 0.88)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selected
                                    ? reward.color
                                    : reward.color.withValues(alpha: 0.18),
                                width: selected ? 2.5 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: reward.shadowColor.withValues(
                                    alpha: selected ? 0.28 : 0.12,
                                  ),
                                  blurRadius: selected ? 16 : 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ColorFiltered(
                                      colorFilter: grayscale
                                          ? const ColorFilter.matrix([
                                              0.2126,
                                              0.7152,
                                              0.0722,
                                              0,
                                              0,
                                              0.2126,
                                              0.7152,
                                              0.0722,
                                              0,
                                              0,
                                              0.2126,
                                              0.7152,
                                              0.0722,
                                              0,
                                              0,
                                              0,
                                              0,
                                              0,
                                              1,
                                              0,
                                            ])
                                          : const ColorFilter.mode(
                                              Colors.transparent,
                                              BlendMode.srcOver,
                                            ),
                                      child: Container(
                                        width: iconBoxSize,
                                        height: iconBoxSize,
                                        decoration: BoxDecoration(
                                          color: reward.softColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            reward.emoji,
                                            style: TextStyle(
                                              fontSize: compactTile ? 21 : 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      claimed
                                          ? Icons.check_circle_rounded
                                          : unlocked
                                              ? Icons.lock_open_rounded
                                              : Icons.lock_rounded,
                                      color: claimed
                                          ? AppColors.gardenGreen
                                          : unlocked
                                              ? reward.color
                                              : AppColors.disabled,
                                      size: compactTile ? 20 : 24,
                                    ),
                                  ],
                                ),
                                SizedBox(height: compactTile ? 10 : 12),
                                Text(
                                  AppLocalization.rewardItem(
                                    context,
                                    reward.id,
                                    'title',
                                  ),
                                  maxLines: compactTile ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyStrong.copyWith(
                                    color: const Color(0xFF1A1060),
                                    fontWeight: FontWeight.w800,
                                    fontSize: compactTile ? 14 : 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        claimed
                                            ? context.tr('rewards.claimed')
                                            : unlocked
                                                ? context.tr('rewards.unlocked')
                                                : context.tr(
                                                    'rewards.need_stars',
                                                    namedArgs: {
                                                      'count':
                                                          '${reward.unlockStars}',
                                                    },
                                                  ),
                                        maxLines: compactTile ? 2 : 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: claimed
                                              ? AppColors.gardenGreen
                                              : unlocked
                                                  ? reward.color
                                                  : AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: compactTile ? 11.5 : 12,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailPanel({
    required _RewardItem reward,
    required bool unlocked,
    required bool claimed,
    bool scrollable = true,
  }) {
    final starsNeeded = math.max(0, reward.unlockStars - _currentStars);
    final detailContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRewardShowcase(
          reward: reward,
          unlocked: unlocked,
          claimed: claimed,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalization.rewardItem(context, reward.id, 'description'),
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr('rewards.next_reward', namedArgs: {'count': '$starsNeeded'}),
          style: AppTypography.bodyStrong.copyWith(
            color: const Color(0xFF1A1060),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _progressToNextUnlock,
            minHeight: 12,
            backgroundColor: AppColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(reward.color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          unlocked
              ? context.tr('rewards.unlocked')
              : context.tr(
                  'rewards.need_stars',
                  namedArgs: {'count': '$starsNeeded'},
                ),
          style: AppTypography.bodySmall.copyWith(
            color: unlocked ? AppColors.gardenGreen : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (_showClaimCelebration && claimed) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.correctFeedback.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.gardenGreen.withValues(alpha: 0.55),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const CelebrationBear(size: 82),
                const SizedBox(height: 8),
                Text(
                  context.tr('learning.activity_complete'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.gardenGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: claimed
                    ? context.tr('rewards.claimed')
                    : unlocked
                        ? (_isClaimingReward
                            ? context.tr('learning.loading_title')
                            : context.tr('rewards.claim'))
                        : context.tr('rewards.locked'),
                icon: claimed
                    ? Icons.check_rounded
                    : unlocked
                        ? Icons.card_giftcard_rounded
                        : Icons.lock_rounded,
                backgroundColor: claimed
                    ? AppColors.gardenGreen
                    : unlocked
                        ? reward.color
                        : AppColors.disabled,
                foregroundColor: Colors.white,
                borderColor: claimed
                    ? const Color(0xFF3A9040)
                    : unlocked
                        ? reward.shadowColor
                        : AppColors.disabled,
                onTap: claimed || !unlocked || _isClaimingReward
                    ? null
                    : _claimSelectedReward,
              ),
            ),
          ],
        ),
        if (reward.category == _RewardCategory.stickers) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _ActionButton(
              label: context.tr('rewards.categories.stickers'),
              icon: Icons.style_rounded,
              backgroundColor: reward.softColor,
              foregroundColor: reward.color,
              borderColor: reward.color.withValues(alpha: 0.35),
              onTap: () => _openRewardDetailSheet(reward),
            ),
          ),
        ],
      ],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: reward.color.withValues(alpha: 0.28), width: 2),
        boxShadow: [
          BoxShadow(
            color: reward.color.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: scrollable
          ? SingleChildScrollView(child: detailContent)
          : detailContent,
    );
  }

  Widget _buildRewardShowcase({
    required _RewardItem reward,
    required bool unlocked,
    required bool claimed,
  }) {
    final animateCollect = _animatingRewardId == reward.id;

    return AnimatedBuilder(
      animation: _collectAnimationController,
      builder: (context, child) {
        final pulse = animateCollect ? _collectPulse : 0.0;
        return Transform.scale(
          scale: 1 + pulse * 0.08,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: reward.softColor.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (animateCollect)
                  AnimatedBuilder(
                    animation: _collectAnimationController,
                    builder: (context, _) {
                      return _CollectStarBurst(
                        progress: _collectBurstProgress,
                        color: reward.color,
                      );
                    },
                  ),
                ColorFiltered(
                  colorFilter: !unlocked && !claimed
                      ? const ColorFilter.matrix([
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ])
                      : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.srcOver,
                        ),
                  child: Text(
                    reward.emoji,
                    style: const TextStyle(fontSize: 42),
                  ),
                ),
                if (!unlocked && !claimed)
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
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
            const SizedBox(height: 8),
            Text(
              AppLocalization.rewardItem(context, reward.id, 'title'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.h2.copyWith(
                color: const Color(0xFF1A1060),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalization.rewardItem(context, reward.id, 'subtitle'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: reward.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.emoji,
    required this.color,
    required this.softColor,
    this.pulse = 0,
  });

  final String title;
  final String value;
  final String emoji;
  final Color color;
  final Color softColor;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + (pulse * 0.05),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.22)),
          boxShadow: pulse <= 0
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18 + (pulse * 0.12)),
                    blurRadius: 12 + (pulse * 8),
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: softColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTypography.bodyStrong.copyWith(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectStarBurst extends StatelessWidget {
  const _CollectStarBurst({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - progress).clamp(0.0, 1.0);
    const offsets = [
      Offset(0, -34),
      Offset(28, -18),
      Offset(32, 20),
      Offset(-30, 18),
      Offset(-26, -20),
    ];

    return IgnorePointer(
      child: SizedBox(
        width: 116,
        height: 116,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < offsets.length; i++)
              Transform.translate(
                offset: Offset(
                  offsets[i].dx * progress,
                  offsets[i].dy * progress,
                ),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: 0.75 + ((1 - (i * 0.08)) * progress * 0.9),
                    child: Icon(
                      i.isEven
                          ? Icons.star_rounded
                          : Icons.auto_awesome_rounded,
                      size: 14 + (i.isEven ? 4 : 0),
                      color: color.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RewardDetailSheet extends StatelessWidget {
  const _RewardDetailSheet({
    required this.reward,
    required this.unlocked,
    required this.claimed,
    required this.onSpeakTap,
  });

  final _RewardItem reward;
  final bool unlocked;
  final bool claimed;
  final VoidCallback onSpeakTap;

  @override
  Widget build(BuildContext context) {
    final statusText = claimed
        ? context.tr('rewards.claimed')
        : unlocked
            ? context.tr('rewards.unlocked')
            : context.tr(
                'rewards.need_stars',
                namedArgs: {
                  'count': '${reward.unlockStars}',
                },
              );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: reward.color.withValues(alpha: 0.24),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: reward.shadowColor.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('rewards.categories.stickers'),
                      style: AppTypography.h2.copyWith(
                        color: const Color(0xFF1A1060),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF5B6676),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: reward.softColor.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      reward.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalization.rewardItem(context, reward.id, 'title'),
                      textAlign: TextAlign.center,
                      style: AppTypography.h2.copyWith(
                        color: const Color(0xFF1A1060),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalization.rewardItem(context, reward.id, 'subtitle'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: reward.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: claimed
                      ? AppColors.correctFeedback.withValues(alpha: 0.85)
                      : reward.softColor.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: claimed
                        ? AppColors.gardenGreen.withValues(alpha: 0.32)
                        : reward.color.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  statusText,
                  style: AppTypography.bodySmall.copyWith(
                    color: claimed ? AppColors.gardenGreen : reward.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalization.rewardItem(context, reward.id, 'description'),
                style: AppTypography.body.copyWith(
                  color: const Color(0xFF556172),
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: context.tr('learning.speaker'),
                      icon: Icons.volume_up_rounded,
                      backgroundColor: reward.color,
                      foregroundColor: Colors.white,
                      borderColor: reward.shadowColor,
                      onTap: onSpeakTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.25),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: selected ? Colors.white : color,
                    fontWeight: FontWeight.w800,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w800,
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
