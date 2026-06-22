import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'kingdom_shared_widgets.dart';

class KingdomTopBar extends StatelessWidget {
  const KingdomTopBar({
    super.key,
    required this.stars,
    required this.streakDays,
    required this.onBack,
    required this.onFindMe,
    required this.onResetView,
  });

  final int stars;
  final int streakDays;
  final VoidCallback onBack;
  final VoidCallback onFindMe;
  final VoidCallback onResetView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KingdomCircleActionButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.outline),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 320;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('kingdom.title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h2.copyWith(
                        fontSize: compact ? 22 : 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('kingdom.subtitle'),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        KingdomInfoPill(
                          icon: Icons.star_rounded,
                          label: context.plural(
                            'common.stars',
                            stars,
                            namedArgs: {'count': '$stars'},
                          ),
                          color: AppColors.premiumGold,
                        ),
                        KingdomInfoPill(
                          icon: Icons.local_fire_department_rounded,
                          label: context.tr(
                            'parent_dashboard.streak_label',
                            namedArgs: {
                              'count': '${math.max(streakDays, 0)}',
                            },
                          ),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            KingdomCircleActionButton(
              icon: Icons.my_location_rounded,
              onTap: onFindMe,
            ),
            const SizedBox(height: 8),
            KingdomCircleActionButton(
              icon: Icons.center_focus_strong_rounded,
              onTap: onResetView,
            ),
          ],
        ),
      ],
    );
  }
}
