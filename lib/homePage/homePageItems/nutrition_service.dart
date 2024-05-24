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
      case 'perderPeso':
        coeficiente = 0.85;
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
      case 'extremamenteAtivo':
        totalCalories = tmb * 1.8 * coeficiente;
        break;
      default:
        totalCalories = tmb * coeficiente;
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
    int refPosTreino = user.refeicaoPosTreino;
    var mealGoalBox = Hive.box<HiveMealGoal>('totalMealGoalBox');
    HiveMealGoal? mealGoal;
    late double protPerMeal;
    late double carbsPerMeal;
    late double fatsPerMeal;
    late double caloriesPerMeal;

    if (mealGoalBox.isEmpty) {
      if (userMealGoal == null) {
        var box = Hive.box<HiveMealGoal>('mealGoals');
        return HiveMealGoalList(mealGoals: HiveList<HiveMealGoal>(box));
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

    List<HiveMealGoal> mealGoals = List.generate(
        qtdRef,
        (i) => HiveMealGoal(
            totalCalories: caloriesPerMeal,
            totalProtein: protPerMeal,
            totalCarbs: carbsPerMeal,
            totalFats: fatsPerMeal));

    var userBox = Hive.box<HiveMealGoal>('userMealGoals');
    var userMealGoalsList = HiveList<HiveMealGoal>(userBox);

    if (refPosTreino >= 0 && refPosTreino <= qtdRef) {
      // Cálculos para ajustes
      double fatsAdjustment = fatsPerMeal * 0.5;
      double protAdjustment = protPerMeal * 0.1;
      double carbsAdjustment = carbsPerMeal * 0.1;

      for (int i = 0; i < qtdRef; i++) {
        if (i + 1 == refPosTreino) {
          mealGoals[i].totalFats -= fatsAdjustment;
          mealGoals[i].totalProtein += protAdjustment;
          mealGoals[i].totalCarbs += carbsAdjustment;
        } else {
          mealGoals[i].totalFats += fatsAdjustment / (qtdRef - 1);
          mealGoals[i].totalProtein -= protAdjustment / (qtdRef - 1);
          mealGoals[i].totalCarbs -= carbsAdjustment / (qtdRef - 1);
        }
        mealGoals[i].totalCalories = mealGoals[i].totalProtein * 4 +
            mealGoals[i].totalCarbs * 4 +
            mealGoals[i].totalFats * 9;
        userBox.add(mealGoals[i]);
        userMealGoalsList.add(mealGoals[i]);
      }
    }

    return HiveMealGoalList(mealGoals: userMealGoalsList);
  }

  MealGoal updateNutritionObj(HiveUser user, objetivoNovo) {
    double totalFats = user.macrosDiarios!.totalFats;
    double totalCalories;
    double totalProtein = user.macrosDiarios!.totalProtein;
    late double totalCarbs;
    String objetivoAtual = user.objetivo;
    double peso = user.peso;
    double carboidrato = user.macrosDiarios!.totalCarbs;

    if (objetivoAtual == 'perderPeso') {
      if (objetivoNovo == 'ganharPeso') {
        totalCarbs = carboidrato + peso;
      } else if (objetivoNovo == 'manterPeso') {
        totalCarbs = carboidrato + (peso * 0.5);
      } else {
        totalCarbs = carboidrato;
      }
    } else if (objetivoAtual == 'ganharPeso') {
      if (objetivoNovo == 'perderPeso') {
        totalCarbs = carboidrato - peso;
      } else if (objetivoNovo == 'manterPeso') {
        totalCarbs = carboidrato - (peso * 0.5);
      } else {
        totalCarbs = carboidrato;
      }
    } else {
      if (objetivoNovo == 'perderPeso') {
        totalCarbs = carboidrato - (peso * 0.5);
      } else if (objetivoNovo == 'ganharPeso') {
        totalCarbs = carboidrato + (peso * 0.5);
      } else {
        totalCarbs = carboidrato;
      }
    }

    totalCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFats * 9);

    return MealGoal(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
    );
  }

  MealGoal updateNutritionOnActivityChange(
      HiveUser user, String novoNivelAtividade) {
    double totalFats = user.macrosDiarios!.totalFats;
    double totalCalories;
    double totalProtein = user.macrosDiarios!.totalProtein;
    late double totalCarbs;

    double getActivityFactor(String nivelAtividade) {
      switch (nivelAtividade) {
        case 'sedentario':
          return 1.2;
        case 'atividadeLeve':
          return 1.3;
        case 'atividadeModerada':
          return 1.42;
        case 'muitoAtivo':
          return 1.55;
        case 'extremamenteAtivo':
          return 1.8;
        default:
          return 1.0;
      }
    }

    double fatorAtual = getActivityFactor(user.nivelAtividade);
    double fatorNovo = getActivityFactor(novoNivelAtividade);

    totalCalories =
        (user.macrosDiarios!.totalCalories / fatorAtual) * fatorNovo;

    if (totalCalories > user.macrosDiarios!.totalCalories) {
      totalCarbs = user.macrosDiarios!.totalCarbs +
          (totalCalories - user.macrosDiarios!.totalCalories) / 4;
    } else {
      totalCarbs = user.macrosDiarios!.totalCarbs -
          (user.macrosDiarios!.totalCalories - totalCalories) / 4;
    }

    return MealGoal(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
    );
  }
}
