import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/child_profile.dart';

class ChildProfileSnapshot {
  const ChildProfileSnapshot({
    required this.profiles,
    required this.activeIndex,
  });

  final List<ChildProfile> profiles;
  final int activeIndex;

  ChildProfile get activeProfile => profiles[activeIndex];
}

class ChildProfileService {
  ChildProfileService._();

  static final ChildProfileService instance = ChildProfileService._();

  static const _activeProfileIndexKey = 'active_child_profile_index';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Box<ChildProfile> get _profilesBox => Hive.box<ChildProfile>('profiles');

  Future<ChildProfileSnapshot> loadSnapshot() async {
    await _ensureSeededProfiles();
    final prefs = await _prefs;
    final profiles = _profilesBox.values.toList(growable: false);
    final activeIndex = prefs.getInt(_activeProfileIndexKey) ?? 0;
    final safeIndex = activeIndex.clamp(0, profiles.length - 1);

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

  /// Keeps at least one profile, and keeps the same child active when an
  /// earlier one is removed.
  Future<void> deleteProfile(int index) async {
    if (_profilesBox.length <= 1 || index < 0 || index >= _profilesBox.length) {
      return;
    }
    final prefs = await _prefs;
    final activeIndex = prefs.getInt(_activeProfileIndexKey) ?? 0;
    await _profilesBox.deleteAt(index);
    final newActive = activeIndex > index
        ? activeIndex - 1
        : activeIndex.clamp(0, _profilesBox.length - 1);
    await prefs.setInt(_activeProfileIndexKey, newActive);
  }

  Future<void> _ensureSeededProfiles() async {
    if (_profilesBox.isNotEmpty) return;

    // One friendly starter profile; parents rename it in the Parent Zone.
    await _profilesBox.add(
      ChildProfile(name: 'Little Star', avatarPath: '🦁', age: 5),
    );
  }
}
