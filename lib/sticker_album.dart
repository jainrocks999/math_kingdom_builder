import 'package:hive/hive.dart';

part 'sticker_album.g.dart';

@HiveType(typeId: 5)
class StickerAlbum extends HiveObject {
  @HiveField(0)
  final List<String> earnedStickerIds;

  StickerAlbum({this.earnedStickerIds = const []});
}