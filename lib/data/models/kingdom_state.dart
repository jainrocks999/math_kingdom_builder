import 'package:hive/hive.dart';

part 'kingdom_state.g.dart';

@HiveType(typeId: 1)
class KingdomState extends HiveObject {
  @HiveField(0)
  final List<KingdomItem> gardenItems;

  @HiveField(1)
  final List<KingdomItem> meadowItems;

  @HiveField(2)
  final List<KingdomItem> castleItems;

  @HiveField(3)
  final int bridgeLength;

  @HiveField(4)
  final bool bridgeSunshine;

  @HiveField(5)
  final int staircaseSteps;

  @HiveField(6)
  final List<String> patternDecorations;

  KingdomState({
    this.gardenItems = const [],
    this.meadowItems = const [],
    this.castleItems = const [],
    this.bridgeLength = 0,
    this.bridgeSunshine = false,
    this.staircaseSteps = 0,
    this.patternDecorations = const [],
  });

  factory KingdomState.empty() => KingdomState();

  KingdomState copyWith({
    List<KingdomItem>? gardenItems,
    List<KingdomItem>? meadowItems,
    List<KingdomItem>? castleItems,
    int? bridgeLength,
    bool? bridgeSunshine,
    int? staircaseSteps,
    List<String>? patternDecorations,
  }) {
    return KingdomState(
      gardenItems: gardenItems ?? this.gardenItems,
      meadowItems: meadowItems ?? this.meadowItems,
      castleItems: castleItems ?? this.castleItems,
      bridgeLength: bridgeLength ?? this.bridgeLength,
      bridgeSunshine: bridgeSunshine ?? this.bridgeSunshine,
      staircaseSteps: staircaseSteps ?? this.staircaseSteps,
      patternDecorations: patternDecorations ?? this.patternDecorations,
    );
  }
}

@HiveType(typeId: 2)
class KingdomItem {
  @HiveField(0)
  final String assetPath;

  @HiveField(1)
  final double x;

  @HiveField(2)
  final double y;

  @HiveField(3)
  final DateTime earnedAt;

  KingdomItem({
    required this.assetPath,
    required this.x,
    required this.y,
    required this.earnedAt,
  });
}