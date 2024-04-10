// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_food_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveFoodItemAdapter extends TypeAdapter<HiveFoodItem> {
  @override
  final int typeId = 0;

  @override
  HiveFoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveFoodItem(
      name: fields[0] as String,
      calories: fields[1] as double,
      protein: fields[2] as double,
      carbs: fields[3] as double,
      fats: fields[4] as double,
      quantity: fields[5] as double,
      dominantNutrient: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveFoodItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.carbs)
      ..writeByte(4)
      ..write(obj.fats)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.dominantNutrient);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveFoodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
