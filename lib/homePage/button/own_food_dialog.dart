import 'package:flutter/material.dart';
import 'package:complete/homePage/hive/hive_food_item.dart';

class FoodDialogs {
  final BuildContext context;
  final foodBox;

  FoodDialogs({required this.context, required this.foodBox});

  void showAddOwnFoodDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final gramsController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar alimento próprio'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um nome';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: gramsController,
                    decoration: const InputDecoration(labelText: 'Gramas'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira as gramas';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: proteinController,
                    decoration: const InputDecoration(labelText: 'Proteína'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a proteína';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: carbsController,
                    decoration:
                        const InputDecoration(labelText: 'Carboidratos'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira os carboidratos';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: fatsController,
                    decoration: const InputDecoration(labelText: 'Gorduras'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira as gorduras';
                      }
                      value = value.replaceAll(',', '.');
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Por favor, insira um número maior que 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Certifica-se de que o formulário está validado antes de prosseguir
                if (formKey.currentState!.validate()) {
                  // Substitui vírgula por ponto e realiza a conversão para double
                  double grams = double.tryParse(
                          gramsController.text.replaceAll(',', '.')) ??
                      0;
                  double protein = double.tryParse(
                          proteinController.text.replaceAll(',', '.')) ??
                      0;
                  double carbs = double.tryParse(
                          carbsController.text.replaceAll(',', '.')) ??
                      0;
                  double fats = double.tryParse(
                          fatsController.text.replaceAll(',', '.')) ??
                      0;

                  // Realiza os cálculos usando os valores convertidos
                  double calories = (4 * (carbs + protein)) + (9 * fats);
                  double caloriesPer100g = (calories / grams) * 100;
                  double proteinPer100g = (protein / grams) * 100;
                  double carbsPer100g = (carbs / grams) * 100;
                  double fatsPer100g = (fats / grams) * 100;

                  // Determina o nutriente dominante
                  String dominantNutrient =
                      'proteina'; // Valor padrão para inicialização
                  if ((protein * 4) > (carbs * 4) &&
                      (protein * 4) > (fats * 9)) {
                    dominantNutrient = 'proteina';
                  } else if ((carbs * 4) > (protein * 4) &&
                      (carbs * 4) > (fats * 9)) {
                    dominantNutrient = 'carboidrato';
                  } else if ((fats * 9) > (protein * 4) &&
                      (fats * 9) > (carbs * 4)) {
                    dominantNutrient = 'gordura';
                  }

                  // Adiciona o alimento ao Hive Box
                  foodBox.add(HiveFoodItem(
                    name: nameController.text,
                    calories: caloriesPer100g,
                    protein: proteinPer100g,
                    carbs: carbsPer100g,
                    fats: fatsPer100g,
                    dominantNutrient: dominantNutrient,
                    quantity: 100,
                  ));

                  // Fecha o diálogo
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteFoodDialog(BuildContext context) async {
    List<HiveFoodItem> foodsToDelete = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Excluir alimentos'),
              content: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ExpansionTile(
                      title: const Text('Carboidratos',
                          style: TextStyle(color: Colors.blue, fontSize: 18.0)),
                      children: <Widget>[
                        for (var food in foodBox.values)
                          if (food.dominantNutrient == 'carboidrato')
                            CheckboxListTile(
                              title: Text(food.name),
                              value: foodsToDelete.contains(food),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    foodsToDelete.add(food as HiveFoodItem);
                                  } else {
                                    foodsToDelete.remove(food);
                                  }
                                });
                              },
                            ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('Proteinas',
                          style: TextStyle(color: Colors.blue, fontSize: 18.0)),
                      children: <Widget>[
                        for (var food in foodBox.values)
                          if (food.dominantNutrient == 'proteina')
                            CheckboxListTile(
                              title: Text(food.name),
                              value: foodsToDelete.contains(food),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    foodsToDelete.add(food as HiveFoodItem);
                                  } else {
                                    foodsToDelete.remove(food);
                                  }
                                });
                              },
                            ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text('Gorduras',
                          style: TextStyle(color: Colors.blue, fontSize: 18.0)),
                      children: <Widget>[
                        for (var food in foodBox.values)
                          if (food.dominantNutrient == 'gordura')
                            CheckboxListTile(
                              title: Text(food.name),
                              value: foodsToDelete.contains(food),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    foodsToDelete.add(food);
                                  } else {
                                    foodsToDelete.remove(food);
                                  }
                                });
                              },
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Concluir exclusão'),
                  onPressed: () {
                    for (var food in foodsToDelete) {
                      var key = foodBox.keys.firstWhere(
                          (k) => foodBox.get(k) == food,
                          orElse: () => null);
                      if (key != null) {
                        foodBox.delete(key);
                      }
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
