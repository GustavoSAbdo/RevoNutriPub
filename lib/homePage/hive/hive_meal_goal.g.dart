// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_meal_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMealGoalAdapter extends TypeAdapter<HiveMealGoal> {
  @override
  final int typeId = 1;

  @override
  HiveMealGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMealGoal(
      totalCalories: fields[0] as double,
      totalProtein: fields[1] as double,
      totalCarbs: fields[2] as double,
      totalFats: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HiveMealGoal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalCalories)
      ..writeByte(1)
      ..write(obj.totalProtein)
      ..writeByte(2)
      ..write(obj.totalCarbs)
      ..writeByte(3)
      ..write(obj.totalFats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMealGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
