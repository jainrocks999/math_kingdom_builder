// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_album.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StickerAlbumAdapter extends TypeAdapter<StickerAlbum> {
  @override
  final int typeId = 5;

  @override
  StickerAlbum read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickerAlbum(
      earnedStickerIds: (fields[0] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StickerAlbum obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.earnedStickerIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickerAlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
