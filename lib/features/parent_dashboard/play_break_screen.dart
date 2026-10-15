import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/adaptive_hub_scaffold.dart';
import '../../shared/widgets/celebration_bear.dart';

enum PlayBreakReason { timeUp, activityOff }

/// Shown instead of a game when the parent's daily time is used up or the
/// activity was switched off in the Parent Zone.
class PlayBreakScreen extends StatelessWidget {
  const PlayBreakScreen({super.key, required this.reason});

  final PlayBreakReason reason;

  static PlayBreakReason reasonFromQuery(String? value) =>
      value == 'off' ? PlayBreakReason.activityOff : PlayBreakReason.timeUp;

  @override
  Widget build(BuildContext context) {
    final timeUp = reason == PlayBreakReason.timeUp;

    return AdaptiveHubScaffold(
      showBanner: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.outline, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CelebrationBear(size: 120),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(
                      timeUp
                          ? 'play_break.time_up_title'
                          : 'play_break.activity_off_title',
                    ),
                    textAlign: TextAlign.center,
                    style: AppTypography.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr(
                      timeUp
                          ? 'play_break.time_up_message'
                          : 'play_break.activity_off_message',
                    ),
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.home_rounded, color: Colors.white),
                      label: Text(
                        context.tr('play_break.go_home'),
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.parentDashboard),
                    icon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.parentAccent,
                    ),
                    label: Text(
                      context.tr('play_break.parent_unlock'),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.parentAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
