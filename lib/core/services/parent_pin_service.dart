import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ParentPinService {
  ParentPinService._();

  static final ParentPinService instance = ParentPinService._();

  static const _pinHashKey = 'parent_pin_hash';
  static const _failedAttemptsKey = 'parent_pin_failed_attempts';
  static const _cooldownUntilKey = 'parent_pin_cooldown_until_ms';

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinHashKey)?.isNotEmpty ?? false;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, _hashPin(pin));
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_cooldownUntilKey);
  }

  Future<bool> verifyPin(String pin) async {
    if (await isInCooldown()) return false;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pinHashKey);
    if (stored == null || stored.isEmpty) return false;

    final isValid = stored == _hashPin(pin);
    if (isValid) {
      await prefs.remove(_failedAttemptsKey);
      await prefs.remove(_cooldownUntilKey);
      return true;
    }

    final attempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_failedAttemptsKey, attempts);
    if (attempts >= 3) {
      await prefs.setInt(
        _cooldownUntilKey,
        DateTime.now().add(const Duration(seconds: 30)).millisecondsSinceEpoch,
      );
      await prefs.remove(_failedAttemptsKey);
    }
    return false;
  }

  Future<bool> isInCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final untilMs = prefs.getInt(_cooldownUntilKey);
    if (untilMs == null) return false;
    if (DateTime.now().millisecondsSinceEpoch >= untilMs) {
      await prefs.remove(_cooldownUntilKey);
      return false;
    }
    return true;
  }

  Future<int> cooldownSecondsRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final untilMs = prefs.getInt(_cooldownUntilKey);
    if (untilMs == null) return 0;
    final remainingMs =
        untilMs - DateTime.now().millisecondsSinceEpoch;
    return (remainingMs / 1000).ceil().clamp(0, 30);
  }

  String _hashPin(String pin) {
    return base64Url.encode(utf8.encode('mk_parent:$pin'));
  }
}
