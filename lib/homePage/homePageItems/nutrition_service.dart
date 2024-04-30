import 'package:complete/homePage/classes.dart';
import 'package:complete/hive/hive_user.dart'; // Caminho para sua classe HiveUser
import 'package:complete/hive/hive_meal_goal_list.dart';
import 'package:complete/hive/hive_meal_goal.dart';
import 'package:hive/hive.dart';

class NutritionService {
  MealGoal calculateNutritionalGoals(HiveUser user) {
    double peso = user.peso;
    String objetivo = user.objetivo;
    String nivelAtividade = user.nivelAtividade;
    double tmb = user.tmb;
    double multiplicadorProt = user.multiplicadorProt;
    double multiplicadorGord = user.multiplicadorGord;

    double coeficiente = 0;
    double totalFats;
    double totalCalories;
    double totalProtein;
    double totalCarbs;

    switch (objetivo) {
      case 'manterPeso':
        coeficiente = 1;
        break;
      case 'perderPesoAgressivamente':
        coeficiente = 0.7;
        break;
      case 'perderPeso':
        coeficiente = 0.85;
        break;
      case 'ganharPesoAgressivamente':
        coeficiente = 1.15;
        break;
      case 'ganharPeso':
        coeficiente = 1.07;
        break;
    }

    switch (nivelAtividade) {
      case 'sedentario':
        totalCalories = tmb * 1.2 * coeficiente;
        break;
      case 'atividadeLeve':
        totalCalories = tmb * 1.3 * coeficiente;
        break;
      case 'atividadeModerada':
        totalCalories = tmb * 1.42 * coeficiente;
        break;
      case 'muitoAtivo':
        totalCalories = tmb * 1.55 * coeficiente;
        break;
      default:
        totalCalories = tmb * 1.8 * coeficiente;
        break;
    }

    totalProtein = peso * multiplicadorProt;
    totalFats = peso * multiplicadorGord;
    totalCarbs = (totalCalories - (totalFats * 9 + totalProtein * 4)) / 4;

    totalCalories = totalProtein * 4 + totalCarbs * 4 + totalFats * 9;

    return MealGoal(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
    );
  }

  HiveMealGoalList calculateRefGoals(HiveUser user) {
    int qtdRef = user.numRefeicoes;
    HiveMealGoal? userMealGoal = user.macrosDiarios;
    // int refPosTreino = user.refeicaoPosTreino;
    var mealGoalBox = Hive.box<HiveMealGoal>('totalMealGoalBox');
    HiveMealGoal? mealGoal;
    late double protPerMeal;
    late double carbsPerMeal;
    late double fatsPerMeal;
    late double caloriesPerMeal;

    if (mealGoalBox.isEmpty) {
      if (userMealGoal == null) {
        var box = Hive.box<HiveMealGoal>('mealGoals');
        return HiveMealGoalList(
            mealGoals: HiveList<HiveMealGoal>(box)); 
      }

      protPerMeal = userMealGoal.totalProtein / qtdRef;
      carbsPerMeal = userMealGoal.totalCarbs / qtdRef;
      fatsPerMeal = userMealGoal.totalFats / qtdRef;
      caloriesPerMeal = userMealGoal.totalCalories / qtdRef;      
    } else {
      mealGoal = mealGoalBox.getAt(0);
      protPerMeal = mealGoal!.totalProtein / qtdRef;
      carbsPerMeal = mealGoal.totalCarbs / qtdRef;
      fatsPerMeal = mealGoal.totalFats / qtdRef;
      caloriesPerMeal = mealGoal.totalCalories / qtdRef;    
    }

    var userBox = Hive.box<HiveMealGoal>('userMealGoals');

      var userMealGoalsList = HiveList<HiveMealGoal>(userBox);

      for (int i = 0; i < qtdRef; i++) {
        HiveMealGoal mealGoal = HiveMealGoal(
            totalCalories: caloriesPerMeal,
            totalProtein: protPerMeal,
            totalCarbs: carbsPerMeal,
            totalFats: fatsPerMeal);

        userBox.add(mealGoal);
        userMealGoalsList.add(mealGoal);
      }
      return HiveMealGoalList(mealGoals: userMealGoalsList);
  }
}
