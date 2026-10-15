import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

/// One finished round of an activity: which item was asked (a number, a sum,
/// a pattern type...) and how many wrong tries it took to solve it.
class PerformanceRound {
  const PerformanceRound({
    required this.moduleId,
    required this.item,
    required this.mistakes,
    required this.solved,
    required this.helped,
    required this.seconds,
    required this.at,
  });

  final String moduleId;
  final String item;
  final int mistakes;

  /// False when the game moved on before the child found the answer.
  final bool solved;

  /// True when the child used a "do it for me" helper button.
  final bool helped;
  final int seconds;
  final DateTime at;

  /// Total tries including the successful one.
  int get tries => mistakes + 1;

  bool get firstTry => solved && !helped && mistakes == 0;

  Map<String, dynamic> toJson() => {
        'm': moduleId,
        'i': item,
        'x': mistakes,
        's': solved,
        'h': helped,
        'd': seconds,
        't': at.millisecondsSinceEpoch,
      };

  static PerformanceRound? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final moduleId = raw['m'];
    final item = raw['i'];
    final at = raw['t'];
    if (moduleId is! String || item is! String || at is! int) return null;
    return PerformanceRound(
      moduleId: moduleId,
      item: item,
      mistakes: raw['x'] is int ? raw['x'] as int : 0,
      solved: raw['s'] != false,
      helped: raw['h'] == true,
      seconds: raw['d'] is int ? raw['d'] as int : 0,
      at: DateTime.fromMillisecondsSinceEpoch(at),
    );
  }
}

/// Aggregated results for one item (e.g. tracing the number 8).
class ItemPerformance {
  ItemPerformance(this.item);

  final String item;
  int rounds = 0;
  int mistakes = 0;
  int firstTry = 0;
  int unsolved = 0;
  int helped = 0;
  int worstTries = 0;
  DateTime? lastPlayed;

  double get averageTries => rounds == 0 ? 0 : (rounds + mistakes) / rounds;

  double get firstTryRate => rounds == 0 ? 0 : firstTry / rounds;

  /// Needs practice: usually takes more than one try, or was skipped/helped.
  bool get isTricky =>
      rounds > 0 && (averageTries >= 2 || unsolved > 0 || helped > 0);
}

/// Aggregated results for one activity.
class ModulePerformance {
  ModulePerformance(this.moduleId);

  final String moduleId;
  final Map<String, ItemPerformance> items = {};
  int rounds = 0;
  int mistakes = 0;
  int firstTry = 0;
  int seconds = 0;
  DateTime? lastPlayed;

  double get accuracy => rounds == 0 ? 0 : firstTry / rounds;

  double get averageTries => rounds == 0 ? 0 : (rounds + mistakes) / rounds;

  /// Trickiest items first.
  List<ItemPerformance> get trickyItems {
    final tricky = items.values.where((item) => item.isTricky).toList()
      ..sort((a, b) => b.averageTries.compareTo(a.averageTries));
    return tricky;
  }

  List<ItemPerformance> get itemsByDifficulty {
    final sorted = items.values.toList()
      ..sort((a, b) {
        final byTries = b.averageTries.compareTo(a.averageTries);
        return byTries != 0 ? byTries : a.item.compareTo(b.item);
      });
    return sorted;
  }
}

class PerformanceReport {
  const PerformanceReport({required this.rounds, required this.modules});

  /// Newest first.
  final List<PerformanceRound> rounds;
  final Map<String, ModulePerformance> modules;

  bool get isEmpty => rounds.isEmpty;

  ModulePerformance? module(String moduleId) => modules[moduleId];

  int get totalRounds => rounds.length;

  double get accuracy {
    if (rounds.isEmpty) return 0;
    return rounds.where((round) => round.firstTry).length / rounds.length;
  }

  /// Rounds per day for the last [days] days, oldest first.
  List<int> roundsPerDay({int days = 7, DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final counts = List<int>.filled(days, 0);
    for (final round in rounds) {
      final diff = today.difference(_day(round.at)).inDays;
      if (diff >= 0 && diff < days) counts[days - 1 - diff]++;
    }
    return counts;
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

/// Stores every finished round so parents can see how many tries each
/// number, sum or question took.
class PerformanceService {
  PerformanceService._();

  static final PerformanceService instance = PerformanceService._();

  static const _roundsKey = 'performance_rounds_v1';

  /// Enough history for weeks of play while keeping prefs small.
  static const _maxRounds = 1500;

  Future<void> _pending = Future<void>.value();

  Future<void> recordRound({
    required String moduleId,
    required String item,
    required int mistakes,
    bool solved = true,
    bool helped = false,
    Duration? timeTaken,
  }) {
    final round = PerformanceRound(
      moduleId: moduleId,
      item: item,
      mistakes: math.max(0, mistakes),
      solved: solved,
      helped: helped,
      seconds: math.min(timeTaken?.inSeconds ?? 0, 30 * 60),
      at: DateTime.now(),
    );
    // Serialize writes so quick consecutive rounds never overwrite each other.
    _pending = _pending.then((_) => _append(round)).catchError((_) {});
    return _pending;
  }

  Future<void> _append(PerformanceRound round) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_roundsKey) ?? <String>[];
    stored.add(jsonEncode(round.toJson()));
    final trimmed = stored.length > _maxRounds
        ? stored.sublist(stored.length - _maxRounds)
        : stored;
    await prefs.setStringList(_roundsKey, trimmed);
  }

  Future<PerformanceReport> loadReport() async {
    await _pending;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_roundsKey) ?? <String>[];
    final rounds = <PerformanceRound>[];
    for (final raw in stored) {
      try {
        final round = PerformanceRound.fromJson(jsonDecode(raw));
        if (round != null) rounds.add(round);
      } catch (_) {
        // Skip a corrupt entry rather than losing the whole report.
      }
    }
    rounds.sort((a, b) => b.at.compareTo(a.at));

    final modules = <String, ModulePerformance>{};
    for (final round in rounds) {
      final module = modules.putIfAbsent(
          round.moduleId, () => ModulePerformance(round.moduleId));
      module
        ..rounds += 1
        ..mistakes += round.mistakes
        ..firstTry += round.firstTry ? 1 : 0
        ..seconds += round.seconds;
      module.lastPlayed ??= round.at;

      final item = module.items
          .putIfAbsent(round.item, () => ItemPerformance(round.item));
      item
        ..rounds += 1
        ..mistakes += round.mistakes
        ..firstTry += round.firstTry ? 1 : 0
        ..unsolved += round.solved ? 0 : 1
        ..helped += round.helped ? 1 : 0
        ..worstTries = math.max(item.worstTries, round.tries);
      item.lastPlayed ??= round.at;
    }

    return PerformanceReport(rounds: rounds, modules: modules);
  }

  Future<void> clear() async {
    await _pending;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roundsKey);
  }
}

/// Per-screen helper: counts wrong tries for the current item and records the
/// round when it is finished.
class RoundAttemptTracker {
  RoundAttemptTracker(this.moduleId);

  final String moduleId;
  int _mistakes = 0;
  bool _helped = false;
  DateTime _startedAt = DateTime.now();

  int get mistakes => _mistakes;

  /// Call when a new item is shown.
  void start() {
    _mistakes = 0;
    _helped = false;
    _startedAt = DateTime.now();
  }

  void miss() => _mistakes++;

  void usedHelp() => _helped = true;

  /// Records the item and starts counting the next one.
  void finish(String item, {bool solved = true}) {
    PerformanceService.instance.recordRound(
      moduleId: moduleId,
      item: item,
      mistakes: _mistakes,
      solved: solved,
      helped: _helped,
      timeTaken: DateTime.now().difference(_startedAt),
    );
    start();
  }
}
