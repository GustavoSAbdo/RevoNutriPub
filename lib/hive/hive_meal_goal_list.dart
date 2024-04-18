import 'package:hive/hive.dart';
import 'hive_meal_goal.dart'; 

part 'hive_meal_goal_list.g.dart'; // Este arquivo será gerado pelo build_runner

@HiveType(typeId: 3)
class HiveMealGoalList {
  @HiveField(0)
  final HiveList<HiveMealGoal> mealGoals;

  HiveMealGoalList({required this.mealGoals});
}
