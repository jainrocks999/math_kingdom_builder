import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/router/app_router.dart';
import 'core/services/app_session_service.dart';
import 'core/services/audio_service.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.emoji,
    required this.color,
    required this.softColor,
    required this.shadowColor,
  });

  final String title;
  final String description;
  final String imageUrl;
  final String emoji;
  final Color color;
  final Color softColor;
  final Color shadowColor;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      title: 'Build Your Dream Kingdom',
      description:
          'Solve cute math missions, win coins, and unlock castle parts one by one.',
      imageUrl: 'assets/images/onboarding/first.png',
      emoji: '🏰',
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
    ),
    OnboardingPageData(
      title: 'Math Made Fun',
      description:
          'Count, trace, and listen through playful lessons made for little learners.',
      imageUrl: 'assets/images/onboarding/second.png',
      emoji: '🎈',
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
    ),
    OnboardingPageData(
      title: 'Collect Bright Rewards',
      description:
          'Earn stars, celebrate small wins, and show everyone your growing math kingdom.',
      imageUrl: 'assets/images/onboarding/third.png',
      emoji: '⭐',
      color: AppColors.premiumGold,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppAudioService.instance.playHomeMusic();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onNextTap() async {
    if (_currentPage == _pages.length - 1) {
      await AppSessionService.instance.markOnboardingComplete();
      if (!mounted) return;
      context.go(AppRoutes.home);
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentPage];

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
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _SunnyBadge(),
                          const Spacer(),
                          _SkipButton(
                            onTap: () => context.go(AppRoutes.home),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
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
                              color:
                                  AppColors.parentAccent.withValues(alpha: 0.3),
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
                      const SizedBox(height: 18),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            return _OnboardingCard(
                              page: _pages[index],
                              step: index + 1,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      _OnboardingCtaButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Start Learning'
                            : 'Next Adventure',
                        subtitle: _currentPage == _pages.length - 1
                            ? 'Enter the home castle and begin'
                            : 'See the next magical surprise',
                        color: currentPage.color,
                        shadowColor: currentPage.shadowColor,
                        emoji: currentPage.emoji,
                        onTap: _onNextTap,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          final page = _pages[index];
                          final isActive = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: isActive ? 34 : 16,
                            height: 16,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isActive
                                    ? [
                                        page.color.withValues(alpha: 0.82),
                                        page.color,
                                      ]
                                    : [
                                        Colors.white,
                                        page.softColor,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: isActive
                                      ? page.shadowColor
                                      : const Color(0xFFD6BFA9),
                                  offset: const Offset(0, 2),
                                  blurRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          );
                        }),
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
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.page,
    required this.step,
  });

  final OnboardingPageData page;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: page.color.withValues(alpha: 0.42),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: page.shadowColor.withValues(alpha: 0.8),
            offset: const Offset(0, 6),
            blurRadius: 0,
          ),
          BoxShadow(
            color: page.color.withValues(alpha: 0.18),
            offset: const Offset(0, 14),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: page.softColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: page.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(page.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Magic Step $step',
                    style: AppTypography.bodyStrong.copyWith(
                      color: page.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: page.softColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  page.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            page.title,
            style: AppTypography.h1.copyWith(
              fontSize: 31,
              color: const Color(0xFF1A1060),
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            page.description,
            style: AppTypography.body.copyWith(
              fontSize: 17,
              color: const Color(0xFF5A6B7A),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingCtaButton extends StatelessWidget {
  const _OnboardingCtaButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.shadowColor,
    required this.emoji,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final Color color;
  final Color shadowColor;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: color.withValues(alpha: 0.9), width: 3),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.26),
              offset: const Offset(0, 10),
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
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.buttonLarge.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.92),
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

class _SunnyBadge extends StatelessWidget {
  const _SunnyBadge();

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

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFFFC83C).withValues(alpha: 0.45),
            width: 2,
          ),
        ),
        child: Text(
          'Skip',
          style: AppTypography.bodyStrong.copyWith(
            color: const Color(0xFF5A6B7A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
