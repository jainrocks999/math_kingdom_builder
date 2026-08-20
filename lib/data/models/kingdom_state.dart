import 'package:hive/hive.dart';

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

class KingdomStateAdapter extends TypeAdapter<KingdomState> {
  @override
  final int typeId = 1;

  @override
  KingdomState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KingdomState(
      gardenItems: (fields[0] as List).cast<KingdomItem>(),
      meadowItems: (fields[1] as List).cast<KingdomItem>(),
      castleItems: (fields[2] as List).cast<KingdomItem>(),
      bridgeLength: fields[3] as int,
      bridgeSunshine: fields[4] as bool,
      staircaseSteps: fields[5] as int,
      patternDecorations: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, KingdomState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.gardenItems)
      ..writeByte(1)
      ..write(obj.meadowItems)
      ..writeByte(2)
      ..write(obj.castleItems)
      ..writeByte(3)
      ..write(obj.bridgeLength)
      ..writeByte(4)
      ..write(obj.bridgeSunshine)
      ..writeByte(5)
      ..write(obj.staircaseSteps)
      ..writeByte(6)
      ..write(obj.patternDecorations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KingdomStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KingdomItemAdapter extends TypeAdapter<KingdomItem> {
  @override
  final int typeId = 2;

  @override
  KingdomItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KingdomItem(
      assetPath: fields[0] as String,
      x: fields[1] as double,
      y: fields[2] as double,
      earnedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KingdomItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.assetPath)
      ..writeByte(1)
      ..write(obj.x)
      ..writeByte(2)
      ..write(obj.y)
      ..writeByte(3)
      ..write(obj.earnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KingdomItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
