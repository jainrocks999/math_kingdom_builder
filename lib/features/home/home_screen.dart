import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';

class _HomeActionData {
  const _HomeActionData({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.emoji,
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final String emoji;
}

class _QuestData {
  const _QuestData({
    required this.label,
    required this.route,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.emoji,
    required this.description,
    required this.stars,
  });

  final String label;
  final String route;
  final IconData icon;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final String emoji;
  final String description;
  final int stars;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const List<_HomeActionData> _featuredActions = [
    _HomeActionData(
      title: 'Start Learning',
      subtitle: 'Number magic & playful counting',
      route: AppRoutes.startlearning,
      icon: Icons.play_arrow_rounded,
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      emoji: '🎮',
    ),
    _HomeActionData(
      title: 'Kingdom Map',
      subtitle: 'Visit the castle & unlock places',
      route: AppRoutes.kingdom,
      icon: Icons.castle_rounded,
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
      emoji: '🏰',
    ),
    _HomeActionData(
      title: 'Sticker Album',
      subtitle: 'Stars, stickers & shiny rewards',
      route: AppRoutes.stickers,
      icon: Icons.auto_awesome_rounded,
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      emoji: '⭐',
    ),
    _HomeActionData(
      title: 'Parent Zone',
      subtitle: 'Settings, progress & tools',
      route: AppRoutes.parentDashboard,
      icon: Icons.lock_outline_rounded,
      color: AppColors.parentAccent,
      softColor: AppColors.parentBackground,
      shadowColor: Color(0xFF3A58C8),
      emoji: '🔐',
    ),
  ];

  static const List<_QuestData> _quests = [
    _QuestData(
      label: 'Counting',
      route: AppRoutes.counting,
      icon: Icons.tag_rounded,
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      emoji: '🔢',
      description: 'Count objects and numbers 1–20',
      stars: 3,
    ),
    _QuestData(
      label: 'Tracing',
      route: AppRoutes.tracing,
      icon: Icons.gesture_rounded,
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      emoji: '✏️',
      description: 'Trace and write numbers beautifully',
      stars: 2,
    ),
    _QuestData(
      label: 'Matching',
      route: AppRoutes.matching,
      icon: Icons.view_week_rounded,
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
      emoji: '🃏',
      description: 'Match numbers to their groups',
      stars: 2,
    ),
    _QuestData(
      label: 'Addition',
      route: AppRoutes.addition,
      icon: Icons.add_circle_outline_rounded,
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      emoji: '➕',
      description: 'Add numbers with fun candy visuals',
      stars: 1,
    ),
    _QuestData(
      label: 'Sequencing',
      route: AppRoutes.sequencing,
      icon: Icons.format_list_numbered_rounded,
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      emoji: '📶',
      description: 'Put numbers in the right order',
      stars: 2,
    ),
    _QuestData(
      label: 'Patterns',
      route: AppRoutes.patterns,
      icon: Icons.auto_awesome_mosaic_rounded,
      color: AppColors.gardenGreen,
      softColor: AppColors.success,
      shadowColor: Color(0xFF3A9040),
      emoji: '🔷',
      description: 'Spot and complete magical patterns',
      stars: 3,
    ),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    AppAudioService.instance.playHomeMusic();
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
    super.dispose();
  }

  @override
  void didPopNext() {
    AppAudioService.instance.playHomeMusic();
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

  @override
  Widget build(BuildContext context) {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          children: [
                            const _SunBadge(),
                            const Spacer(),
                            _NotifButton(onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Hero title
                        Text(
                          'Math Kingdom ✨',
                          style: AppTypography.hero.copyWith(
                            fontSize: 36,
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
                          'Count, add, explore & grow your candy castle!',
                          style: AppTypography.body.copyWith(
                            color: const Color(0xFF4A5568),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Big Play button
                        _PrimaryPlayButton(
                          onPressed: () => _navigateWithoutHomeMusic(
                            AppRoutes.numberRecognition,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2x2 feature cards
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: HomeScreen._featuredActions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.14,
                          ),
                          itemBuilder: (context, index) => _FeatureCard(
                            action: HomeScreen._featuredActions[index],
                            onTap: () => _navigateWithoutHomeMusic(
                              HomeScreen._featuredActions[index].route,
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),

                        // Quest section header
                        Text(
                          'Choose a Quest 🗺️',
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
                          'Pick a mini adventure and keep the fun going!',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF5A6B7A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quest cards grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: HomeScreen._quests.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.96,
                          ),
                          itemBuilder: (context, index) => _QuestCard(
                            quest: HomeScreen._quests[index],
                            onTap: () => _navigateWithoutHomeMusic(
                              HomeScreen._quests[index].route,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Daily challenge banner
                        _DailyChallengeBanner(
                          onTap: () => _navigateWithoutHomeMusic(
                            AppRoutes.numberRecognition,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFB800), width: 2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Sunny adventures!',
            style: AppTypography.bodyStrong.copyWith(
              color: const Color(0xFFC17A00),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  const _NotifButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          Icons.notifications_none_rounded,
          color: Color(0xFF5A6B7A),
          size: 22,
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
    return GestureDetector(
      onTap: onPressed,
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
                    'Play Now!',
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Start with number recognition',
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
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.action, required this.onTap});
  final _HomeActionData action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: action.color.withValues(alpha: 0.45),
            width: 2.5,
          ),
          boxShadow: [
            // "3D press" bottom shadow — the key kid-friendly effect
            BoxShadow(
              color: action.shadowColor.withValues(alpha: 0.8),
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
            BoxShadow(
              color: action.color.withValues(alpha: 0.18),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Big emoji box
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: action.softColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: action.color.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        action.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Chevron pill
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: action.color.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: action.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                action.title,
                style: AppTypography.cardTitle.copyWith(
                  color: const Color(0xFF1E1060),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF7A849A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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

// ─── Quest Card ───────────────────────────────────────────────────────────────

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.onTap,
  });

  final _QuestData quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: quest.color.withValues(alpha: 0.5),
            width: 2.5,
          ),
          boxShadow: [
            // "3D press" bottom shadow
            BoxShadow(
              color: quest.shadowColor.withValues(alpha: 0.75),
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
            BoxShadow(
              color: quest.color.withValues(alpha: 0.18),
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
                      color: quest.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: quest.color.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        quest.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Play button
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: quest.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: quest.color.withValues(alpha: 0.45),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: quest.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                quest.label,
                style: AppTypography.cardTitle.copyWith(
                  color: const Color(0xFF1E1060),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                quest.description,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF7A849A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              // Colored star dots
              Row(
                children: List.generate(3, (i) {
                  final filled = i < quest.stars;
                  return Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: filled
                            ? quest.color.withValues(alpha: 0.22)
                            : const Color(0xFFF0EBE4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: filled
                              ? quest.color.withValues(alpha: 0.65)
                              : const Color(0xFFD8CFCA),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: filled ? quest.color : const Color(0xFFB8B0A8),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Daily Challenge Banner ───────────────────────────────────────────────────

class _DailyChallengeBanner extends StatelessWidget {
  const _DailyChallengeBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: const Center(
                child: Text('🌟', style: TextStyle(fontSize: 30)),
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
                      color: const Color(0xFFFFE664).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '✦ Daily Challenge',
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
                    'Count the Magic Stars!',
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.surface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete today\'s quest & earn a golden crown',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
