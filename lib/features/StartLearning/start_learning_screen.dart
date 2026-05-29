import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';

class _LearningModule {
  const _LearningModule({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final String route;
}

class StartLearningScreen extends StatelessWidget {
  const StartLearningScreen({super.key});

  static const List<_LearningModule> _modules = [
    _LearningModule(
      title: 'Learn Numbers',
      subtitle: 'Swipe giant number art from 0 to 30',
      emoji: '🔢',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      route: AppRoutes.learnNumbers,
    ),
    _LearningModule(
      title: 'Trace Numbers',
      subtitle: 'Trace and write numbers beautifully',
      emoji: '✏️',
      color: AppColors.pathwayPeach,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFD97A4D),
      route: AppRoutes.tracing,
    ),
    _LearningModule(
      title: 'Count Objects',
      subtitle: 'Count fruits, stars and toys',
      emoji: '🍎',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      route: '/count-objects',
    ),
    _LearningModule(
      title: 'Find Correct Number',
      subtitle: 'Choose the correct magical number',
      emoji: '🎯',
      color: AppColors.stairsLavender,
      softColor: AppColors.restBackground,
      shadowColor: Color(0xFFA888E8),
      route: '/find-number',
    ),
    _LearningModule(
      title: 'Match Numbers',
      subtitle: 'Match numbers with correct objects',
      emoji: '🃏',
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      route: '/match-numbers',
    ),
    _LearningModule(
      title: 'Mini Quiz',
      subtitle: 'Test your brain with fun questions',
      emoji: '🧠',
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      route: '/mini-quiz',
    ),
    _LearningModule(
      title: 'Rewards',
      subtitle: 'Collect stars and unlock trophies',
      emoji: '🏆',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      route: '/rewards',
    ),
  ];

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
                        onTap: () => context.pop(),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Start Learning 🎮',
                          style: AppTypography.hero.copyWith(
                            fontSize: 31,
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Choose a fun activity and become a Math Hero!',
                      style: AppTypography.body.copyWith(
                        color: const Color(0xFF4A5568),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                                'Complete Lessons & Win Stars!',
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.surface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Finish activities to unlock magical rewards',
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
                  ..._modules.map(
                    (module) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _LearningCard(module: module),
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
                                '3 Stars Earned Today!',
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E1060),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Keep learning to unlock golden rewards',
                                style: AppTypography.bodySmall.copyWith(
                                  color: const Color(0xFF7A849A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  3,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF6B35),
              offset: Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF2D1B69),
          size: 28,
        ),
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({required this.module});

  final _LearningModule module;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(module.route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: module.color.withValues(alpha: 0.45),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: module.shadowColor.withValues(alpha: 0.8),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: module.color.withValues(alpha: 0.18),
              offset: const Offset(0, 10),
              blurRadius: 22,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: module.softColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: module.color.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    module.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: AppTypography.cardTitle.copyWith(
                        color: const Color(0xFF1E1060),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      module.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF7A849A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: module.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Start Adventure',
                        style: AppTypography.bodySmall.copyWith(
                          color: module.color,
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: module.color.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: module.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
