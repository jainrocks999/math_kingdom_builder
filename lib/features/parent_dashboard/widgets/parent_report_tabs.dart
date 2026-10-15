import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/performance_service.dart';
import '../../../core/services/reward_progress_service.dart';
import '../../kingdom/journey_activity_data.dart';
import '../parent_insights.dart';

const Color parentInk = Color(0xFF1E1060);
const Color parentMuted = Color(0xFF5A6B7A);

/// Colour for an average number of tries: green → amber → red.
Color triesColor(double averageTries) {
  if (averageTries < 1.5) return const Color(0xFF3FA65A);
  if (averageTries < 2.5) return const Color(0xFFE0A100);
  return const Color(0xFFE5554A);
}

String formatMinutes(BuildContext context, int seconds) {
  final minutes = (seconds / 60).round();
  if (minutes < 60) {
    return context.tr(
      'parent_dashboard.minutes_short',
      namedArgs: {'count': '$minutes'},
    );
  }
  return context.tr(
    'parent_dashboard.hours_short',
    namedArgs: {'hours': '${minutes ~/ 60}', 'minutes': '${minutes % 60}'},
  );
}

String masteryLabel(BuildContext context, MasteryLevel level) =>
    context.tr('parent_dashboard.mastery.${level.name}');

Color masteryColor(MasteryLevel level) => switch (level) {
      MasteryLevel.notStarted => AppColors.disabled,
      MasteryLevel.exploring => AppColors.info,
      MasteryLevel.practicing => AppColors.warning,
      MasteryLevel.confident => const Color(0xFF3FA65A),
    };

class ParentCard extends StatelessWidget {
  const ParentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1E1060),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      // ListTiles inside need a Material to paint ink on.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class ParentSectionTitle extends StatelessWidget {
  const ParentSectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3.copyWith(color: parentInk)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(color: parentMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: parentInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// How a single round went, e.g. "First try", "3 tries", "Skipped".
String roundResultLabel(BuildContext context, PerformanceRound round) {
  if (!round.solved) return context.tr('parent_dashboard.result.skipped');
  if (round.helped) return context.tr('parent_dashboard.result.helped');
  if (round.mistakes == 0) {
    return context.tr('parent_dashboard.result.first_try');
  }
  return context.tr(
    'parent_dashboard.result.tries',
    namedArgs: {'count': '${round.tries}'},
  );
}

Color roundResultColor(PerformanceRound round) {
  if (!round.solved) return const Color(0xFFE5554A);
  if (round.helped) return AppColors.warning;
  return triesColor(round.tries.toDouble());
}

// ---------------------------------------------------------------------------
// Overview
// ---------------------------------------------------------------------------

class ParentOverviewTab extends StatelessWidget {
  const ParentOverviewTab({
    super.key,
    required this.childName,
    required this.progress,
    required this.report,
    required this.usageSecondsPerDay,
    required this.limitMinutes,
    required this.onOpenReports,
  });

  final String childName;
  final RewardProgressSnapshot progress;
  final PerformanceReport report;

  /// Oldest first, today last.
  final List<int> usageSecondsPerDay;
  final int limitMinutes;
  final VoidCallback onOpenReports;

  @override
  Widget build(BuildContext context) {
    final roundsPerDay = report.roundsPerDay();
    final weekRounds = roundsPerDay.fold<int>(0, (a, b) => a + b);
    final weekSeconds = usageSecondsPerDay.fold<int>(0, (a, b) => a + b);
    final todaySeconds = usageSecondsPerDay.last;
    final weekRoundsList = report.rounds
        .where((r) => DateTime.now().difference(r.at).inDays < 7)
        .toList();
    final weekAccuracy = weekRoundsList.isEmpty
        ? null
        : weekRoundsList.where((r) => r.firstTry).length /
            weekRoundsList.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _TodayCard(
          childName: childName,
          todaySeconds: todaySeconds,
          limitMinutes: limitMinutes,
          todayCompletions: progress.todayCompletions,
        ),
        const SizedBox(height: 12),
        _StatGrid(
          stats: [
            (
              '⭐',
              '${progress.totalStars}',
              context.tr('parent_dashboard.stat.stars'),
            ),
            (
              '🔥',
              '${progress.streakDays}',
              context.tr('parent_dashboard.stat.streak'),
            ),
            (
              '🎮',
              '$weekRounds',
              context.tr('parent_dashboard.stat.rounds_week'),
            ),
            (
              '🎯',
              weekAccuracy == null ? '–' : '${(weekAccuracy * 100).round()}%',
              context.tr('parent_dashboard.stat.first_try'),
            ),
          ],
        ),
        ParentSectionTitle(
          context.tr('parent_dashboard.week_title'),
          subtitle: context.tr(
            'parent_dashboard.week_subtitle',
            namedArgs: {'time': formatMinutes(context, weekSeconds)},
          ),
        ),
        ParentCard(
          child: _WeekChart(
            secondsPerDay: usageSecondsPerDay,
            roundsPerDay: roundsPerDay,
          ),
        ),
        ParentSectionTitle(context.tr('parent_dashboard.highlights_title')),
        _HighlightsCard(report: report, onOpenReports: onOpenReports),
        ParentSectionTitle(
          context.tr('parent_dashboard.recent_title'),
          subtitle: context.tr('parent_dashboard.recent_subtitle'),
        ),
        _RecentRounds(rounds: report.rounds.take(10).toList()),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({
    required this.childName,
    required this.todaySeconds,
    required this.limitMinutes,
    required this.todayCompletions,
  });

  final String childName;
  final int todaySeconds;
  final int limitMinutes;
  final int todayCompletions;

  @override
  Widget build(BuildContext context) {
    final hasLimit = limitMinutes > 0;
    final fraction =
        hasLimit ? (todaySeconds / (limitMinutes * 60)).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C7AEA), Color(0xFF7E62E0)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              'parent_dashboard.child_progress',
              namedArgs: {'name': childName},
            ),
            style: AppTypography.h3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMinutes(context, todaySeconds),
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasLimit
                      ? context.tr(
                          'parent_dashboard.today_of_limit',
                          namedArgs: {'limit': '$limitMinutes'},
                        )
                      : context.tr('parent_dashboard.today_played'),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          if (hasLimit) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                color: fraction >= 1 ? AppColors.accent : Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${context.plural('common.adventures', todayCompletions)} '
            '${context.tr('common.today')}',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<(String, String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        const spacing = 10.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (emoji, value, label) in stats)
              SizedBox(
                width: width,
                child: ParentCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value,
                              style: AppTypography.h3.copyWith(
                                color: parentInk,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: parentMuted,
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
        );
      },
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.secondsPerDay, required this.roundsPerDay});

  final List<int> secondsPerDay;
  final List<int> roundsPerDay;

  @override
  Widget build(BuildContext context) {
    final maxSeconds = math.max(60, secondsPerDay.reduce(math.max));
    final today = DateTime.now();
    final locale = context.locale.toString();
    const barAreaHeight = 110.0;

    return Column(
      children: [
        SizedBox(
          height: barAreaHeight + 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < secondsPerDay.length; i++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${(secondsPerDay[i] / 60).round()}',
                        style: AppTypography.caption.copyWith(
                          color: parentMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 22,
                        height: math.max(
                          4,
                          barAreaHeight * secondsPerDay[i] / maxSeconds,
                        ),
                        decoration: BoxDecoration(
                          color: i == secondsPerDay.length - 1
                              ? AppColors.parentAccent
                              : AppColors.parentAccent.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat.E(locale).format(
                          today.subtract(
                            Duration(days: secondsPerDay.length - 1 - i),
                          ),
                        ),
                        style: AppTypography.caption.copyWith(
                          color: parentInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('parent_dashboard.week_chart_caption'),
          style: AppTypography.caption.copyWith(color: parentMuted),
        ),
      ],
    );
  }
}

class _HighlightsCard extends StatelessWidget {
  const _HighlightsCard({required this.report, required this.onOpenReports});

  final PerformanceReport report;
  final VoidCallback onOpenReports;

  @override
  Widget build(BuildContext context) {
    final strengths = report.modules.values
        .where((m) => m.rounds >= 3 && m.accuracy >= 0.75)
        .toList()
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));

    final needsPractice = <(String, ItemPerformance)>[
      for (final module in report.modules.values)
        for (final item in module.trickyItems) (module.moduleId, item),
    ]..sort((a, b) => b.$2.averageTries.compareTo(a.$2.averageTries));

    if (report.isEmpty) {
      return ParentCard(
        child: Text(
          context.tr('parent_dashboard.no_data'),
          style: AppTypography.body.copyWith(color: parentMuted),
        ),
      );
    }

    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💪 ${context.tr('parent_dashboard.strengths')}',
            style: AppTypography.bodyStrong.copyWith(color: parentInk),
          ),
          const SizedBox(height: 8),
          if (strengths.isEmpty)
            Text(
              context.tr('parent_dashboard.strengths_empty'),
              style: AppTypography.bodySmall.copyWith(color: parentMuted),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final module in strengths.take(4))
                  _MiniChip(
                    label:
                        '${activityFor(module.moduleId)?.emoji ?? ''} ${moduleTitle(context, module.moduleId)} · ${(module.accuracy * 100).round()}%',
                    color: const Color(0xFF3FA65A),
                  ),
              ],
            ),
          const Divider(height: 26),
          Text(
            '🧩 ${context.tr('parent_dashboard.needs_practice')}',
            style: AppTypography.bodyStrong.copyWith(color: parentInk),
          ),
          const SizedBox(height: 8),
          if (needsPractice.isEmpty)
            Text(
              context.tr('parent_dashboard.needs_practice_empty'),
              style: AppTypography.bodySmall.copyWith(color: parentMuted),
            )
          else
            for (final (moduleId, item) in needsPractice.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      activityFor(moduleId)?.emoji ?? '•',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${moduleTitle(context, moduleId)}: ${itemLabel(context, moduleId, item.item)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: parentInk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _MiniChip(
                      label: context.tr(
                        'parent_dashboard.avg_tries',
                        namedArgs: {
                          'count': item.averageTries.toStringAsFixed(1),
                        },
                      ),
                      color: triesColor(item.averageTries),
                    ),
                  ],
                ),
              ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onOpenReports,
              child: Text(
                context.tr('parent_dashboard.see_full_report'),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.parentAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRounds extends StatelessWidget {
  const _RecentRounds({required this.rounds});

  final List<PerformanceRound> rounds;

  @override
  Widget build(BuildContext context) {
    if (rounds.isEmpty) {
      return ParentCard(
        child: Text(
          context.tr('parent_dashboard.no_data'),
          style: AppTypography.body.copyWith(color: parentMuted),
        ),
      );
    }
    final timeFormat = DateFormat.MMMd(context.locale.toString()).add_jm();

    return ParentCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < rounds.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(
                    activityFor(rounds[i].moduleId)?.emoji ?? '•',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${moduleTitle(context, rounds[i].moduleId)}: ${itemLabel(context, rounds[i].moduleId, rounds[i].item)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: parentInk,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          timeFormat.format(rounds[i].at),
                          style: AppTypography.caption.copyWith(
                            color: parentMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MiniChip(
                    label: roundResultLabel(context, rounds[i]),
                    color: roundResultColor(rounds[i]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

class ParentReportsTab extends StatelessWidget {
  const ParentReportsTab({
    super.key,
    required this.progress,
    required this.report,
    required this.onPractice,
  });

  final RewardProgressSnapshot progress;
  final PerformanceReport report;
  final ValueChanged<String> onPractice;

  @override
  Widget build(BuildContext context) {
    // Most played first; untouched activities at the bottom.
    final activities = [...journeyActivities]..sort((a, b) {
        final ra = report.module(a.moduleId)?.rounds ??
            progress.completionCountFor(a.moduleId);
        final rb = report.module(b.moduleId)?.rounds ??
            progress.completionCountFor(b.moduleId);
        final byRounds = rb.compareTo(ra);
        return byRounds != 0
            ? byRounds
            : journeyActivities.indexOf(a).compareTo(
                  journeyActivities.indexOf(b),
                );
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 12),
          child: Text(
            context.tr('parent_dashboard.report.intro'),
            style: AppTypography.bodySmall.copyWith(color: parentMuted),
          ),
        ),
        const _TriesLegend(),
        const SizedBox(height: 12),
        for (final activity in activities)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ModuleReportCard(
              activity: activity,
              module: report.module(activity.moduleId),
              completions: progress.completionCountFor(activity.moduleId),
              onPractice: () => onPractice(activity.moduleId),
            ),
          ),
      ],
    );
  }
}

class _TriesLegend extends StatelessWidget {
  const _TriesLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _MiniChip(
          label: context.tr('parent_dashboard.legend.easy'),
          color: triesColor(1),
        ),
        _MiniChip(
          label: context.tr('parent_dashboard.legend.some_help'),
          color: triesColor(2),
        ),
        _MiniChip(
          label: context.tr('parent_dashboard.legend.tricky'),
          color: triesColor(3),
        ),
      ],
    );
  }
}

class _ModuleReportCard extends StatelessWidget {
  const _ModuleReportCard({
    required this.activity,
    required this.module,
    required this.completions,
    required this.onPractice,
  });

  final JourneyActivity activity;
  final ModulePerformance? module;
  final int completions;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final module = this.module;
    final mastery = masteryFor(module, completions);
    final hasRounds = module != null && module.rounds > 0;
    final viewOnly = activity.moduleId == RewardModuleIds.learnNumbers;

    final summary = hasRounds
        ? context.tr(
            'parent_dashboard.report.summary',
            namedArgs: {
              'rounds': '${module.rounds}',
              'percent': '${(module.accuracy * 100).round()}',
              'tries': module.averageTries.toStringAsFixed(1),
            },
          )
        : completions > 0
            ? context.tr(
                viewOnly
                    ? 'parent_dashboard.report.viewed'
                    : 'parent_dashboard.report.sessions_only',
                namedArgs: {'count': '$completions'},
              )
            : context.tr('parent_dashboard.report.not_started');

    return ParentCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          enabled: hasRounds,
          tilePadding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(activity.emoji, style: const TextStyle(fontSize: 22)),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  moduleTitle(context, activity.moduleId),
                  style: AppTypography.bodyStrong.copyWith(color: parentInk),
                ),
              ),
              _MiniChip(
                label: masteryLabel(context, mastery),
                color: masteryColor(mastery),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              summary,
              style: AppTypography.caption.copyWith(color: parentMuted),
            ),
          ),
          trailing: hasRounds ? null : const SizedBox.shrink(),
          children: [
            if (hasRounds) ...[
              _ModuleStatsRow(module: module),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr('parent_dashboard.report.items_title'),
                  style: AppTypography.bodySmall.copyWith(
                    color: parentInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in module.itemsByDifficulty)
                    _ItemChip(moduleId: activity.moduleId, item: item),
                ],
              ),
              const SizedBox(height: 12),
              for (final item in module.trickyItems.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${context.tr('parent_dashboard.report.tricky_line', namedArgs: {
                          'item':
                              itemLabel(context, activity.moduleId, item.item),
                          'rounds': '${item.rounds}',
                          'tries': item.averageTries.toStringAsFixed(1),
                          'worst': '${item.worstTries}',
                        })}',
                    style: AppTypography.bodySmall.copyWith(color: parentInk),
                  ),
                ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onPractice,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.parentAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon:
                      const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: Text(
                    context.tr('parent_dashboard.practice_now'),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleStatsRow extends StatelessWidget {
  const _ModuleStatsRow({required this.module});

  final ModulePerformance module;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('${module.rounds}', context.tr('parent_dashboard.report.rounds')),
      (
        '${(module.accuracy * 100).round()}%',
        context.tr('parent_dashboard.report.first_try'),
      ),
      (
        module.averageTries.toStringAsFixed(1),
        context.tr('parent_dashboard.report.avg_tries'),
      ),
      (
        formatMinutes(context, module.seconds),
        context.tr('parent_dashboard.report.time'),
      ),
    ];
    return Row(
      children: [
        for (final (value, label) in stats)
          Expanded(
            child: Column(
              children: [
                Text(
                  value,
                  style: AppTypography.bodyStrong.copyWith(color: parentInk),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: parentMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.moduleId, required this.item});

  final String moduleId;
  final ItemPerformance item;

  @override
  Widget build(BuildContext context) {
    final color = triesColor(item.averageTries);
    return Tooltip(
      message: context.tr(
        'parent_dashboard.report.tricky_line',
        namedArgs: {
          'item': itemLabel(context, moduleId, item.item),
          'rounds': '${item.rounds}',
          'tries': item.averageTries.toStringAsFixed(1),
          'worst': '${item.worstTries}',
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Text(
              itemLabel(context, moduleId, item.item),
              style: AppTypography.bodySmall.copyWith(
                color: parentInk,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '×${item.averageTries.toStringAsFixed(1)}',
              style: AppTypography.caption.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tips
// ---------------------------------------------------------------------------

class ParentTipsTab extends StatelessWidget {
  const ParentTipsTab({
    super.key,
    required this.tips,
    required this.onPractice,
  });

  final List<ParentTip> tips;
  final ValueChanged<String> onPractice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 12),
          child: Text(
            context.tr('parent_dashboard.tips_intro'),
            style: AppTypography.bodySmall.copyWith(color: parentMuted),
          ),
        ),
        for (final tip in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TipCard(
              tip: tip,
              onPractice:
                  tip.moduleId == null ? null : () => onPractice(tip.moduleId!),
            ),
          ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.onPractice});

  final ParentTip tip;
  final VoidCallback? onPractice;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tip.color.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: tip.color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip.title,
                            style: AppTypography.bodyStrong.copyWith(
                              color: parentInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tip.body,
                      style: AppTypography.bodySmall.copyWith(
                        color: parentInk,
                        height: 1.4,
                      ),
                    ),
                    if (onPractice != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: onPractice,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.parentAccent,
                            side: const BorderSide(
                              color: AppColors.parentAccent,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            context.tr('parent_dashboard.practice_now'),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.parentAccent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
