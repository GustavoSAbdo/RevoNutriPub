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
      dataNascimento: fields[2] as DateTime,
      multiplicadorGord: fields[3] as double,
      multiplicadorProt: fields[4] as double,
      numRefeicoes: fields[5] as int,
      peso: fields[6] as double,
      nivelAtividade: fields[7] as String,
      objetivo: fields[8] as String,
      refeicaoPosTreino: fields[9] as int,
      tmb: fields[10] as double,
      macrosRef: fields[11] as HiveMealGoalList?,
      macrosDiarios: fields[12] as HiveMealGoal?,
      nome: fields[13] as String,
      genero: fields[14] as String,
      lastFeedbackDate: fields[15] as DateTime?,
      lastObjectiveChange: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveUser obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.altura)
      ..writeByte(1)
      ..write(obj.idade)
      ..writeByte(2)
      ..write(obj.dataNascimento)
      ..writeByte(3)
      ..write(obj.multiplicadorGord)
      ..writeByte(4)
      ..write(obj.multiplicadorProt)
      ..writeByte(5)
      ..write(obj.numRefeicoes)
      ..writeByte(6)
      ..write(obj.peso)
      ..writeByte(7)
      ..write(obj.nivelAtividade)
      ..writeByte(8)
      ..write(obj.objetivo)
      ..writeByte(9)
      ..write(obj.refeicaoPosTreino)
      ..writeByte(10)
      ..write(obj.tmb)
      ..writeByte(11)
      ..write(obj.macrosRef)
      ..writeByte(12)
      ..write(obj.macrosDiarios)
      ..writeByte(13)
      ..write(obj.nome)
      ..writeByte(14)
      ..write(obj.genero)
      ..writeByte(15)
      ..write(obj.lastFeedbackDate)
      ..writeByte(16)
      ..write(obj.lastObjectiveChange);
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
