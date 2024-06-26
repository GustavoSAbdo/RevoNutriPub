import 'package:complete/firebase_options.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:complete/hive/hive_food_item.dart';
import 'package:complete/hive/hive_refeicao.dart';
import 'package:complete/hive/hive_meal_goal.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:complete/homePage/drawerItems/meal_goal_data.dart';
import 'package:complete/hive/hive_user.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';

late Box<HiveFoodItem> foodBox;
late Box<HiveFoodItem> dataBaseFoods;
late Box<HiveMealGoal> totalMealGoalBox;
late Box<HiveUser> userBox;
late Box<HiveMealGoalList> mealGoalListBox;
late Box<HiveMealGoalList> mealGoalListBoxAut;
late Box<HiveMealGoal> mealGoals;
late Box<HiveMealGoal> userMealGoals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(HiveFoodItemAdapter());
  Hive.registerAdapter(HiveRefeicaoAdapter());
  Hive.registerAdapter(HiveMealGoalAdapter());
  Hive.registerAdapter(HiveUserAdapter());
  Hive.registerAdapter(HiveMealGoalListAdapter());

  dataBaseFoods = await Hive.openBox<HiveFoodItem>('dataBaseFoods');
  foodBox = await Hive.openBox<HiveFoodItem>('foodBox');
  totalMealGoalBox = await Hive.openBox<HiveMealGoal>('totalMealGoalBox');
  userBox = await Hive.openBox<HiveUser>('userBox');
  mealGoalListBox = await Hive.openBox<HiveMealGoalList>('mealGoalListBox');
  mealGoalListBoxAut = await Hive.openBox<HiveMealGoalList>('mealGoalListBoxAut');
  mealGoals = await Hive.openBox<HiveMealGoal>('mealGoals');
  userMealGoals = await Hive.openBox<HiveMealGoal>('userMealGoals');
  final refeicaoBox = await Hive.openBox<HiveRefeicao>('refeicaoBox');

  if (dataBaseFoods.isEmpty) {
    await transferDataToHiveFromJson();
  }

  

  runApp(
    MultiProvider(
      providers: [
        Provider<Box<HiveRefeicao>>.value(
          value: refeicaoBox,
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider<MealGoalData>(
          create: (_) => MealGoalData(totalMealGoalBox),
        ),
      ],
      child: const MyApp(),
    ),
  );
}





Future<void> transferDataToHiveFromJson() async {
  String data = await rootBundle.loadString('assets/data/alimentos.json');
  final Map<String, dynamic> jsonMap = json.decode(data);

  for (var foodJson in jsonMap['Alimentos']) {
    String name = normalizeString(foodJson['A']);
    double calories = foodJson['B']?.toDouble() ?? 0.0;
    double protein = foodJson['C']?.toDouble() ?? 0.0;
    double fats = foodJson['D']?.toDouble() ?? 0.0;
    double carbs = foodJson['E']?.toDouble() ?? 0.0;

    double proteinKcal = protein * 4;
    double fatsKcal = fats * 9;
    double carbsKcal = carbs * 4;
    String dominantNutrient = '';
    if (proteinKcal > fatsKcal && proteinKcal > carbsKcal) {
      dominantNutrient = 'proteina';
    } else if (fatsKcal > proteinKcal && fatsKcal > carbsKcal) {
      dominantNutrient = 'gordura';
    } else if (carbsKcal > proteinKcal && carbsKcal > fatsKcal) {
      dominantNutrient = 'carboidrato';
    }

    var foodItem = HiveFoodItem(
      name: name.trim(),
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      dominantNutrient: dominantNutrient,
    );

    await dataBaseFoods.put(foodItem.name, foodItem);
  }
}

String normalizeString(String input) {
  const accents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
  const withoutAccents = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';

  String output = input.split('').map((char) {
    int index = accents.indexOf(char);
    return index != -1 ? withoutAccents[index] : char;
  }).join();

  return output.replaceAll(',', ' ').replaceAll('  ', ' ');
}
