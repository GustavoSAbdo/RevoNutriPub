import 'package:complete/homePage/classes.dart';

class NutritionService {
  MealGoal calculateNutritionalGoals(Map<String, dynamic> userData) {
    double peso = userData['peso'] is double
        ? userData['peso']
        : double.tryParse(userData['peso'].toString()) ?? 0;
    String objetivo = userData['objetivo'];
    String nivelAtividade = userData['nivelAtividade'];
    double coeficiente = 0;
    double tmb = double.tryParse(userData['tmb'].toString()) ?? 0;
    double multiplicadorProt = double.tryParse(userData['multiplicadorProt'].toString()) ?? 0;
    double multiplicadorGord = double.tryParse(userData['multiplicadorGord'].toString()) ?? 0;

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
}