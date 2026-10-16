import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/child_profile.dart';

class ChildProfileSnapshot {
  const ChildProfileSnapshot({
    required this.profiles,
    required this.activeIndex,
  });

  final List<ChildProfile> profiles;

  /// -1 when there are no profiles yet.
  final int activeIndex;

  bool get isEmpty => profiles.isEmpty;

  ChildProfile? get activeProfile =>
      profiles.isEmpty ? null : profiles[activeIndex];
}

class ChildProfileService {
  ChildProfileService._();

  static final ChildProfileService instance = ChildProfileService._();

  static const _activeProfileIndexKey = 'active_child_profile_index';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Box<ChildProfile> get _profilesBox => Hive.box<ChildProfile>('profiles');

  /// True once at least one child profile exists. The app asks for one
  /// before it can be used.
  bool get hasProfiles => _profilesBox.isNotEmpty;

  Future<ChildProfileSnapshot> loadSnapshot() async {
    final prefs = await _prefs;
    final profiles = _profilesBox.values.toList(growable: false);
    final activeIndex = prefs.getInt(_activeProfileIndexKey) ?? 0;
    final safeIndex =
        profiles.isEmpty ? -1 : activeIndex.clamp(0, profiles.length - 1);

    return ChildProfileSnapshot(
      profiles: profiles,
      activeIndex: safeIndex,
    );
  }

  Future<void> setActiveProfileIndex(int index) async {
    final profiles = _profilesBox.values.toList(growable: false);
    if (profiles.isEmpty) return;
    final safeIndex = index.clamp(0, profiles.length - 1);
    final prefs = await _prefs;
    await prefs.setInt(_activeProfileIndexKey, safeIndex);
  }

  Future<void> addProfile(ChildProfile profile, {bool makeActive = true}) async {
    await _profilesBox.add(profile);
    if (makeActive) {
      await setActiveProfileIndex(_profilesBox.length - 1);
    }
  }

  Future<void> updateProfile(int index, ChildProfile profile) async {
    if (index < 0 || index >= _profilesBox.length) return;
    await _profilesBox.putAt(index, profile);
  }

  /// Keeps the same child active when an earlier one is removed. Removing
  /// the last profile is allowed; the app then asks for a new one.
  Future<void> deleteProfile(int index) async {
    if (index < 0 || index >= _profilesBox.length) return;
    final prefs = await _prefs;
    final activeIndex = prefs.getInt(_activeProfileIndexKey) ?? 0;
    await _profilesBox.deleteAt(index);
    if (_profilesBox.isEmpty) {
      await prefs.remove(_activeProfileIndexKey);
      return;
    }
    final newActive = activeIndex > index
        ? activeIndex - 1
        : activeIndex.clamp(0, _profilesBox.length - 1);
    await prefs.setInt(_activeProfileIndexKey, newActive);
  }
}
