import 'package:hive/hive.dart';

part 'child_profile.g.dart';

@HiveType(typeId: 3)
class ChildProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String avatarPath;

  ChildProfile({
    required this.name,
    required this.avatarPath,
  });
}