import 'package:hive/hive.dart';

part 'hive_meal_goal.g.dart';

@HiveType(typeId: 1)
class HiveMealGoal extends HiveObject{
  @HiveField(0)
  final double totalCalories;

  @HiveField(1)
  final double totalProtein;

  @HiveField(2)
  final double totalCarbs;

  @HiveField(3)
  final double totalFats;

  HiveMealGoal({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });
}