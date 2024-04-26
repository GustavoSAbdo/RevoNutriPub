import 'package:complete/hive/hive_meal_goal.dart';
import 'package:complete/homePage/drawerItems/meal_goal_data.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:complete/hive/hive_user.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';

class MealData {
  TextEditingController carbs = TextEditingController();
  TextEditingController protein = TextEditingController();
  TextEditingController fats = TextEditingController();
  Function updateCallback;

  MealData(
      {String carbs = '',
      String protein = '',
      String fats = '',
      required this.updateCallback}) {
    this.carbs.text = carbs;
    this.protein.text = protein;
    this.fats.text = fats;

    // Adicionar listeners para atualizar a UI quando os valores mudarem
    this.carbs.addListener(() => updateCallback());
    this.protein.addListener(() => updateCallback());
    this.fats.addListener(() => updateCallback());
  }

  void dispose() {
    carbs.dispose();
    protein.dispose();
    fats.dispose();
  }
}

class MealInputPage extends StatefulWidget {
  @override
  _MealInputPageState createState() => _MealInputPageState();
}

class _MealInputPageState extends State<MealInputPage> {
  List<MealData>? meals; // Tornar nullable
  late Box userBox;
  HiveUser? user;
  late int refPosTreino;
  bool isLoading = true;
  double remainingCarbs = 0.0;
  double remainingProtein = 0.0;
  double remainingFats = 0.0;

  @override
  void initState() {
    super.initState();
    initializeMealData();
    calculateRemainingMacros();
  }

  void calculateRemainingMacros() {
    final mealGoalData = Provider.of<MealGoalData>(context, listen: false);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      final userBox = Hive.box<HiveUser>('userBox');
      HiveUser? hiveUser = userBox.get(uid);

      if (mealGoalData.mealGoal != null && meals != null) {
        remainingCarbs = mealGoalData.mealGoal?.totalCarbs ?? 0.0;
        remainingProtein = mealGoalData.mealGoal?.totalProtein ?? 0.0;
        remainingFats = mealGoalData.mealGoal?.totalFats ?? 0.0;

        for (var meal in meals!) {
          remainingCarbs -= double.tryParse(meal.carbs.text) ?? 0.0;
          remainingProtein -= double.tryParse(meal.protein.text) ?? 0.0;
          remainingFats -= double.tryParse(meal.fats.text) ?? 0.0;
        }
        setState(() {});
      } else if (hiveUser != null && hiveUser.macrosDiarios != null) {
        remainingCarbs = hiveUser.macrosDiarios?.totalCarbs ?? 0.0;
        remainingFats = hiveUser.macrosDiarios?.totalFats ?? 0.0;
        remainingProtein = hiveUser.macrosDiarios?.totalProtein ?? 0.0;

        for (var meal in meals ?? []) {
          remainingCarbs -= double.tryParse(meal.carbs.text) ?? 0.0;
          remainingProtein -= double.tryParse(meal.protein.text) ?? 0.0;
          remainingFats -= double.tryParse(meal.fats.text) ?? 0.0;
        }
        setState(() {});
      }
    }
  }

  void updateMacros() {
    calculateRemainingMacros();
    setState(() {});
  }

  void initializeMealData() async {
    userBox = await Hive.openBox<HiveUser>('userBox');
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && userBox.containsKey(uid)) {
      HiveUser user = userBox.get(uid)!;
      int numMeals = user.numRefeicoes;
      refPosTreino = user.refeicaoPosTreino;

      var box = Hive.box<HiveMealGoal>('mealGoals');
      List<HiveMealGoal> mealGoals = box.values.toList();

      if (mealGoals.isNotEmpty) {
        meals = mealGoals
            .map((mealGoal) => MealData(
                  carbs: mealGoal.totalCarbs.toStringAsFixed(2),
                  protein: mealGoal.totalProtein.toStringAsFixed(2),
                  fats: mealGoal.totalFats.toStringAsFixed(2),
                  updateCallback: updateMacros,
                ))
            .toList();
      } else {
        meals = List.generate(
            numMeals, (_) => MealData(updateCallback: updateMacros));
      }

      calculateRemainingMacros(); // Adicione esta linha
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
      ),
      body: Column(
        children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    'Macros Restantes:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Carboidratos: ${remainingCarbs.toStringAsFixed(2)}g',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Proteínas: ${remainingProtein.toStringAsFixed(2)}g',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Gorduras: ${remainingFats.toStringAsFixed(2)}g',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Expanded(
            child: meals == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: meals!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                (refPosTreino == index + 1)
                                    ? 'Refeição pós-treino'
                                    : 'Refeição ${index + 1}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      controller: meals![index].carbs,
                                      decoration: const InputDecoration(
                                          labelText: 'Carboidrato:'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      controller: meals![index].protein,
                                      decoration: const InputDecoration(
                                          labelText: 'Proteína:'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      controller: meals![index].fats,
                                      decoration: const InputDecoration(
                                          labelText: 'Gordura:'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: clearAllInputs,
                  child: const Text('Limpar'),
                ),
                ElevatedButton(
                  onPressed: saveAllInputs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void clearAllInputs() async {
    var box = Hive.box<HiveMealGoal>('mealGoals');
    await box.clear();
    for (var meal in meals!) {
      meal.carbs.clear();
      meal.protein.clear();
      meal.fats.clear();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados limpos com sucesso!')),
    );
    Navigator.pushReplacementNamed(context, '/home');
  }

  void saveAllInputs() async {
    if (remainingCarbs != 0.0 ||
        remainingProtein != 0.0 ||
        remainingFats != 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Por favor, certifique-se de que todos os macros restantes são iguais a zero antes de salvar.')),
      );
      return;
    }

    var box = Hive.box<HiveMealGoal>('mealGoals');
    await box.clear();
    var mealGoalsList =
        Hive.box<HiveMealGoalList>('mealGoalListBox').get('mealGoalsList');

    if (mealGoalsList == null) {
      mealGoalsList = HiveMealGoalList(mealGoals: HiveList(box));
    } else {
      mealGoalsList.mealGoals.clear();
    }

    for (var mealData in meals!) {
      double totalProtein = double.tryParse(mealData.protein.text) ?? 0.0;
      double totalCarbs = double.tryParse(mealData.carbs.text) ?? 0.0;
      double totalFats = double.tryParse(mealData.fats.text) ?? 0.0;
      double totalCalories =
          (totalProtein * 4) + (totalCarbs * 4) + (totalFats * 9);

      HiveMealGoal mealGoal = HiveMealGoal(
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFats: totalFats,
      );

      box.add(mealGoal);
      mealGoalsList.mealGoals.add(mealGoal);
    }

    await Hive.box<HiveMealGoalList>('mealGoalListBox')
        .put('mealGoalsList', mealGoalsList);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos com sucesso!')),
    );

    Navigator.pushReplacementNamed(context, '/home');
  }
}
