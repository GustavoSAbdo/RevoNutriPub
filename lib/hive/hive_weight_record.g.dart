// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_weight_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveWeightRecordAdapter extends TypeAdapter<HiveWeightRecord> {
  @override
  final int typeId = 5;

  @override
  HiveWeightRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveWeightRecord(
      peso: fields[0] as double,
      data: fields[1] as DateTime,
      objetivo: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveWeightRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.peso)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.objetivo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveWeightRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
