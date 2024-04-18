import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:complete/hive/hive_user.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';
import 'package:complete/hive/hive_meal_goal.dart';

class MealData {
  TextEditingController carbs = TextEditingController();
  TextEditingController protein = TextEditingController();
  TextEditingController fats = TextEditingController();

  MealData({String carbs = '', String protein = '', String fats = ''}) {
    this.carbs.text = carbs;
    this.protein.text = protein;
    this.fats.text = fats;
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

  @override
  void initState() {
    super.initState();
    initializeMealData();
  }

  void initializeMealData() async {
  userBox = await Hive.openBox<HiveUser>('userBox');
  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid != null && userBox.containsKey(uid)) {
    HiveUser user = userBox.get(uid)!;
    int numMeals = user.numRefeicoes;
    refPosTreino = user.refeicaoPosTreino;

    // Correção: Supondo que os dados de refeição estão salvos em outra box específica para MealGoals
    var box = Hive.box<HiveMealGoal>('mealGoals'); // Certifique-se que esta box é aberta em algum ponto antes de ser usada
    List<HiveMealGoal> mealGoals = box.values.toList();

    if (mealGoals.isNotEmpty) {
      meals = mealGoals.map((mealGoal) => MealData(
        carbs: mealGoal.totalCarbs.toStringAsFixed(2),
        protein: mealGoal.totalProtein.toStringAsFixed(2),
        fats: mealGoal.totalFats.toStringAsFixed(2),
      )).toList();
    } else {
      // Inicializa com campos vazios se não houver dados salvos
      meals = List.generate(numMeals, (_) => MealData());
    }

    setState(() {});
  }
}


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Inputs'),
      ),
      body: meals == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
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
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void clearAllInputs() {
    for (var meal in meals!) {
      meal.carbs.clear();
      meal.protein.clear();
      meal.fats.clear();
    }
  }

  void saveAllInputs() async {
    // Supondo que a box para 'HiveMealGoal' seja chamada 'mealGoals'
    var box = Hive.box<HiveMealGoal>('mealGoals');

    // Se a 'mealGoalListBox' deve conter uma lista de 'HiveMealGoal', então
    var mealGoalsList =
        Hive.box<HiveMealGoalList>('mealGoalListBox').get('mealGoalsList');

    if (mealGoalsList == null) {
      mealGoalsList = HiveMealGoalList(mealGoals: HiveList(box));
    } else {
      mealGoalsList.mealGoals.clear();
      await Hive.box<HiveMealGoalList>('mealGoalListBox').put('mealGoalsList', mealGoalsList); 
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

      // Adiciona o objeto 'mealGoal' à 'box' de 'HiveMealGoal'
      box.add(mealGoal);

      Hive.box<HiveMealGoal>('mealGoals').add(mealGoal);
      mealGoalsList.mealGoals.add(mealGoal);
    }

    // Salva as alterações na box de 'HiveMealGoalList'
    await Hive.box<HiveMealGoalList>('mealGoalListBox')
        .put('mealGoalsList', mealGoalsList);

    // Feedback ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dados salvos com sucesso!')),
    );
    // Navega para outra página ou atualiza a UI
    Navigator.pushReplacementNamed(context, '/home');
  }
}
