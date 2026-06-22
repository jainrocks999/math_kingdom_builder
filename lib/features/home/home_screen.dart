import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/daily_challenge_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../../data/models/home_action_model.dart';
import '../../data/models/quest_model.dart';
import '../../shared/widgets/kid_oops_view.dart';
import 'home_content_mappers.dart';
import 'home_content_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  static const int _dailyGoal = 3;

  RewardProgressSnapshot _progressSnapshot = const RewardProgressSnapshot(
    totalStars: 0,
    completionCounts: {},
    claimedRewardIds: <String>{},
    todayCompletions: 0,
    streakDays: 0,
  );
  DailyChallengeSnapshot? _dailyChallengeSnapshot;

  @override
  void initState() {
    super.initState();
    AppAudioService.instance.playHomeMusic();
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
  void dispose() {
    appRouteObserver.unsubscribe(this);
    AppAudioService.instance.stopHomeMusic();
    super.dispose();
  }

  @override
  void didPopNext() {
    AppAudioService.instance.playHomeMusic();
    _loadProgress();
  }

  @override
  void didPushNext() {
    AppAudioService.instance.stopHomeMusic();
  }

  void _navigateWithoutHomeMusic(String route, {bool replace = false}) {
    AppAudioService.instance.stopHomeMusic();

    if (replace) {
      context.go(route);
    } else {
      context.push(route);
    }
  }

  Future<void> _loadProgress() async {
    var snapshot = await RewardProgressService.instance.loadSnapshot();
    final dailyChallenge = await DailyChallengeService.instance.loadSnapshot(
      progressSnapshot: snapshot,
    );
    if (dailyChallenge.rewardGrantedNow) {
      snapshot = await RewardProgressService.instance.loadSnapshot();
    }
    if (!mounted) return;
    setState(() {
      _progressSnapshot = snapshot;
      _dailyChallengeSnapshot = dailyChallenge;
    });
  }

  int _progressForQuest(QuestModel quest) {
    switch (quest.id) {
      case 'counting':
        return _completionCountForModules([RewardModuleIds.countObjects]);
      case 'tracing':
        return _completionCountForModules([RewardModuleIds.traceNumbers]);
      case 'matching':
        return _completionCountForModules([RewardModuleIds.matchNumbers]);
      case 'math_operations':
        return _completionCountForModules([
          RewardModuleIds.addition,
          RewardModuleIds.subtraction,
          RewardModuleIds.multiplication,
          RewardModuleIds.division,
        ]);
      case 'sequencing':
        return _completionCountForModules([RewardModuleIds.sequencing]);
      case 'patterns':
        return _completionCountForModules([RewardModuleIds.patterns]);
      default:
        return 0;
    }
  }

  int _completionCountForModules(List<String> moduleIds) {
    return moduleIds.fold<int>(
      0,
      (total, moduleId) =>
          total + _progressSnapshot.completionCountFor(moduleId),
    );
  }

  double _heroTitleSize(double maxWidth) {
    return AppTypography.responsiveSize(maxWidth, min: 29, max: 36);
  }

  double _featuredAspectRatio(double maxWidth) {
    if (maxWidth < 340) return 0.94;
    if (maxWidth < 380) return 1.02;
    return 1.14;
  }

  double _questAspectRatio(double maxWidth) {
    if (maxWidth < 340) return 0.78;
    if (maxWidth < 380) return 0.87;
    return 0.96;
  }

  String _featureTitle(BuildContext context, HomeActionModel action) {
    final key = 'home.featured_actions.${action.id}.title';
    final translated = context.tr(key);
    return translated == key ? action.title : translated;
  }

  String _featureSubtitle(BuildContext context, HomeActionModel action) {
    final key = 'home.featured_actions.${action.id}.subtitle';
    final translated = context.tr(key);
    return translated == key ? action.subtitle : translated;
  }

  String _questLabel(BuildContext context, QuestModel quest) {
    final key = 'home.quests.${quest.id}.label';
    final translated = context.tr(key);
    return translated == key ? quest.label : translated;
  }

  String _questDescription(BuildContext context, QuestModel quest) {
    final key = 'home.quests.${quest.id}.description';
    final translated = context.tr(key);
    return translated == key ? quest.description : translated;
  }

  @override
  Widget build(BuildContext context) {
    final homeContent = ref.watch(homeContentProvider);

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

          // Positioned.fill(
          //   child: SvgPicture.asset(
          //     'assets/images/svg/math_kingdom_bg.svg',
          //     fit: BoxFit.cover,
          //     alignment: Alignment.topCenter,
          //   ),
          // ),
          // Sky gradient overlay
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
            child: homeContent.when(
              data: (content) => LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(child: _SunBadge()),
                              const SizedBox(width: 12),
                              _HeaderActions(
                                totalStars: _progressSnapshot.totalStars,
                                onParentTap: () => _navigateWithoutHomeMusic(
                                  AppRoutes.parentDashboard,
                                ),
                                onSettingsTap: () => _navigateWithoutHomeMusic(
                                  AppRoutes.settings,
                                ),
                                onRewardsTap: () => _navigateWithoutHomeMusic(
                                  AppRoutes.stickers,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('home.hero_title'),
                            style: AppTypography.hero.copyWith(
                              fontSize: _heroTitleSize(constraints.maxWidth),
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
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            context.tr('home.hero_subtitle'),
                            style: AppTypography.body.copyWith(
                              color: const Color(0xFF4A5568),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _PrimaryPlayButton(
                            onPressed: () => _navigateWithoutHomeMusic(
                              AppRoutes.startlearning,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: content.featuredActions.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: _featuredAspectRatio(
                                constraints.maxWidth,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final action = content.featuredActions[index];
                              return _FeatureCard(
                                action: action,
                                title: _featureTitle(context, action),
                                subtitle: _featureSubtitle(context, action),
                                onTap: () => _navigateWithoutHomeMusic(
                                  action.route,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 26),
                          Text(
                            context.tr('home.choose_quest_title'),
                            style: AppTypography.h2.copyWith(
                              color: const Color(0xFF2D1B69),
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              shadows: [
                                const Shadow(
                                  color: Colors.white,
                                  blurRadius: 0,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('home.choose_quest_subtitle'),
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF5A6B7A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: content.quests.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: _questAspectRatio(
                                constraints.maxWidth,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final quest = content.quests[index];
                              return _QuestCard(
                                quest: quest,
                                label: _questLabel(context, quest),
                                description: _questDescription(context, quest),
                                progressStars: _progressForQuest(quest).clamp(
                                  0,
                                  3,
                                ),
                                onTap: quest.isComingSoon
                                    ? null
                                    : () => _navigateWithoutHomeMusic(
                                          quest.route,
                                        ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _DailyChallengeBanner(
                            challengeSnapshot: _dailyChallengeSnapshot,
                            todayCompletions:
                                _progressSnapshot.todayCompletions,
                            dailyGoal: _dailyGoal,
                            streakDays: _progressSnapshot.streakDays,
                            onTap: () => _navigateWithoutHomeMusic(
                              _dailyChallengeSnapshot?.challenge.route ??
                                  AppRoutes.startlearning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: _HomeLoadingView.new,
              error: (error, stackTrace) => _HomeErrorView(
                onRetry: () => ref.invalidate(homeContentProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar Widgets ──────────────────────────────────────────────────────────

class _SunBadge extends StatelessWidget {
  const _SunBadge();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 170;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFFFC83C).withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 18 : 22,
                height: compact ? 18 : 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFB800),
                    width: compact ? 1.6 : 2,
                  ),
                ),
              ),
              SizedBox(width: compact ? 6 : 8),
              Flexible(
                child: Text(
                  context.tr('home.sunny_badge'),
                  style: AppTypography.bodyStrong.copyWith(
                    color: const Color(0xFFC17A00),
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.totalStars,
    required this.onParentTap,
    required this.onSettingsTap,
    required this.onRewardsTap,
  });

  final int totalStars;
  final VoidCallback onParentTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onRewardsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StarCountChip(totalStars: totalStars),
        const SizedBox(width: 8),
        _SettingsButton(onTap: onSettingsTap),
        const SizedBox(width: 8),
        _ParentZoneButton(onTap: onParentTap),
        const SizedBox(width: 8),
        _RewardsButton(onTap: onRewardsTap),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: AppColors.secondary,
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _ParentZoneButton extends StatelessWidget {
  const _ParentZoneButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.parentAccent.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.shield_moon_rounded,
            color: AppColors.parentAccent,
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _StarCountChip extends StatelessWidget {
  const _StarCountChip({required this.totalStars});

  final int totalStars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7B8), Color(0xFFFFE07A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFC83C).withValues(alpha: 0.7),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE2B22B),
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x33F8C74E),
            offset: Offset(0, 8),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFD99A00),
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            '$totalStars',
            style: AppTypography.bodyStrong.copyWith(
              color: const Color(0xFF8A6000),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            totalStars == 1
                ? context.tr('common.star_word_one')
                : context.tr('common.star_word_other'),
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF8A6000),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardsButton extends StatelessWidget {
  const _RewardsButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFC83C).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFD4A000),
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ─── Primary Play Button ──────────────────────────────────────────────────────

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.pathwayPeach],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFF8C4A),
              width: 3,
            ),
            boxShadow: const [
              // "3D press" bottom shadow
              BoxShadow(
                color: Color(0xFFC94A18),
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Color(0x66FF6B35),
                offset: Offset(0, 10),
                blurRadius: 18,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎮', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr('home.start_learning_title'),
                      style: AppTypography.buttonLarge.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.tr('home.start_learning_subtitle'),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.action,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final HomeActionModel action;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(action.colorHex, fallback: AppColors.primary);
    final softColor = colorFromHex(
      action.softColorHex,
      fallback: AppColors.primaryLight,
    );
    final shadowColor = colorFromHex(
      action.shadowColorHex,
      fallback: AppColors.primary,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: color.withValues(alpha: 0.45),
              width: 2.5,
            ),
            boxShadow: [
              // "3D press" bottom shadow — the key kid-friendly effect
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.8),
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                offset: const Offset(0, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compactHeight = constraints.maxHeight < 175;
              final tilePadding = compactHeight ? 12.0 : 14.0;
              final artworkSize = compactHeight ? 52.0 : 58.0;
              final artworkRadius = compactHeight ? 16.0 : 18.0;
              final chevronSize = compactHeight ? 26.0 : 28.0;
              final titleFontSize = compactHeight ? 14.5 : 15.5;
              final subtitleFontSize = compactHeight ? 11.5 : 12.0;
              final topGap = compactHeight ? 8.0 : 10.0;
              final textGap = compactHeight ? 3.0 : 4.0;

              return Padding(
                padding: EdgeInsets.all(tilePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: artworkSize,
                          height: artworkSize,
                          decoration: BoxDecoration(
                            color: softColor.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(artworkRadius),
                            border: Border.all(
                              color: color.withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              compactHeight ? 12 : 14,
                            ),
                            child: Image.asset(
                              action.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    iconFromKey(action.iconKey),
                                    color: color,
                                    size: compactHeight ? 24 : 28,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: chevronSize,
                          height: chevronSize,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: compactHeight ? 16 : 18,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: topGap),
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        color: const Color(0xFF1E1060),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: textGap),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF7A849A),
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Quest Card ───────────────────────────────────────────────────────────────

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.label,
    required this.description,
    required this.onTap,
    required this.progressStars,
  });

  final QuestModel quest;
  final String label;
  final String description;
  final VoidCallback? onTap;
  final int progressStars;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(quest.colorHex, fallback: AppColors.secondary);
    final shadowColor = colorFromHex(
      quest.shadowColorHex,
      fallback: AppColors.secondary,
    );
    final isComingSoon = quest.isComingSoon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: isComingSoon
                ? AppColors.surfaceMuted.withValues(alpha: 0.94)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 2.5,
            ),
            boxShadow: [
              // "3D press" bottom shadow
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.75),
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.18),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emoji container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: color.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          quest.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                iconFromKey(quest.iconKey),
                                color: color,
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Play button
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.45),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 18,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.cardTitle.copyWith(
                          color: const Color(0xFF1E1060),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isComingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.tr('home.coming_soon'),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF7A849A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: List.generate(3, (i) {
                    final filled = i < progressStars;
                    return Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: filled
                              ? color.withValues(alpha: 0.22)
                              : const Color(0xFFF0EBE4),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: filled
                                ? color.withValues(alpha: 0.65)
                                : const Color(0xFFD8CFCA),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: filled ? color : const Color(0xFFB8B0A8),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return KidOopsView(
      title: context.tr('home.error.title'),
      subtitle: context.tr('home.error.subtitle'),
      buttonLabel: context.tr('home.error.button'),
      onButtonTap: onRetry,
    );
  }
}

// ─── Daily Challenge Banner ───────────────────────────────────────────────────

class _DailyChallengeBanner extends StatelessWidget {
  const _DailyChallengeBanner({
    required this.onTap,
    required this.challengeSnapshot,
    required this.todayCompletions,
    required this.dailyGoal,
    required this.streakDays,
  });

  final VoidCallback onTap;
  final DailyChallengeSnapshot? challengeSnapshot;
  final int todayCompletions;
  final int dailyGoal;
  final int streakDays;

  bool get _isRewardClaimed => challengeSnapshot?.isRewardClaimed ?? false;

  bool get _isChallengeCompleted => challengeSnapshot?.isCompleted ?? false;

  String _challengeTitle(BuildContext context) {
    final challenge = challengeSnapshot?.challenge;
    if (challenge == null) return '';
    final key = 'home.daily_challenges.${challenge.id}.title';
    final translated = context.tr(key);
    return translated == key ? challenge.title : translated;
  }

  String _challengeSubtitle(BuildContext context) {
    final challenge = challengeSnapshot?.challenge;
    if (challenge == null) return '';
    final key = 'home.daily_challenges.${challenge.id}.subtitle';
    final translated = context.tr(key);
    return translated == key ? challenge.subtitle : translated;
  }

  String _headline(BuildContext context) {
    final challengeTitle = _challengeTitle(context);
    if (_isRewardClaimed) {
      return context.tr('home.daily.reward_earned');
    }
    if (_isChallengeCompleted) {
      return challengeTitle.isEmpty
          ? context.tr('home.daily.daily_challenge_complete')
          : context.tr(
              'home.daily.challenge_complete',
              namedArgs: {'title': challengeTitle},
            );
    }
    if (todayCompletions >= dailyGoal) {
      return challengeTitle.isEmpty
          ? context.tr('home.daily.daily_goal_complete')
          : context.tr(
              'home.daily.challenge_complete',
              namedArgs: {'title': challengeTitle},
            );
    }
    if (todayCompletions == 0) {
      return challengeTitle.isEmpty
          ? context.tr('home.daily.start_today_challenge')
          : context.tr(
              'home.daily.play_challenge',
              namedArgs: {'title': challengeTitle},
            );
    }
    return context.plural('home.daily.adventures_done', todayCompletions);
  }

  String _subtitle(BuildContext context) {
    final challenge = challengeSnapshot?.challenge;
    final localizedTitle = _challengeTitle(context);
    final localizedSubtitle = _challengeSubtitle(context);
    if (_isRewardClaimed) {
      final bonusStars = challengeSnapshot?.bonusStars ?? 0;
      return challenge == null
          ? context.tr(
              'home.daily.reward_added_today',
              namedArgs: {'stars': '$bonusStars'},
            )
          : context.tr(
              'home.daily.reward_added_for_challenge',
              namedArgs: {'stars': '$bonusStars', 'title': localizedTitle},
            );
    }
    if (_isChallengeCompleted) {
      return challenge == null
          ? context.tr('home.daily.challenge_bonus_today')
          : context.tr(
              'home.daily.challenge_bonus_named',
              namedArgs: {'title': localizedTitle},
            );
    }
    if (todayCompletions >= dailyGoal) {
      return streakDays > 1
          ? context.tr(
              'home.daily.streak_glowing',
              namedArgs: {'days': '$streakDays'},
            )
          : challenge == null
              ? context.tr('home.daily.goal_complete_keep_going')
              : context.tr(
                  'home.daily.challenge_complete_keep_going',
                  namedArgs: {'title': localizedTitle},
                );
    }

    final remaining = dailyGoal - todayCompletions;
    final remainingLabel = context.plural(
      'common.adventures',
      remaining,
    );
    if (challenge == null) {
      return context.tr(
        'home.daily.remaining_to_crown',
        namedArgs: {'count': remainingLabel},
      );
    }
    return context.tr(
      'home.daily.remaining_to_goal',
      namedArgs: {
        'subtitle': localizedSubtitle,
        'count': remainingLabel,
      },
    );
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
            gradient: const LinearGradient(
              colors: [AppColors.parentAccent, AppColors.bridgeBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 2.5,
            ),
            boxShadow: const [
              // "3D press" bottom shadow
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
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    challengeSnapshot?.challenge.emoji ?? '🌟',
                    style: const TextStyle(fontSize: 30),
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
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _isRewardClaimed
                            ? const Color(0xFFFFF2A8).withValues(alpha: 0.95)
                            : const Color(0xFFFFE664).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _isRewardClaimed
                            ? context.tr(
                                'home.daily.badge_claimed',
                                namedArgs: {
                                  'stars':
                                      '${challengeSnapshot?.bonusStars ?? 0}',
                                },
                              )
                            : context.tr(
                                'home.daily.badge_daily',
                                namedArgs: {
                                  'emoji':
                                      challengeSnapshot?.challenge.emoji ?? '✦',
                                },
                              ),
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF8A6000),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _headline(context),
                      style: AppTypography.cardTitle.copyWith(
                        color: AppColors.surface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(context),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _isRewardClaimed
                      ? Icons.check_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: _isRewardClaimed ? 20 : 16,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
