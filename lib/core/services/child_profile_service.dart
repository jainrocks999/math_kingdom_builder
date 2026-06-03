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

  Future<void> _ensureSeededProfiles() async {
    if (_profilesBox.isNotEmpty) return;

    await _profilesBox.addAll([
      ChildProfile(name: 'Aarav', avatarPath: '🦁'),
      ChildProfile(name: 'Mia', avatarPath: '🐻'),
      ChildProfile(name: 'Zoya', avatarPath: '🦊'),
    ]);
  }
}
