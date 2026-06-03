import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../shared/widgets/celebration_bear.dart';

enum _RewardCategory { stickers, badges, trophies }

class _RewardItem {
  const _RewardItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.unlockStars,
  });

  final String id;
  final _RewardCategory category;
  final String title;
  final String subtitle;
  final String description;
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

class _RewardsScreenState extends State<RewardsScreen> with RouteAware {
  static const List<_RewardItem> _rewards = [
    _RewardItem(
      id: 'sticker-sun',
      category: _RewardCategory.stickers,
      title: 'Sunny Star',
      subtitle: 'Happy morning sticker',
      description: 'A bright golden sticker for cheerful learning days.',
      emoji: '🌞',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      unlockStars: 0,
    ),
    _RewardItem(
      id: 'sticker-rainbow',
      category: _RewardCategory.stickers,
      title: 'Rainbow Pop',
      subtitle: 'Color splash sticker',
      description: 'Unlocked after a few wins to decorate your collection.',
      emoji: '🌈',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      unlockStars: 6,
    ),
    _RewardItem(
      id: 'sticker-balloon',
      category: _RewardCategory.stickers,
      title: 'Balloon Buddy',
      subtitle: 'Floating fun sticker',
      description: 'A party balloon sticker for steady practice.',
      emoji: '🎈',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      unlockStars: 10,
    ),
    _RewardItem(
      id: 'sticker-crown',
      category: _RewardCategory.stickers,
      title: 'Mini Crown',
      subtitle: 'Royal sticker reward',
      description: 'A royal crown for children who keep showing up.',
      emoji: '👑',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
      unlockStars: 14,
    ),
    _RewardItem(
      id: 'badge-counter',
      category: _RewardCategory.badges,
      title: 'Counting Champ',
      subtitle: 'Badge for number confidence',
      description: 'Celebrate strong counting progress with this mint badge.',
      emoji: '🔢',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      unlockStars: 4,
    ),
    _RewardItem(
      id: 'badge-tracer',
      category: _RewardCategory.badges,
      title: 'Tracing Pro',
      subtitle: 'Badge for careful writing',
      description: 'Awarded to learners who trace with patience.',
      emoji: '✏️',
      color: AppColors.pathwayPeach,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFD97A4D),
      unlockStars: 8,
    ),
    _RewardItem(
      id: 'badge-matcher',
      category: _RewardCategory.badges,
      title: 'Matching Master',
      subtitle: 'Badge for quick thinking',
      description: 'A smart badge for strong visual matching.',
      emoji: '🃏',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      unlockStars: 12,
    ),
    _RewardItem(
      id: 'badge-quiz',
      category: _RewardCategory.badges,
      title: 'Quiz Wizard',
      subtitle: 'Badge for mixed challenges',
      description: 'A shiny badge for handling tap, drag, and write tasks.',
      emoji: '🧠',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      unlockStars: 16,
    ),
    _RewardItem(
      id: 'trophy-bronze',
      category: _RewardCategory.trophies,
      title: 'Bronze Castle Cup',
      subtitle: 'First kingdom trophy',
      description: 'A small but proud trophy for early milestones.',
      emoji: '🏆',
      color: AppColors.pathwayPeach,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFD97A4D),
      unlockStars: 8,
    ),
    _RewardItem(
      id: 'trophy-silver',
      category: _RewardCategory.trophies,
      title: 'Silver Moon Cup',
      subtitle: 'Middle milestone trophy',
      description: 'A silver reward for consistent learning sessions.',
      emoji: '🥈',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      unlockStars: 14,
    ),
    _RewardItem(
      id: 'trophy-gold',
      category: _RewardCategory.trophies,
      title: 'Golden Kingdom Cup',
      subtitle: 'Big celebration trophy',
      description: 'A golden cup for building a strong math kingdom.',
      emoji: '🥇',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      unlockStars: 20,
    ),
    _RewardItem(
      id: 'trophy-royal',
      category: _RewardCategory.trophies,
      title: 'Royal Hero Crown',
      subtitle: 'Top collection reward',
      description: 'The grand reward for children who finish many adventures.',
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
  _RewardCategory _selectedCategory = _RewardCategory.stickers;
  int _selectedIndex = 0;
  bool _showClaimCelebration = false;
  bool _isLoadingProgress = true;

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
    final locked = _rewards
        .where((reward) => reward.unlockStars > _currentStars)
        .toList(growable: false)
      ..sort((a, b) => a.unlockStars.compareTo(b.unlockStars));
    return locked.isEmpty ? _currentStars : locked.first.unlockStars;
  }

  double get _progressToNextUnlock {
    if (_nextUnlockStars <= _currentStars) return 1;
    final base = (_nextUnlockStars - 6).clamp(0, _nextUnlockStars);
    final range = math.max(1, _nextUnlockStars - base);
    return ((_currentStars - base) / range).clamp(0, 1).toDouble();
  }

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

  void _claimSelectedReward() {
    final reward = _selectedReward;
    if (!_isUnlocked(reward) || _isClaimed(reward)) return;

    AppAudioService.instance.playCelebrationMusic();
    RewardProgressService.instance.claimReward(reward.id);
    setState(() {
      _claimedRewardIds.add(reward.id);
      _showClaimCelebration = true;
    });
  }

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProgress) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
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
                        child: isCompact
                            ? Column(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _buildRewardGrid(),
                                  ),
                                  const SizedBox(height: 14),
                                  Expanded(
                                    flex: 4,
                                    child: _buildDetailPanel(
                                      reward: reward,
                                      unlocked: unlocked,
                                      claimed: claimed,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
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
    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_back_rounded,
          color: AppColors.premiumGold,
          onTap: _goBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rewards',
                style: AppTypography.hero.copyWith(
                  fontSize: 30,
                  color: const Color(0xFF1A1060),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Collect stars, badges, and shiny rewards',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF586374),
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
        title: 'Star Bank',
        value: '$_currentStars',
        emoji: '⭐',
        color: AppColors.warning,
        softColor: AppColors.premiumGoldLight,
      ),
      _SummaryCard(
        title: 'Unlocked',
        value: '$_unlockedCount',
        emoji: '🎁',
        color: AppColors.secondary,
        softColor: AppColors.secondaryLight,
      ),
      _SummaryCard(
        title: 'Claimed',
        value: '$_claimedCount',
        emoji: '🏆',
        color: AppColors.parentAccent,
        softColor: AppColors.restBackground,
      ),
      _SummaryCard(
        title: 'Wins',
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
        label: 'Stickers',
        emoji: '✨',
        selected: _selectedCategory == _RewardCategory.stickers,
        color: AppColors.primary,
        onTap: () => _selectCategory(_RewardCategory.stickers),
      ),
      _CategoryTab(
        label: 'Badges',
        emoji: '🎖️',
        selected: _selectedCategory == _RewardCategory.badges,
        color: AppColors.bridgeBlue,
        onTap: () => _selectCategory(_RewardCategory.badges),
      ),
      _CategoryTab(
        label: 'Trophies',
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

  Widget _buildRewardGrid() {
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
          final crossAxisCount = constraints.maxWidth < 320 ? 1 : 2;
          final isTightGrid = constraints.maxWidth < 430;

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rewards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isTightGrid ? 1.14 : 1.05,
            ),
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final selected = index == _selectedIndex;
              final unlocked = _isUnlocked(reward);
              final claimed = _isClaimed(reward);

              return GestureDetector(
                onTap: () => _selectReward(index),
                child: LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final compactTile = cardConstraints.maxWidth < 150 ||
                        cardConstraints.maxHeight < 150;
                    final iconBoxSize = compactTile ? 40.0 : 46.0;

                    return AnimatedContainer(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: iconBoxSize,
                                height: iconBoxSize,
                                decoration: BoxDecoration(
                                  color: reward.softColor,
                                  borderRadius: BorderRadius.circular(16),
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
                          const Spacer(),
                          Text(
                            reward.title,
                            maxLines: compactTile ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyStrong.copyWith(
                              color: const Color(0xFF1A1060),
                              fontWeight: FontWeight.w800,
                              fontSize: compactTile ? 14 : 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            claimed
                                ? 'Claimed'
                                : unlocked
                                    ? 'Ready to claim'
                                    : 'Unlock at ${reward.unlockStars} stars',
                            maxLines: compactTile ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: claimed
                                  ? AppColors.gardenGreen
                                  : unlocked
                                      ? reward.color
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: compactTile ? 11.5 : 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
  }) {
    final starsNeeded = math.max(0, reward.unlockStars - _currentStars);

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: reward.softColor.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    reward.emoji,
                    style: const TextStyle(fontSize: 42),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reward.title,
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
                    reward.subtitle,
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
            const SizedBox(height: 16),
            Text(
              reward.description,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Progress to next reward',
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
                  ? 'Unlocked now'
                  : '$starsNeeded more stars needed to unlock this reward',
              style: AppTypography.bodySmall.copyWith(
                color:
                    unlocked ? AppColors.gardenGreen : AppColors.textSecondary,
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
                      'Reward Claimed!',
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
                        ? 'Already Claimed'
                        : unlocked
                            ? 'Claim Reward'
                            : 'Locked',
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
                    onTap: claimed || !unlocked ? null : _claimSelectedReward,
                  ),
                ),
              ],
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
  });

  final String title;
  final String value;
  final String emoji;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.22)),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white),
          ),
          child: Icon(icon, color: color),
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
