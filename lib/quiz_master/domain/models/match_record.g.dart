// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_record.dart';

class MatchRecordAdapter extends TypeAdapter<MatchRecord> {
  @override
  final int typeId = 0;

  @override
  MatchRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchRecord(
      date: fields[0] as DateTime,
      scorePlayer1: fields[1] as int,
      scorePlayer2: fields[2] as int,
      categoryName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MatchRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.scorePlayer1)
      ..writeByte(2)
      ..write(obj.scorePlayer2)
      ..writeByte(3)
      ..write(obj.categoryName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
