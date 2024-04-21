import 'package:flutter/material.dart';
import 'package:complete/hive/hive_meal_goal.dart';
import 'package:complete/main.dart';
import 'package:provider/provider.dart';
import 'package:complete/homePage/drawerItems/meal_goal_data.dart';

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
                      _proteinController.clear();
                      _carbsController.clear();
                      _fatsController.clear();
                      _caloriesController.clear();
                      Navigator.pushReplacementNamed(context, '/home');
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

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newGoal = HiveMealGoal(
        totalProtein:
            double.parse(_proteinController.text.replaceAll(',', '.')),
        totalCarbs: double.parse(_carbsController.text.replaceAll(',', '.')),
        totalFats: double.parse(_fatsController.text.replaceAll(',', '.')),
        totalCalories: double.parse(_caloriesController.text),
      );
      totalMealGoalBox.add(newGoal);
      Provider.of<MealGoalData>(context, listen: false).update(newGoal);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
