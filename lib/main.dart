import 'package:complete/firebase_options.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:complete/homePage/hive/hive_food_item.dart';
import 'package:complete/homePage/hive/hive_refeicao.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

late Box<HiveFoodItem> foodBox;
late Box<HiveFoodItem> dataBaseFoods;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(HiveFoodItemAdapter());
  Hive.registerAdapter(HiveRefeicaoAdapter());

  dataBaseFoods = await Hive.openBox<HiveFoodItem>('dataBaseFoods');
  foodBox = await Hive.openBox<HiveFoodItem>('foodBox');
  final refeicaoBox = await Hive.openBox<HiveRefeicao>('refeicaoBox');

  if (dataBaseFoods.isEmpty) {
    await transferDataToHiveFromJson();
  }

  runApp(
    Provider<Box<HiveRefeicao>>.value(
      value: refeicaoBox,
      child: ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> transferDataToHiveFromJson() async {

  String data = await rootBundle.loadString('assets/data/alimentos.json');

  final Map<String, dynamic> jsonMap = json.decode(data);

  for (var foodJson in jsonMap['Alimentos']) {
    String name = foodJson['A'].replaceAll(',', ' ').replaceAll('  ', ' ');
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

    // Cria um objeto HiveFoodItem com os dados mapeados
    var foodItem = HiveFoodItem(
      name: name.trim(),
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      dominantNutrient: dominantNutrient,
    );

    // Salva o objeto no Hive
    await dataBaseFoods.put(foodItem.name,
        foodItem);
  }
}
