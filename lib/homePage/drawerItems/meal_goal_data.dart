import 'package:flutter/foundation.dart';
import 'package:complete/hive/hive_meal_goal.dart';
import 'package:hive/hive.dart';

class MealGoalData extends ChangeNotifier {
  HiveMealGoal? mealGoal;
  late Box<HiveMealGoal> mealGoalBox;

  MealGoalData(this.mealGoalBox) {
    if (mealGoalBox.isNotEmpty) {
      mealGoal = mealGoalBox.getAt(0);
    }
  }

  void update(HiveMealGoal newGoal) {
    mealGoal = newGoal;
    mealGoalBox.putAt(0, newGoal);
    notifyListeners();
  }

  void clear() {
    mealGoal = null;
    mealGoalBox.clear();
    notifyListeners();
  }
}