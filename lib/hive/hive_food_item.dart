import 'package:hive/hive.dart';

part 'hive_food_item.g.dart'; // Nome do arquivo gerado pelo Hive

@HiveType(typeId: 0)
class HiveFoodItem {
  @HiveField(0)
  final String name;
  @HiveField(1)
  double calories;
  @HiveField(2)
  double protein;
  @HiveField(3)
  double carbs;
  @HiveField(4)
  double fats;
  @HiveField(5)
  double quantity;
  @HiveField(6)
  String dominantNutrient;

  HiveFoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.quantity = 100,
    this.dominantNutrient = '',
  });


   Map<String, dynamic> toMap() {
    return {
      'nome': name,
      'kcal': calories,
      'proteina': protein,
      'carboidrato': carbs,
      'gordura': fats,
      'dominantNutrient': dominantNutrient,
    };
  }
  factory HiveFoodItem.fromMap(Map<String, dynamic> map) {
    return HiveFoodItem(
      name: map['nome'] ?? '', 
      calories: map['kcal']?.toDouble() ?? 0.0, 
      protein: map['proteina']?.toDouble() ?? 0.0,
      carbs: map['carboidrato']?.toDouble() ?? 0.0,
      fats: map['gordura']?.toDouble() ?? 0.0,
      quantity: map['quantidade']?.toDouble() ?? 100.0, 
      dominantNutrient: map['dominantNutrient'] ?? '',
    );
  }
}