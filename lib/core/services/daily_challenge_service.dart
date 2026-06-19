import 'package:shared_preferences/shared_preferences.dart';

import '../router/app_router.dart';
import 'reward_progress_service.dart';

class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.moduleId,
    required this.route,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  final String id;
  final String moduleId;
  final String route;
  final String title;
  final String subtitle;
  final String emoji;
}

class DailyChallengeSnapshot {
  const DailyChallengeSnapshot({
    required this.challenge,
    required this.dateKey,
    required this.baselineCompletionCount,
    required this.currentCompletionCount,
    required this.isRewardClaimed,
    required this.rewardGrantedNow,
    required this.bonusStars,
  });

  final DailyChallenge challenge;
  final String dateKey;
  final int baselineCompletionCount;
  final int currentCompletionCount;
  final bool isRewardClaimed;
  final bool rewardGrantedNow;
  final int bonusStars;

  bool get isCompleted => currentCompletionCount > baselineCompletionCount;
}

class DailyChallengeService {
  DailyChallengeService._();

  static final DailyChallengeService instance = DailyChallengeService._();

  static const _baselinePrefix = 'daily_challenge_baseline';
  static const _rewardClaimPrefix = 'daily_challenge_reward_claimed';
  static const _bonusStars = 2;

  static const List<DailyChallenge> _challenges = [
    DailyChallenge(
      id: 'learn_numbers',
      moduleId: RewardModuleIds.learnNumbers,
      route: AppRoutes.learnNumbers,
      title: 'Learn Numbers',
      subtitle: 'Wake up the number bear and hear today\'s counting words.',
      emoji: '🔢',
    ),
    DailyChallenge(
      id: 'count_objects',
      moduleId: RewardModuleIds.countObjects,
      route: AppRoutes.counting,
      title: 'Count Objects',
      subtitle: 'Count the picture friends and tap the right answer.',
      emoji: '🍎',
    ),
    DailyChallenge(
      id: 'find_number',
      moduleId: RewardModuleIds.findNumber,
      route: AppRoutes.findNumber,
      title: 'Find Correct Number',
      subtitle: 'Listen carefully and pick the magical number you hear.',
      emoji: '🎯',
    ),
    DailyChallenge(
      id: 'match_numbers',
      moduleId: RewardModuleIds.matchNumbers,
      route: AppRoutes.matching,
      title: 'Match Numbers',
      subtitle: 'Match the number to the right object group.',
      emoji: '🃏',
    ),
    DailyChallenge(
      id: 'mini_quiz',
      moduleId: RewardModuleIds.miniQuiz,
      route: AppRoutes.miniQuiz,
      title: 'Mini Quiz',
      subtitle: 'Take on a mixed brain challenge and keep your streak glowing.',
      emoji: '🧠',
    ),
    DailyChallenge(
      id: 'addition',
      moduleId: RewardModuleIds.addition,
      route: AppRoutes.addition,
      title: 'Addition',
      subtitle: 'Combine two groups and fill the bowl with the answer.',
      emoji: '➕',
    ),
    DailyChallenge(
      id: 'sequencing',
      moduleId: RewardModuleIds.sequencing,
      route: AppRoutes.sequencing,
      title: 'Sequencing',
      subtitle: 'Complete today\'s missing number trail in the right order.',
      emoji: '🪜',
    ),
    DailyChallenge(
      id: 'patterns',
      moduleId: RewardModuleIds.patterns,
      route: AppRoutes.patterns,
      title: 'Patterns',
      subtitle: 'Spot the repeating shape pattern and finish it.',
      emoji: '🔷',
    ),
  ];

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<DailyChallengeSnapshot> loadSnapshot({
    RewardProgressSnapshot? progressSnapshot,
  }) async {
    final progress =
        progressSnapshot ?? await RewardProgressService.instance.loadSnapshot();
    final today = DateTime.now();
    final dateKey = _dateKey(today);
    final challenge = _challengeForDate(today);
    final baselineKey = _baselineStorageKey(dateKey, challenge.id);
    final rewardClaimKey = _rewardClaimStorageKey(dateKey, challenge.id);
    final prefs = await _prefs;

    var baseline = prefs.getInt(baselineKey);
    baseline ??= progress.completionCountFor(challenge.moduleId);
    await prefs.setInt(baselineKey, baseline);

    final currentCompletionCount =
        progress.completionCountFor(challenge.moduleId);
    final isCompleted = currentCompletionCount > baseline;
    var isRewardClaimed = prefs.getBool(rewardClaimKey) ?? false;
    var rewardGrantedNow = false;

    if (isCompleted && !isRewardClaimed) {
      await prefs.setBool(rewardClaimKey, true);
      try {
        await RewardProgressService.instance.awardBonusStars(_bonusStars);
        isRewardClaimed = true;
        rewardGrantedNow = true;
      } catch (_) {
        await prefs.remove(rewardClaimKey);
        rethrow;
      }
    }

    return DailyChallengeSnapshot(
      challenge: challenge,
      dateKey: dateKey,
      baselineCompletionCount: baseline,
      currentCompletionCount: currentCompletionCount,
      isRewardClaimed: isRewardClaimed,
      rewardGrantedNow: rewardGrantedNow,
      bonusStars: _bonusStars,
    );
  }

  DailyChallenge _challengeForDate(DateTime date) {
    final bucket = DateTime(date.year, date.month, date.day)
        .difference(DateTime(2026, 1, 1))
        .inDays;
    final index = bucket % _challenges.length;
    return _challenges[index < 0 ? index + _challenges.length : index];
  }

  String _baselineStorageKey(String dateKey, String challengeId) {
    return '$_baselinePrefix:$dateKey:$challengeId';
  }

  String _rewardClaimStorageKey(String dateKey, String challengeId) {
    return '$_rewardClaimPrefix:$dateKey:$challengeId';
  }

  String _dateKey(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
