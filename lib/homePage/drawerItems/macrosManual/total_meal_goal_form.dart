import 'package:complete/hive/hive_user.dart';
import 'package:complete/homePage/homePageItems/nutrition_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:complete/hive/hive_meal_goal.dart';
import 'package:complete/main.dart';
import 'package:provider/provider.dart';
import 'package:complete/homePage/drawerItems/meal_goal_data.dart';
import 'package:hive/hive.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';

class MealGoalFormPage extends StatefulWidget {
  const MealGoalFormPage({super.key});

  @override
  _MealGoalFormPageState createState() => _MealGoalFormPageState();
}

class _MealGoalFormPageState extends State<MealGoalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _proteinController.addListener(_updateCalories);
    _carbsController.addListener(_updateCalories);
    _fatsController.addListener(_updateCalories);

    MealGoalData mealGoalData =
        Provider.of<MealGoalData>(context, listen: false);
    HiveMealGoal? currentGoal = mealGoalData.mealGoal;

    if (currentGoal != null) {
      _proteinController.text = currentGoal.totalProtein.toString();
      _carbsController.text = currentGoal.totalCarbs.toString();
      _fatsController.text = currentGoal.totalFats.toString();
      _caloriesController.text = currentGoal.totalCalories.toString();
    }
  }

  @override
  void dispose() {
    _proteinController.removeListener(_updateCalories);
    _carbsController.removeListener(_updateCalories);
    _fatsController.removeListener(_updateCalories);
    // Dispose controllers
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _updateCalories() {
    double protein =
        double.tryParse(_proteinController.text.replaceAll(',', '.')) ?? 0;
    double carbs =
        double.tryParse(_carbsController.text.replaceAll(',', '.')) ?? 0;
    double fats =
        double.tryParse(_fatsController.text.replaceAll(',', '.')) ?? 0;
    double calories = (protein * 4) + (carbs * 4) + (fats * 9);
    _caloriesController.text = calories.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: _proteinController,
                decoration:
                    const InputDecoration(labelText: 'Proteína (gramas)'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateNumber(value),
              ),
              TextFormField(
                controller: _carbsController,
                decoration:
                    const InputDecoration(labelText: 'Carboidrato (gramas)'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateNumber(value),
              ),
              TextFormField(
                controller: _fatsController,
                decoration:
                    const InputDecoration(labelText: 'Gordura (gramas)'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateNumber(value),
              ),
              TextFormField(
                controller: _caloriesController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Calorias'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<MealGoalData>(context, listen: false).clear();
                      var autListBox = Hive.box<HiveMealGoalList>('mealGoalListBoxAut');
                      autListBox.clear();
                      _proteinController.clear();
                      _carbsController.clear();
                      _fatsController.clear();
                      _caloriesController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Dados limpos com sucesso!')),
                      );
                      var box = Hive.box<HiveMealGoalList>('mealGoalListBox');
                      var mealGoalsList = box.get('mealGoalsList');

                      // Aqui verificamos se o mealGoalsList não é nulo e se tem itens
                      if (mealGoalsList != null &&
                          mealGoalsList.mealGoals.isNotEmpty) {
                        Navigator.pushReplacementNamed(
                            context, '/macrosRefPage');
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: const Text('Limpar'),
                  ),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary, // Cor de fundo do botão
                      foregroundColor:
                          Colors.white, // Cor do texto e ícones do botão
                    ),
                    child: const Text('Salvar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value) {
    if (value == null ||
        double.tryParse(value.replaceAll(',', '.')) == null ||
        double.parse(value.replaceAll(',', '.')) < 1) {
      return 'Por favor, insira um número válido maior ou igual a 1';
    }
    return null;
  }

  void _saveForm() async {
  if (_formKey.currentState!.validate()) {
    // Mostra o AlertDialog
    bool shouldContinue = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Com os macronutrientes sendo definidos manualmente, não podemos garantir que irá ter resultados e também iremos deixar coisas como ajustes por sua conta.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false para não continuar
              },
            ),
            TextButton(
              child: const Text('Continuar'),
              onPressed: () {
                Navigator.of(context).pop(true); // Retorna true para continuar
              },
            ),
          ],
        );
      },
    );

    if (!shouldContinue) {
      return; // Interrompe a execução do código
    }

    final newGoal = HiveMealGoal(
      totalProtein: double.parse(_proteinController.text.replaceAll(',', '.')),
      totalCarbs: double.parse(_carbsController.text.replaceAll(',', '.')),
      totalFats: double.parse(_fatsController.text.replaceAll(',', '.')),
      totalCalories: double.parse(_caloriesController.text),
    );

    totalMealGoalBox.add(newGoal);
    Provider.of<MealGoalData>(context, listen: false).update(newGoal);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos com sucesso!')),
    );

    var box = Hive.box<HiveMealGoalList>('mealGoalListBox');
    var mealGoalsList = box.get('mealGoalsList');

    User? user = FirebaseAuth.instance.currentUser;
    final userBox = Hive.box<HiveUser>('userBox');
    if (user != null && userBox.containsKey(user.uid)) {
      String uid = user.uid;
      HiveUser? hiveUser = userBox.get(uid);

      HiveMealGoalList calculatedMealGoals = NutritionService().calculateRefGoals(hiveUser!);
      var autListBox = Hive.box<HiveMealGoalList>('mealGoalListBoxAut');
      autListBox.put('mealGoalListBoxAut', calculatedMealGoals);
    }
    
    if (mealGoalsList != null && mealGoalsList.mealGoals.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/macrosRefPage');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

}
