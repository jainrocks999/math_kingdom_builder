import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/services/reward_progress_service.dart';
import '../../../data/models/reward_catalog.dart';
import '../journey_activity_data.dart';
import '../kingdom_zone_data.dart';
import 'journey_path.dart';

class JourneySectionHeader extends StatelessWidget {
  const JourneySectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.h3)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class JourneyStatsRow extends StatelessWidget {
  const JourneyStatsRow({
    super.key,
    required this.stars,
    required this.activities,
    required this.badgesUnlocked,
    required this.badgesTotal,
    required this.streakDays,
  });

  final int stars;
  final int activities;
  final int badgesUnlocked;
  final int badgesTotal;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData('⭐', '$stars', context.tr('kingdom.stat_stars'),
          AppColors.premiumGold),
      _StatData('✅', '$activities', context.tr('kingdom.stat_activities'),
          AppColors.gardenGreen),
      _StatData('🏅', '$badgesUnlocked/$badgesTotal',
          context.tr('kingdom.stat_badges'), AppColors.parentAccent),
      _StatData('🔥', '${math.max(streakDays, 0)}',
          context.tr('kingdom.stat_streak'), AppColors.primary),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 4 : 2;
        const spacing = 10.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(width: tileWidth, child: _StatTile(stat: stat)),
          ],
        );
      },
    );
  }
}

class _StatData {
  const _StatData(this.emoji, this.value, this.label, this.color);

  final String emoji;
  final String value;
  final String label;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});

  final _StatData stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stat.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(stat.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  style: AppTypography.h3.copyWith(height: 1.1),
                ),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mascot nudge towards the next best stop, with a one-tap play button.
class JourneyContinueCard extends StatelessWidget {
  const JourneyContinueCard({
    super.key,
    required this.recommendedZone,
    required this.journeyComplete,
    required this.todayCompletions,
    required this.onContinue,
  });

  final KingdomZoneData recommendedZone;
  final bool journeyComplete;
  final int todayCompletions;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final zone = recommendedZone;
    final message = journeyComplete
        ? context.tr('kingdom.journey_complete')
        : AppLocalization.kingdomZone(context, zone.id, 'hint');
    final todayLabel = context.tr(
      todayCompletions == 1
          ? 'kingdom.today_completed'
          : 'kingdom.today_completed_other',
      namedArgs: {'count': '$todayCompletions'},
    );

    return JourneyCard(
      color: zone.softColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(zone.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.kingdomZone(context, zone.id, 'title'),
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: zone.progressFraction,
              minHeight: 10,
              backgroundColor: Colors.white,
              color: zone.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '📅 $todayLabel',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                context.tr('kingdom.continue_journey'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JourneyBadgesStrip extends StatelessWidget {
  const JourneyBadgesStrip({
    super.key,
    required this.stars,
    required this.onOpenAlbum,
  });

  final int stars;
  final VoidCallback onOpenAlbum;

  @override
  Widget build(BuildContext context) {
    final rewards = [...rewardCatalog]
      ..sort((a, b) => a.unlockStars.compareTo(b.unlockStars));
    final nextReward = rewards.cast<RewardItem?>().firstWhere(
          (reward) => reward!.unlockStars > stars,
          orElse: () => null,
        );
    final previousThreshold = rewards
        .where((reward) => reward.unlockStars <= stars)
        .fold<int>(0, (best, reward) => math.max(best, reward.unlockStars));
    final nextProgress = nextReward == null
        ? 1.0
        : ((stars - previousThreshold) /
                math.max(1, nextReward.unlockStars - previousThreshold))
            .clamp(0.0, 1.0);

    return JourneyCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rewards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _BadgeTile(
                reward: rewards[index],
                unlocked: rewards[index].unlockStars <= stars,
                onTap: onOpenAlbum,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nextReward == null
                ? context.tr('kingdom.all_badges')
                : context.tr(
                    'kingdom.next_badge',
                    namedArgs: {
                      'count': '${nextReward.unlockStars - stars}',
                      'name': AppLocalization.rewardItem(
                        context,
                        nextReward.id,
                        'title',
                      ),
                    },
                  ),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: nextProgress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceMuted,
              color: AppColors.premiumGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.reward,
    required this.unlocked,
    required this.onTap,
  });

  final RewardItem reward;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: unlocked ? reward.softColor : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked
                ? reward.color.withValues(alpha: 0.6)
                : AppColors.outline,
            width: unlocked ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Opacity(
                  opacity: unlocked ? 1 : 0.3,
                  child: Text(
                    reward.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                if (!unlocked)
                  const Positioned(
                    right: -8,
                    bottom: -4,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalization.rewardItem(context, reward.id, 'title'),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color:
                    unlocked ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (!unlocked) ...[
              const Spacer(),
              Text(
                '⭐ ${reward.unlockStars}',
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Every activity with how many times it was played and stars earned.
/// Played activities come first, most played on top.
class JourneyActivityLog extends StatelessWidget {
  const JourneyActivityLog({
    super.key,
    required this.completionCounts,
    required this.onPlay,
  });

  final Map<String, int> completionCounts;
  final ValueChanged<JourneyActivity> onPlay;

  @override
  Widget build(BuildContext context) {
    final activities = [...journeyActivities];
    int countFor(JourneyActivity activity) =>
        completionCounts[activity.moduleId] ?? 0;
    // List.sort is not stable, so tie-break on the catalog order.
    activities.sort((a, b) {
      final byCount = countFor(b).compareTo(countFor(a));
      if (byCount != 0) return byCount;
      return journeyActivities.indexOf(a).compareTo(
            journeyActivities.indexOf(b),
          );
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640
            ? 3
            : constraints.maxWidth >= 300
                ? 2
                : 1;
        const spacing = 10.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final activity in activities)
              SizedBox(
                width: tileWidth,
                child: _ActivityTile(
                  activity: activity,
                  count: countFor(activity),
                  onTap: () => onPlay(activity),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.count,
    required this.onTap,
  });

  final JourneyActivity activity;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final played = count > 0;
    final stars = count *
        RewardProgressService.instance.starsForModule(activity.moduleId);

    return Material(
      color: Colors.white.withValues(alpha: played ? 0.96 : 0.75),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: played
                  ? activity.color.withValues(alpha: 0.5)
                  : AppColors.outline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: activity.color.withValues(alpha: played ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  activity.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('modules.${activity.moduleId}.title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      played
                          ? '${context.tr('kingdom.played_count', namedArgs: {
                                  'count': '$count'
                                })} · ${context.tr('kingdom.stars_earned', namedArgs: {
                                  'count': '$stars'
                                })}'
                          : context.tr('kingdom.not_played'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Icon(
                played
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_outline_rounded,
                color: played ? AppColors.gardenGreen : AppColors.disabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Details for one journey stop, with a play button when it is reachable.
Future<void> showJourneyStopSheet(
  BuildContext context, {
  required KingdomZoneData zone,
  required JourneyStopStatus status,
  required VoidCallback onPlay,
}) {
  final locked = status == JourneyStopStatus.locked;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: zone.color.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: locked ? AppColors.surfaceMuted : zone.softColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      locked ? '🔒' : zone.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalization.kingdomZone(
                            sheetContext,
                            zone.id,
                            'title',
                          ),
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          journeyStatusLabel(sheetContext, status),
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: zone.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                locked
                    ? sheetContext.tr('kingdom.unlock_grow_zones')
                    : AppLocalization.kingdomZone(
                        sheetContext,
                        zone.id,
                        zone.isComplete ? 'subtitle' : 'hint',
                      ),
                style: AppTypography.body,
              ),
              if (!locked) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: zone.progressFraction,
                    minHeight: 12,
                    backgroundColor: AppColors.surfaceMuted,
                    color: zone.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sheetContext.tr(
                    'kingdom.rewards_progress',
                    namedArgs: {
                      'progress': '${math.min(zone.progress, zone.goal)}',
                      'goal': '${zone.goal}',
                    },
                  ),
                  style: AppTypography.caption,
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: zone.softColor,
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: zone.color.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        sheetContext.tr('kingdom.close'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.button.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (!locked && zone.playable) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          onPlay();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          AppLocalization.kingdomZone(
                            sheetContext,
                            zone.id,
                            'cta',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
