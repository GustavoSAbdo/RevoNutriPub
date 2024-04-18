// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_meal_goal_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveMealGoalListAdapter extends TypeAdapter<HiveMealGoalList> {
  @override
  final int typeId = 3;

  @override
  HiveMealGoalList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveMealGoalList(
      mealGoals: (fields[0] as HiveList).castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveMealGoalList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.mealGoals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMealGoalListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
