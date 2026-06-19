import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class KidOopsView extends StatelessWidget {
  const KidOopsView({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
  });

  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

  @override
  Widget build(BuildContext context) {
    final showButton = buttonLabel != null && onButtonTap != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                offset: const Offset(0, 12),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/bear/idle.png',
                height: 92,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('🐻', style: TextStyle(fontSize: 64));
                },
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.h3.copyWith(
                  color: const Color(0xFF2D1B69),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: const Color(0xFF5A6B7A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showButton) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onButtonTap,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(buttonLabel!),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    textStyle: AppTypography.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
