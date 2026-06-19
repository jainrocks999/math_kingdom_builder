import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'celebration_bear.dart';

class KidLoadingView extends StatelessWidget {
  const KidLoadingView({
    super.key,
    this.title = 'Loading...',
    this.subtitle = 'Getting your next activity ready.',
    this.color = AppColors.primary,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bearSize = compact ? 72.0 : 92.0;
    final spinnerSize = compact ? 18.0 : 22.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 20,
              vertical: compact ? 18 : 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(28),
              border:
                  Border.all(color: color.withValues(alpha: 0.22), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CelebrationBear(size: bearSize),
                SizedBox(height: compact ? 10 : 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: const Color(0xFF1E1060),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF5A6B7A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: compact ? 12 : 14),
                SizedBox(
                  width: spinnerSize,
                  height: spinnerSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
