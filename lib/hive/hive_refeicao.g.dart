// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_refeicao.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveRefeicaoAdapter extends TypeAdapter<HiveRefeicao> {
  @override
  final int typeId = 2;

  @override
  HiveRefeicao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveRefeicao(
      items: (fields[0] as List?)?.cast<HiveFoodItem>(),
      modified: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveRefeicao obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.items)
      ..writeByte(1)
      ..write(obj.modified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveRefeicaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
