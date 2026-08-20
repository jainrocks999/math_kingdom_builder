import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class LessonProgress extends HiveObject {
  @HiveField(0)
  final List<int> masteredNumbers;

  LessonProgress({
    this.masteredNumbers = const [],
  });
}

class LessonProgressAdapter extends TypeAdapter<LessonProgress> {
  @override
  final int typeId = 4;

  @override
  LessonProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonProgress(
      masteredNumbers: (fields[0] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, LessonProgress obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.masteredNumbers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
