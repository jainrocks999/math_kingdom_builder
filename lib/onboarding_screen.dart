import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/router/app_router.dart';
import 'shared/widgets/bouncing_game_button.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Build Your Dream Kingdom',
      description:
          'Solve math problems to earn coins and build amazing structures',
      imageUrl: 'assets/images/onboarding/first.png'
    ),
    OnboardingPageData(
      title: 'Math Made Fun',
      description:
          'From counting to calculus, grow your skills at your own pace',
      imageUrl: 'assets/images/onboarding/second.png',
    ),
    OnboardingPageData(
      title: 'Challenge Friends',
      description: 'Compete on leaderboards and show off your kingdom',
      imageUrl: 'assets/images/onboarding/third.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextTap() {
    if (_currentPage == _pages.length - 1) {
      // Once completed, navigate to home (or whichever is the next flow)
      context.go(AppRoutes.home);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.castle_rounded,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'Math Kingdom',
              style: AppTypography.h2.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backround.png',
              fit: BoxFit.cover,
            ),
          ),
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AspectRatio(
                          aspectRatio: 1,
                            child: Image.asset(
                            page.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      page.title,
                      style: GoogleFonts.lilitaOne(
                        textStyle: AppTypography.h1.copyWith(
                          fontSize: 36,
                          letterSpacing: 0.5,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.description,
                      style: GoogleFonts.quicksand(
                        textStyle: AppTypography.body.copyWith(
                          fontSize: 20, 
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: BouncingGameButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Start Building!'
                          : 'Next',
                      leadingIcon: _currentPage == _pages.length - 1
                          ? Icons.workspace_premium
                          : null,
                      trailingIcon: _currentPage != _pages.length - 1
                          ? Icons.arrow_forward
                          : null,
                      onTap: _onNextTap,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
