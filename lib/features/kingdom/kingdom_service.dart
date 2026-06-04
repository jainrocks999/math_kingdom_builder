import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/reward_progress_service.dart';
import '../../data/models/kingdom_state.dart';

class KingdomSyncResult {
  const KingdomSyncResult({
    required this.state,
    required this.progress,
    required this.newlyUnlockedZoneIds,
  });

  final KingdomState state;
  final RewardProgressSnapshot progress;
  final Set<String> newlyUnlockedZoneIds;
}

/// Keeps persisted [KingdomState] aligned with learning progress and tracks
/// which zones the child has already seen unlock for.
class KingdomService {
  KingdomService._();

  static final KingdomService instance = KingdomService._();

  static const _seenUnlockedZonesKey = 'kingdom_seen_unlocked_zones';
  static const _mapWidth = 1180.0;
  static const _mapHeight = 860.0;

  /// Updates kingdom rewards from learning progress without unlock UI.
  Future<void> syncFromProgressOnly() async {
    final progress = await RewardProgressService.instance.loadSnapshot();
    final box = Hive.box<KingdomState>('kingdoms');
    final current = box.get('current') ?? KingdomState.empty();
    final synced = _applyProgressToState(current, progress);

    if (_stateChanged(current, synced)) {
      await box.put('current', synced);
    }
  }

  Future<KingdomSyncResult> loadSyncedState() async {
    final progress = await RewardProgressService.instance.loadSnapshot();
    final box = Hive.box<KingdomState>('kingdoms');
    final current = box.get('current') ?? KingdomState.empty();
    final synced = _applyProgressToState(current, progress);

    if (_stateChanged(current, synced)) {
      await box.put('current', synced);
    }

    final unlockedZoneIds = _unlockedZoneIds(synced, progress);
    final seenZoneIds = await _loadSeenUnlockedZones();
    late final Set<String> newlyUnlocked;

    if (seenZoneIds.isEmpty) {
      await _markZonesSeen(unlockedZoneIds);
      newlyUnlocked = <String>{};
    } else {
      newlyUnlocked = unlockedZoneIds.difference(seenZoneIds);
      if (newlyUnlocked.isNotEmpty) {
        await _markZonesSeen(unlockedZoneIds);
      }
    }

    return KingdomSyncResult(
      state: synced,
      progress: progress,
      newlyUnlockedZoneIds: newlyUnlocked,
    );
  }

  KingdomState _applyProgressToState(
    KingdomState state,
    RewardProgressSnapshot progress,
  ) {
    final learnProgress =
        progress.completionCountFor(RewardModuleIds.learnNumbers) +
            progress.completionCountFor(RewardModuleIds.findNumber);
    final countingProgress =
        progress.completionCountFor(RewardModuleIds.countObjects);
    final tracingProgress =
        progress.completionCountFor(RewardModuleIds.traceNumbers);
    final matchingProgress =
        progress.completionCountFor(RewardModuleIds.matchNumbers);

    final gardenTarget = learnProgress.clamp(0, 8);
    final meadowTarget = countingProgress.clamp(0, 6);
    final castleTarget = tracingProgress.clamp(0, 6);
    final pathTarget = matchingProgress.clamp(0, 5);

    return state.copyWith(
      gardenItems: _ensureItems(
        existing: state.gardenItems,
        targetCount: gardenTarget,
        assetPrefix: 'garden/flower_',
        zoneLeft: 80,
        zoneTop: 360,
        zoneWidth: 270,
        zoneHeight: 180,
        columns: 4,
      ),
      meadowItems: _ensureItems(
        existing: state.meadowItems,
        targetCount: meadowTarget,
        assetPrefix: 'meadow/animal_',
        zoneLeft: 395,
        zoneTop: 250,
        zoneWidth: 285,
        zoneHeight: 190,
        columns: 3,
      ),
      castleItems: _ensureItems(
        existing: state.castleItems,
        targetCount: castleTarget,
        assetPrefix: 'castle/block_',
        zoneLeft: 760,
        zoneTop: 120,
        zoneWidth: 270,
        zoneHeight: 230,
        columns: 5,
      ),
      patternDecorations: _ensurePatternDecorations(
        state.patternDecorations,
        pathTarget,
      ),
    );
  }

  List<KingdomItem> _ensureItems({
    required List<KingdomItem> existing,
    required int targetCount,
    required String assetPrefix,
    required double zoneLeft,
    required double zoneTop,
    required double zoneWidth,
    required double zoneHeight,
    required int columns,
  }) {
    if (existing.length >= targetCount) {
      return existing;
    }

    final items = List<KingdomItem>.from(existing);
    for (var i = existing.length; i < targetCount; i++) {
      final column = i % columns;
      final row = i ~/ columns;
      items.add(
        KingdomItem(
          assetPath: 'assets/images/kingdom/$assetPrefix${i % 5}',
          x: (zoneLeft + 28 + (column * (zoneWidth / columns))) / _mapWidth,
          y: (zoneTop + zoneHeight - 48 - (row * 32)) / _mapHeight,
          earnedAt: DateTime.now(),
        ),
      );
    }
    return items;
  }

  List<String> _ensurePatternDecorations(
    List<String> existing,
    int targetCount,
  ) {
    if (existing.length >= targetCount) return existing;

    const palette = ['peach', 'lavender', 'mint', 'gold', 'sky'];
    final decorations = List<String>.from(existing);
    for (var i = existing.length; i < targetCount; i++) {
      decorations.add(palette[i % palette.length]);
    }
    return decorations;
  }

  Set<String> _unlockedZoneIds(
    KingdomState state,
    RewardProgressSnapshot progress,
  ) {
    final learnProgress =
        progress.completionCountFor(RewardModuleIds.learnNumbers) +
            progress.completionCountFor(RewardModuleIds.findNumber);
    final countingProgress =
        progress.completionCountFor(RewardModuleIds.countObjects);
    final tracingProgress =
        progress.completionCountFor(RewardModuleIds.traceNumbers);
    final matchingProgress =
        progress.completionCountFor(RewardModuleIds.matchNumbers);

    final unlocked = <String>{'garden'};

    if (state.gardenItems.isNotEmpty || learnProgress > 0) {
      unlocked.add('meadow');
    }
    if (state.meadowItems.isNotEmpty || countingProgress > 0) {
      unlocked.add('castle');
    }
    if (state.castleItems.isNotEmpty || tracingProgress > 0) {
      unlocked.add('path');
    }
    if (state.patternDecorations.isNotEmpty || matchingProgress > 0) {
      unlocked.add('bridge');
    }
    if (state.bridgeLength > 0) {
      unlocked.add('stairs');
    }

    return unlocked;
  }

  bool _stateChanged(KingdomState before, KingdomState after) {
    return before.gardenItems.length != after.gardenItems.length ||
        before.meadowItems.length != after.meadowItems.length ||
        before.castleItems.length != after.castleItems.length ||
        before.patternDecorations.length != after.patternDecorations.length ||
        before.bridgeLength != after.bridgeLength ||
        before.bridgeSunshine != after.bridgeSunshine ||
        before.staircaseSteps != after.staircaseSteps;
  }

  Future<Set<String>> _loadSeenUnlockedZones() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_seenUnlockedZonesKey)?.toSet() ?? <String>{};
  }

  Future<void> _markZonesSeen(Set<String> zoneIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _seenUnlockedZonesKey,
      zoneIds.toList()..sort(),
    );
  }
}
