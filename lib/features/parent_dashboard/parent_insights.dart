import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/services/performance_service.dart';
import '../../core/services/reward_progress_service.dart';
import '../kingdom/journey_activity_data.dart';

enum MasteryLevel { notStarted, exploring, practicing, confident }

/// Rounds needed before a module is judged; fewer is too little to say.
const int _minRoundsToJudge = 3;

JourneyActivity? activityFor(String moduleId) {
  for (final activity in journeyActivities) {
    if (activity.moduleId == moduleId) return activity;
  }
  return null;
}

String moduleTitle(BuildContext context, String moduleId) =>
    context.tr('modules.$moduleId.title');

/// Human label for a recorded item: "8", "3 + 4", "AB pattern",
/// "Write the number"...
String itemLabel(BuildContext context, String moduleId, String item) {
  switch (moduleId) {
    case RewardModuleIds.patterns:
      return context.tr(
        'parent_dashboard.report.pattern_item',
        namedArgs: {'kind': item},
      );
    case RewardModuleIds.miniQuiz:
      final key = 'parent_dashboard.quiz_modes.$item';
      final label = context.tr(key);
      return label == key ? item : label;
    default:
      return item;
  }
}

MasteryLevel masteryFor(ModulePerformance? module, int completions) {
  if (module == null || module.rounds == 0) {
    // Played before tries were recorded, or a view-only activity.
    if (completions >= 8) return MasteryLevel.confident;
    if (completions >= 3) return MasteryLevel.practicing;
    if (completions > 0) return MasteryLevel.exploring;
    return MasteryLevel.notStarted;
  }
  if (module.rounds < _minRoundsToJudge) return MasteryLevel.exploring;
  if (module.accuracy >= 0.75 && module.rounds >= 6) {
    return MasteryLevel.confident;
  }
  return MasteryLevel.practicing;
}

class ParentTip {
  const ParentTip({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
    this.moduleId,
    this.priority = 0,
  });

  final String emoji;
  final String title;
  final String body;
  final Color color;

  /// Activity the "Practice now" button opens, when there is one.
  final String? moduleId;

  /// Higher shows first.
  final int priority;
}

/// Rule-based suggestions built from what the child actually did.
List<ParentTip> buildParentTips(
  BuildContext context, {
  required PerformanceReport report,
  required RewardProgressSnapshot progress,
  required List<int> usageSecondsPerDay,
  required int dailyLimitMinutes,
  required String childName,
}) {
  final tips = <ParentTip>[];
  String tr(String key, [Map<String, String>? args]) =>
      context.tr('parent_dashboard.tips.$key', namedArgs: args);

  if (report.isEmpty && progress.completionCounts.isEmpty) {
    return [
      ParentTip(
        emoji: '👋',
        title: tr('start_title'),
        body: tr('start_body', {'name': childName}),
        color: const Color(0xFF5C7AEA),
        moduleId: RewardModuleIds.countObjects,
      ),
    ];
  }

  for (final module in report.modules.values) {
    final title = moduleTitle(context, module.moduleId);
    // Helper-only items are covered by the helper tip below.
    final tricky = module.trickyItems
        .where((item) => item.averageTries >= 2 || item.unsolved > 0)
        .toList();

    // 1. Specific items that took several tries.
    if (tricky.isNotEmpty) {
      final items = tricky
          .take(3)
          .map((item) => itemLabel(context, module.moduleId, item.item))
          .join(', ');
      final worst = tricky.first;
      tips.add(
        ParentTip(
          emoji: '🎯',
          title:
              tr('practice_items_title', {'items': items, 'activity': title}),
          body: '${tr('practice_items_body', {
                'name': childName,
                'items': items,
                'tries': worst.averageTries.toStringAsFixed(1),
              })} ${_activityHowTo(context, module.moduleId, items)}',
          color: const Color(0xFFE5734A),
          moduleId: module.moduleId,
          priority: 50 + (worst.averageTries * 10).round(),
        ),
      );
    }

    // 2. Leaning on the "do it for me" helper.
    final helpedRounds =
        module.items.values.fold<int>(0, (sum, item) => sum + item.helped);
    if (helpedRounds >= 2) {
      tips.add(
        ParentTip(
          emoji: '🤝',
          title: tr('helper_title', {'activity': title}),
          body:
              tr('helper_body', {'name': childName, 'count': '$helpedRounds'}),
          color: const Color(0xFFF4B942),
          moduleId: module.moduleId,
          priority: 40,
        ),
      );
    }

    // 3. Fast answers with many mistakes usually means guessing.
    if (_tapToAnswerModules.contains(module.moduleId) &&
        module.rounds >= _minRoundsToJudge &&
        module.averageTries >= 1.8 &&
        module.seconds / module.rounds < 6) {
      tips.add(
        ParentTip(
          emoji: '🐢',
          title: tr('slow_down_title', {'activity': title}),
          body: tr('slow_down_body', {'name': childName}),
          color: const Color(0xFF7BC6FF),
          moduleId: module.moduleId,
          priority: 35,
        ),
      );
    }

    // 4. Doing great: suggest the next step.
    if (module.rounds >= 6 && module.accuracy >= 0.8) {
      final next = _nextChallenge[module.moduleId];
      final nextPlayed = next != null && (report.module(next)?.rounds ?? 0) > 0;
      tips.add(
        ParentTip(
          emoji: '🚀',
          title: tr('ready_next_title', {'activity': title}),
          body: next != null && !nextPlayed
              ? tr('ready_next_body', {
                  'name': childName,
                  'percent': '${(module.accuracy * 100).round()}',
                  'next': moduleTitle(context, next),
                })
              : tr('ready_praise_body', {
                  'name': childName,
                  'percent': '${(module.accuracy * 100).round()}',
                }),
          color: const Color(0xFF6BCB77),
          moduleId: next != null && !nextPlayed ? next : null,
          priority: 20,
        ),
      );
    }
  }

  // 5. Activities never tried (skip view-only Learn Numbers).
  final untried = journeyActivities
      .where(
        (activity) =>
            activity.moduleId != RewardModuleIds.learnNumbers &&
            (report.module(activity.moduleId)?.rounds ?? 0) == 0 &&
            progress.completionCountFor(activity.moduleId) == 0,
      )
      .take(2);
  for (final activity in untried) {
    tips.add(
      ParentTip(
        emoji: activity.emoji,
        title: tr('try_new_title', {
          'activity': moduleTitle(context, activity.moduleId),
        }),
        body: tr('try_new_body', {'name': childName}),
        color: activity.color,
        moduleId: activity.moduleId,
        priority: 10,
      ),
    );
  }

  // 6. Routine: gaps in play, or long sessions without a limit.
  final daysPlayed = usageSecondsPerDay.where((s) => s >= 60).length;
  if (daysPlayed <= 2) {
    tips.add(
      ParentTip(
        emoji: '📅',
        title: tr('routine_title'),
        body: tr('routine_body', {'name': childName}),
        color: const Color(0xFFCDB4FF),
        priority: 15,
      ),
    );
  }
  final activeDays = usageSecondsPerDay.where((s) => s > 0).toList();
  final averageMinutes = activeDays.isEmpty
      ? 0
      : activeDays.reduce((a, b) => a + b) ~/ activeDays.length ~/ 60;
  if (dailyLimitMinutes == 0 && averageMinutes >= 40) {
    tips.add(
      ParentTip(
        emoji: '⏰',
        title: tr('limit_title'),
        body: tr('limit_body', {'minutes': '$averageMinutes'}),
        color: const Color(0xFF5C7AEA),
        priority: 30,
      ),
    );
  }

  tips.sort((a, b) => b.priority.compareTo(a.priority));
  return tips;
}

/// Games where a quick wrong tap suggests guessing. Tracing and the
/// drag-based math games are left out: speed there is not guessing.
const Set<String> _tapToAnswerModules = {
  RewardModuleIds.findNumber,
  RewardModuleIds.countObjects,
  RewardModuleIds.matchNumbers,
  RewardModuleIds.miniQuiz,
  RewardModuleIds.sequencing,
  RewardModuleIds.patterns,
};

/// A natural next activity once one is mastered.
const Map<String, String> _nextChallenge = {
  RewardModuleIds.findNumber: RewardModuleIds.traceNumbers,
  RewardModuleIds.traceNumbers: RewardModuleIds.countObjects,
  RewardModuleIds.countObjects: RewardModuleIds.matchNumbers,
  RewardModuleIds.matchNumbers: RewardModuleIds.addition,
  RewardModuleIds.addition: RewardModuleIds.subtraction,
  RewardModuleIds.subtraction: RewardModuleIds.multiplication,
  RewardModuleIds.multiplication: RewardModuleIds.division,
  RewardModuleIds.sequencing: RewardModuleIds.patterns,
  RewardModuleIds.patterns: RewardModuleIds.miniQuiz,
};

/// Offline, hands-on practice ideas per activity.
String _activityHowTo(BuildContext context, String moduleId, String items) {
  final key = switch (moduleId) {
    RewardModuleIds.traceNumbers => 'howto_trace',
    RewardModuleIds.findNumber => 'howto_find',
    RewardModuleIds.countObjects ||
    RewardModuleIds.matchNumbers =>
      'howto_count',
    RewardModuleIds.addition ||
    RewardModuleIds.subtraction ||
    RewardModuleIds.multiplication ||
    RewardModuleIds.division =>
      'howto_math',
    RewardModuleIds.sequencing => 'howto_sequence',
    RewardModuleIds.patterns => 'howto_pattern',
    _ => 'howto_general',
  };
  return context.tr(
    'parent_dashboard.tips.$key',
    namedArgs: {'items': items},
  );
}
