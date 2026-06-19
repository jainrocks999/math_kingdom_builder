import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';

class _OperationCardData {
  const _OperationCardData({
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.route,
    required this.color,
    required this.softColor,
    required this.shadowColor,
    required this.available,
  });

  final String title;
  final String emoji;
  final String subtitle;
  final String route;
  final Color color;
  final Color softColor;
  final Color shadowColor;
  final bool available;
}

class MathOperationsScreen extends StatelessWidget {
  const MathOperationsScreen({super.key});

  static const _operations = [
    _OperationCardData(
      title: 'Addition',
      emoji: '➕',
      subtitle: 'Combine groups',
      route: AppRoutes.addition,
      color: AppColors.warning,
      softColor: AppColors.premiumGoldLight,
      shadowColor: Color(0xFFD4A000),
      available: true,
    ),
    _OperationCardData(
      title: 'Subtraction',
      emoji: '➖',
      subtitle: 'Take objects away',
      route: AppRoutes.subtraction,
      color: AppColors.secondary,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2AADA4),
      available: true,
    ),
    _OperationCardData(
      title: 'Multiplication',
      emoji: '✖️',
      subtitle: 'Build equal groups',
      route: AppRoutes.multiplication,
      color: AppColors.primary,
      softColor: AppColors.primaryLight,
      shadowColor: Color(0xFFC94A18),
      available: true,
    ),
    _OperationCardData(
      title: 'Division',
      emoji: '➗',
      subtitle: 'Share into groups',
      route: AppRoutes.division,
      color: AppColors.bridgeBlue,
      softColor: AppColors.secondaryLight,
      shadowColor: Color(0xFF2890D0),
      available: true,
    ),
  ];

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.home);
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
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF87CEEB).withValues(alpha: 0.55),
                  AppColors.background.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _goBack(context),
                          child: const SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF2D1B69),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Math Ops',
                        style: AppTypography.hero.copyWith(
                          fontSize: 30,
                          color: const Color(0xFF1A1060),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Addition, subtraction, multiplication, and division in one place.',
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF5A6B7A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._operations.map(
                    (operation) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _OperationPlayCard(
                        data: operation,
                        onTap: () => context.push(operation.route),
                      ),
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

class _OperationPlayCard extends StatelessWidget {
  const _OperationPlayCard({
    required this.data,
    required this.onTap,
  });

  final _OperationCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: data.color.withValues(alpha: 0.45),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: data.shadowColor.withValues(alpha: 0.8),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: data.color.withValues(alpha: 0.18),
              offset: const Offset(0, 10),
              blurRadius: 22,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: data.softColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: data.color.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: AppTypography.cardTitle.copyWith(
                      color: const Color(0xFF1E1060),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF6E768A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!data.available)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Soon',
                  style: AppTypography.caption.copyWith(
                    color: data.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.color.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: data.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
