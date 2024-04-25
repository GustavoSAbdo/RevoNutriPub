// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveUserAdapter extends TypeAdapter<HiveUser> {
  @override
  final int typeId = 4;

  @override
  HiveUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveUser(
      altura: fields[0] as double,
      idade: fields[1] as int,
      multiplicadorGord: fields[2] as double,
      multiplicadorProt: fields[3] as double,
      numRefeicoes: fields[4] as int,
      peso: fields[5] as double,
      nivelAtividade: fields[6] as String,
      objetivo: fields[7] as String,
      refeicaoPosTreino: fields[8] as int,
      tmb: fields[9] as double,
      macrosRef: fields[10] as HiveMealGoalList?,
      macrosDiarios: fields[11] as HiveMealGoal?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUser obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.altura)
      ..writeByte(1)
      ..write(obj.idade)
      ..writeByte(2)
      ..write(obj.multiplicadorGord)
      ..writeByte(3)
      ..write(obj.multiplicadorProt)
      ..writeByte(4)
      ..write(obj.numRefeicoes)
      ..writeByte(5)
      ..write(obj.peso)
      ..writeByte(6)
      ..write(obj.nivelAtividade)
      ..writeByte(7)
      ..write(obj.objetivo)
      ..writeByte(8)
      ..write(obj.refeicaoPosTreino)
      ..writeByte(9)
      ..write(obj.tmb)
      ..writeByte(10)
      ..write(obj.macrosRef)
      ..writeByte(11)
      ..write(obj.macrosDiarios);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
