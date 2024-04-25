import 'package:flutter/material.dart';
import '../classes.dart';
import 'package:hive/hive.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';
import 'package:complete/hive/hive_meal_goal.dart';

class MyExpansionPanelListWidget extends StatefulWidget {
  final List<Refeicao> refeicoes;
  final Function(int, Refeicao) onRefeicaoUpdated;

  final double totalDailyCalories;
  final double totalDailyProtein;
  final double totalDailyCarbs;
  final double totalDailyFats;
  final int numRef;

  const MyExpansionPanelListWidget({
    super.key,
    required this.refeicoes,
    required this.onRefeicaoUpdated,
    required this.totalDailyCalories,
    required this.totalDailyProtein,
    required this.totalDailyCarbs,
    required this.totalDailyFats,
    required this.numRef,
  });

  @override
  _MyExpansionPanelListWidgetState createState() =>
      _MyExpansionPanelListWidgetState();
}

class _MyExpansionPanelListWidgetState
    extends State<MyExpansionPanelListWidget> {
  double calculateTotal(
      List<FoodItem> items, double Function(FoodItem) selector) {
    return items.fold(0.0, (double prev, item) => prev + selector(item));
  }

  Widget buildNutritionSummary(String label, double total, double goal) {
    return Text(
      '$label: ${total.toStringAsFixed(2)} / ${goal.toStringAsFixed(2)}',
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<HiveMealGoalList>('mealGoalListBox');
    var mealGoalsList = box
        .get('mealGoalsList'); // Assume que isso retorna uma HiveMealGoalList

    if (mealGoalsList == null) {
      return const Center(child: Text("Nenhum dado de refeição disponível."));
    }

    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        children: mealGoalsList.mealGoals.asMap().entries.map((entry) {
          int index = entry.key;
          HiveMealGoal mealGoal = entry.value;
          Refeicao refeicao = widget.refeicoes[index];

          double totalProtein =
              calculateTotal(refeicao.items, (item) => item.protein);
          double totalCarbs =
              calculateTotal(refeicao.items, (item) => item.carbs);
          double totalFats =
              calculateTotal(refeicao.items, (item) => item.fats);
          double totalCalories =
              totalProtein * 4 + totalCarbs * 4 + totalFats * 9;

          return ExpansionPanelRadio(
            value: index,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text('Refeição ${index + 1}'),
              );
            },
            body: Column(
              children: [
                ...refeicao.items.map((foodItem) => ListTile(
                      title: Text(
                          '${foodItem.quantity.toStringAsFixed(1)}g de ${foodItem.name}'),
                      subtitle: Text(
                          'Calorias: ${foodItem.calories.toStringAsFixed(2)}, Proteínas: ${foodItem.protein.toStringAsFixed(2)}, Carboidratos: ${foodItem.carbs.toStringAsFixed(2)}, Gorduras: ${foodItem.fats.toStringAsFixed(2)}'),
                    )),
                const Divider(color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildNutritionSummary('🔥 Calorias da refeição',
                          totalCalories, mealGoal.totalCalories),
                      buildNutritionSummary('🍗 Proteínas da refeição',
                          totalProtein, mealGoal.totalProtein),
                      buildNutritionSummary('🍞 Carboidratos da refeição',
                          totalCarbs, mealGoal.totalCarbs),
                      buildNutritionSummary('🥑 Gorduras da refeição',
                          totalFats, mealGoal.totalFats),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
