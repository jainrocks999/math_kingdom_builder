import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router/app_router.dart';
import 'reward_progress_service.dart';

/// Parent-set limits (daily play time, activities turned off) plus the play
/// time tracking they rely on.
///
/// Values are cached in memory so the router can check them synchronously.
class ParentControlsService {
  ParentControlsService._();

  static final ParentControlsService instance = ParentControlsService._();

  static const _dailyLimitKey = 'parent_controls_daily_limit_minutes';
  static const _disabledModulesKey = 'parent_controls_disabled_modules';
  static const _bonusMinutesKey = 'parent_controls_bonus_minutes';
  static const _bonusDateKey = 'parent_controls_bonus_date';
  static const _usageKey = 'parent_controls_daily_usage_seconds';

  static const dailyLimitOptions = [0, 15, 30, 45, 60, 90];

  /// Activity routes a parent can switch off, keyed by module id.
  static const Map<String, String> moduleRoutes = {
    RewardModuleIds.learnNumbers: AppRoutes.learnNumbers,
    RewardModuleIds.findNumber: AppRoutes.findNumber,
    RewardModuleIds.countObjects: AppRoutes.counting,
    RewardModuleIds.traceNumbers: AppRoutes.tracing,
    RewardModuleIds.matchNumbers: AppRoutes.matching,
    RewardModuleIds.miniQuiz: AppRoutes.miniQuiz,
    RewardModuleIds.addition: AppRoutes.addition,
    RewardModuleIds.subtraction: AppRoutes.subtraction,
    RewardModuleIds.multiplication: AppRoutes.multiplication,
    RewardModuleIds.division: AppRoutes.division,
    RewardModuleIds.sequencing: AppRoutes.sequencing,
    RewardModuleIds.patterns: AppRoutes.patterns,
  };

  /// Every screen where the child is playing. Blocked once time is up.
  static final Set<String> playRoutes = {
    ...moduleRoutes.values,
    AppRoutes.mathOperations,
    AppRoutes.numberRecognition,
  };

  int _dailyLimitMinutes = 0;
  Set<String> _disabledModules = <String>{};
  int _bonusMinutes = 0;
  String? _bonusDate;
  Map<String, int> _usage = <String, int>{};

  DateTime? _sessionStartedAt;
  Timer? _flushTimer;
  bool _loaded = false;

  /// Flips to true while today's time is used up. The app listens to send
  /// the child to the break screen mid-game.
  final ValueNotifier<bool> timeUp = ValueNotifier<bool>(false);

  int get dailyLimitMinutes => _dailyLimitMinutes;

  Set<String> get disabledModules => Set.unmodifiable(_disabledModules);

  int get bonusMinutesToday => _bonusDate == _todayKey ? _bonusMinutes : 0;

  int get effectiveLimitMinutes =>
      _dailyLimitMinutes == 0 ? 0 : _dailyLimitMinutes + bonusMinutesToday;

  /// Includes the session that is running right now.
  int get todaySeconds {
    final stored = _usage[_todayKey] ?? 0;
    final start = _sessionStartedAt;
    if (start == null) return stored;
    return stored + DateTime.now().difference(start).inSeconds;
  }

  bool get isTimeUp {
    final limit = effectiveLimitMinutes;
    return limit > 0 && todaySeconds >= limit * 60;
  }

  int get remainingSeconds {
    final limit = effectiveLimitMinutes;
    if (limit == 0) return -1;
    return (limit * 60 - todaySeconds).clamp(0, limit * 60);
  }

  bool isModuleEnabled(String moduleId) => !_disabledModules.contains(moduleId);

  /// The module a route belongs to, if it is a switchable activity.
  String? moduleForRoute(String route) {
    for (final entry in moduleRoutes.entries) {
      if (entry.value == route) return entry.key;
    }
    return null;
  }

  bool isRouteDisabled(String route) {
    final moduleId = moduleForRoute(route);
    return moduleId != null && !isModuleEnabled(moduleId);
  }

  /// Seconds played per day for the last [days] days, oldest first.
  List<int> usagePerDay({int days = 7}) {
    final today = DateTime.now();
    return [
      for (var i = days - 1; i >= 0; i--)
        i == 0
            ? todaySeconds
            : _usage[_dateKey(today.subtract(Duration(days: i)))] ?? 0,
    ];
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _dailyLimitMinutes = prefs.getInt(_dailyLimitKey) ?? 0;
    _disabledModules =
        prefs.getStringList(_disabledModulesKey)?.toSet() ?? <String>{};
    _bonusMinutes = prefs.getInt(_bonusMinutesKey) ?? 0;
    _bonusDate = prefs.getString(_bonusDateKey);
    _usage = _decodeUsage(prefs.getString(_usageKey));
    _loaded = true;
    _updateTimeUp();
  }

  /// Call when the app comes to the foreground.
  Future<void> startSession() async {
    await ensureLoaded();
    _sessionStartedAt ??= DateTime.now();
    _flushTimer?.cancel();
    // Flush regularly so time is kept even if the app is killed, and so the
    // limit is noticed while a game is open.
    _flushTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_flushSession(keepRunning: true));
    });
    _updateTimeUp();
  }

  /// Call when the app goes to the background.
  Future<void> stopSession() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    await _flushSession(keepRunning: false);
  }

  Future<void> _flushSession({required bool keepRunning}) async {
    final start = _sessionStartedAt;
    if (start == null) return;
    final now = DateTime.now();
    // Split across midnight so each day gets its own share.
    var cursor = start;
    while (_dateKey(cursor) != _dateKey(now)) {
      final nextMidnight = DateTime(cursor.year, cursor.month, cursor.day + 1);
      _addUsage(_dateKey(cursor), nextMidnight.difference(cursor).inSeconds);
      cursor = nextMidnight;
    }
    _addUsage(_dateKey(now), now.difference(cursor).inSeconds);
    _sessionStartedAt = keepRunning ? now : null;
    _pruneUsage();
    _updateTimeUp();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usageKey, jsonEncode(_usage));
  }

  void _addUsage(String key, int seconds) {
    if (seconds <= 0) return;
    _usage[key] = (_usage[key] ?? 0) + seconds;
  }

  void _pruneUsage() {
    final cutoff = _dateKey(DateTime.now().subtract(const Duration(days: 35)));
    _usage.removeWhere((key, _) => key.compareTo(cutoff) < 0);
  }

  Future<void> setDailyLimitMinutes(int minutes) async {
    await ensureLoaded();
    _dailyLimitMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyLimitKey, minutes);
    _updateTimeUp();
  }

  /// Gives extra minutes for today only.
  Future<void> addBonusMinutesToday(int minutes) async {
    await ensureLoaded();
    _bonusMinutes = bonusMinutesToday + minutes;
    _bonusDate = _todayKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bonusMinutesKey, _bonusMinutes);
    await prefs.setString(_bonusDateKey, _todayKey);
    _updateTimeUp();
  }

  Future<void> setModuleEnabled(String moduleId, bool enabled) async {
    await ensureLoaded();
    if (enabled) {
      _disabledModules.remove(moduleId);
    } else {
      _disabledModules.add(moduleId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _disabledModulesKey,
      _disabledModules.toList()..sort(),
    );
  }

  Future<void> resetTodayUsage() async {
    await ensureLoaded();
    _usage.remove(_todayKey);
    if (_sessionStartedAt != null) _sessionStartedAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usageKey, jsonEncode(_usage));
    _updateTimeUp();
  }

  void _updateTimeUp() {
    timeUp.value = isTimeUp;
  }

  Map<String, int> _decodeUsage(String? raw) {
    if (raw == null || raw.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return <String, int>{};
      return {
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is int)
            entry.key as String: entry.value as int,
      };
    } catch (_) {
      return <String, int>{};
    }
  }

  String get _todayKey => _dateKey(DateTime.now());

  static String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
