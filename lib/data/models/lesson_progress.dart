import 'package:hive/hive.dart';

part 'lesson_progress.g.dart';

@HiveType(typeId: 4)
class LessonProgress extends HiveObject {
  @HiveField(0)
  final List<int> masteredNumbers;

  LessonProgress({
    this.masteredNumbers = const [],
  });
}