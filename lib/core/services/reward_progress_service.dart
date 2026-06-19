import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/kingdom/kingdom_service.dart';

class RewardProgressSnapshot {
  const RewardProgressSnapshot({
    required this.totalStars,
    required this.completionCounts,
    required this.claimedRewardIds,
    required this.todayCompletions,
    required this.streakDays,
  });

  final int totalStars;
  final Map<String, int> completionCounts;
  final Set<String> claimedRewardIds;
  final int todayCompletions;
  final int streakDays;

  int completionCountFor(String moduleId) => completionCounts[moduleId] ?? 0;
}

abstract final class RewardModuleIds {
  static const addition = 'addition';
  static const subtraction = 'subtraction';
  static const multiplication = 'multiplication';
  static const division = 'division';
  static const sequencing = 'sequencing';
  static const patterns = 'patterns';
  static const learnNumbers = 'learn_numbers';
  static const traceNumbers = 'trace_numbers';
  static const countObjects = 'count_objects';
  static const findNumber = 'find_correct_number';
  static const matchNumbers = 'match_numbers';
  static const miniQuiz = 'mini_quiz';
}

class RewardProgressService {
  RewardProgressService._();

  static final RewardProgressService instance = RewardProgressService._();

  static const _totalStarsKey = 'reward_progress_total_stars';
  static const _completionCountsKey = 'reward_progress_completion_counts';
  static const _claimedRewardsKey = 'reward_progress_claimed_rewards';
  static const _seenUnlockedModulesKey =
      'reward_progress_seen_unlocked_modules';
  static const _todayCompletionsKey = 'reward_progress_today_completions';
  static const _lastCompletionDateKey = 'reward_progress_last_completion_date';
  static const _streakDaysKey = 'reward_progress_streak_days';

  static const Map<String, int> _moduleStarRewards = {
    RewardModuleIds.addition: 4,
    RewardModuleIds.subtraction: 4,
    RewardModuleIds.multiplication: 4,
    RewardModuleIds.division: 4,
    RewardModuleIds.sequencing: 4,
    RewardModuleIds.patterns: 4,
    RewardModuleIds.learnNumbers: 4,
    RewardModuleIds.traceNumbers: 4,
    RewardModuleIds.countObjects: 3,
    RewardModuleIds.findNumber: 3,
    RewardModuleIds.matchNumbers: 3,
    RewardModuleIds.miniQuiz: 5,
  };

  int starsForModule(String moduleId) => _moduleStarRewards[moduleId] ?? 1;

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<RewardProgressSnapshot> loadSnapshot() async {
    final prefs = await _prefs;
    final totalStars = prefs.getInt(_totalStarsKey) ?? 0;
    final completionCounts = _decodeCompletionCounts(
      prefs.getString(_completionCountsKey),
    );
    final claimedRewardIds =
        prefs.getStringList(_claimedRewardsKey)?.toSet() ?? <String>{};
    final todayKey = _dateKey(DateTime.now());
    final lastCompletionDate = prefs.getString(_lastCompletionDateKey);
    final todayCompletions = lastCompletionDate == todayKey
        ? (prefs.getInt(_todayCompletionsKey) ?? 0)
        : 0;
    final streakDays = prefs.getInt(_streakDaysKey) ?? 0;

    return RewardProgressSnapshot(
      totalStars: totalStars,
      completionCounts: completionCounts,
      claimedRewardIds: claimedRewardIds,
      todayCompletions: todayCompletions,
      streakDays: streakDays,
    );
  }

  Future<void> recordModuleCompletion(String moduleId) async {
    final prefs = await _prefs;
    final completionCounts = _decodeCompletionCounts(
      prefs.getString(_completionCountsKey),
    );
    completionCounts[moduleId] = (completionCounts[moduleId] ?? 0) + 1;

    final currentStars = prefs.getInt(_totalStarsKey) ?? 0;
    final starsToAward = _moduleStarRewards[moduleId] ?? 1;
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final yesterdayKey = _dateKey(
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
    );
    final lastCompletionDate = prefs.getString(_lastCompletionDateKey);
    var todayCompletions = prefs.getInt(_todayCompletionsKey) ?? 0;
    var streakDays = prefs.getInt(_streakDaysKey) ?? 0;

    if (lastCompletionDate == todayKey) {
      todayCompletions += 1;
      if (streakDays == 0) streakDays = 1;
    } else {
      todayCompletions = 1;
      if (lastCompletionDate == yesterdayKey) {
        streakDays = streakDays > 0 ? streakDays + 1 : 2;
      } else {
        streakDays = 1;
      }
    }

    await prefs.setInt(_totalStarsKey, currentStars + starsToAward);
    await prefs.setString(
      _completionCountsKey,
      jsonEncode(completionCounts),
    );
    await prefs.setInt(_todayCompletionsKey, todayCompletions);
    await prefs.setString(_lastCompletionDateKey, todayKey);
    await prefs.setInt(_streakDaysKey, streakDays);
    await KingdomService.instance.syncFromProgressOnly();
  }

  Future<void> claimReward(String rewardId) async {
    final prefs = await _prefs;
    final claimed = prefs.getStringList(_claimedRewardsKey) ?? <String>[];
    if (claimed.contains(rewardId)) return;
    claimed.add(rewardId);
    await prefs.setStringList(_claimedRewardsKey, claimed);
  }

  Future<Set<String>?> loadSeenUnlockedModules() async {
    final prefs = await _prefs;
    final routes = prefs.getStringList(_seenUnlockedModulesKey);
    if (routes == null) return null;
    return routes.toSet();
  }

  Future<void> initializeSeenUnlockedModules(Set<String> moduleRoutes) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _seenUnlockedModulesKey,
      moduleRoutes.toList()..sort(),
    );
  }

  Future<void> markUnlockedModulesSeen(Set<String> moduleRoutes) async {
    final prefs = await _prefs;
    final existing =
        prefs.getStringList(_seenUnlockedModulesKey)?.toSet() ?? <String>{};
    existing.addAll(moduleRoutes);
    await prefs.setStringList(
      _seenUnlockedModulesKey,
      existing.toList()..sort(),
    );
  }

  Map<String, int> _decodeCompletionCounts(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return <String, int>{};

    final decoded = jsonDecode(rawValue);
    if (decoded is! Map<String, dynamic>) return <String, int>{};

    return decoded.map(
      (key, value) =>
          MapEntry(key, value is int ? value : int.tryParse('$value') ?? 0),
    );
  }

  String _dateKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
