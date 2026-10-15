import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class ChildProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String avatarPath;

  /// Age in years; null for profiles created before ages were asked.
  @HiveField(2)
  final int? age;

  ChildProfile({
    required this.name,
    required this.avatarPath,
    this.age,
  });
}

class ChildProfileAdapter extends TypeAdapter<ChildProfile> {
  @override
  final int typeId = 3;

  @override
  ChildProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChildProfile(
      name: fields[0] as String,
      avatarPath: fields[1] as String,
      age: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ChildProfile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.avatarPath)
      ..writeByte(2)
      ..write(obj.age);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
