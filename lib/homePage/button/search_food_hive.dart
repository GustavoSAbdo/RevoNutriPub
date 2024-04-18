import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:complete/hive/hive_food_item.dart';


class SearchAndSelectFoodFromHiveWidget extends StatefulWidget {
  final Function(HiveFoodItem) onFoodSelected;
  final String nutrientDominant;
  final Box<HiveFoodItem> foodBox;

  const SearchAndSelectFoodFromHiveWidget(
      {super.key, required this.onFoodSelected, required this.nutrientDominant, required this.foodBox});

  @override
  _SearchAndSelectFoodFromHiveWidgetState createState() =>
      _SearchAndSelectFoodFromHiveWidgetState();
}

class _SearchAndSelectFoodFromHiveWidgetState
    extends State<SearchAndSelectFoodFromHiveWidget> {
  String searchQuery = '';
  List<HiveFoodItem> selectedFoods = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void addFoodToSelected(HiveFoodItem foodItem) {
  if (selectedFoods.length >= 3) {
    // Mostra o AlertDialog se já houver 3 alimentos selecionados
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Limite Atingido"),
          content: const Text("Só é possível adicionar 3 alimentos. Caso queira adicionar outro, delete um da lista primeiro."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o AlertDialog
              },
            ),
          ],
        );
      },
    );
  } else {
    // Adiciona o alimento à lista se houver menos de 3 itens
    setState(() {
      selectedFoods.add(foodItem);
      widget.onFoodSelected(foodItem);
    });
    searchController.clear();
    searchQuery = '';
    FocusScope.of(context).unfocus();
  }
}

  void removeFoodAt(int index) {
    setState(() {
      selectedFoods.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Pesquisar Alimento Próprio',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: searchQuery.isEmpty
              ? ListView.builder(
                  itemCount: selectedFoods.length,
                  itemBuilder: (context, index) {
                    final food = selectedFoods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text('Calorias: ${food.calories.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => removeFoodAt(index),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: widget.foodBox.length,
                  itemBuilder: (context, index) {
                    HiveFoodItem? foodItem = widget.foodBox.getAt(index);
                    if (foodItem != null &&
                        foodItem.name.toLowerCase().contains(searchQuery) &&
                        foodItem.dominantNutrient == widget.nutrientDominant) {
                      return ListTile(
                        title: Text(foodItem.name),
                        subtitle: Text('Calorias: ${foodItem.calories.toStringAsFixed(2)}, Carboidrato: ${foodItem.carbs.toStringAsFixed(2)}, Proteina: ${foodItem.protein.toStringAsFixed(2)}, Gordura: ${foodItem.fats.toStringAsFixed(2)}, '),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => addFoodToSelected(foodItem),
                        ),
                      );
                    } else {
                      return Container(); // Retorna um container vazio para alimentos que não correspondem à consulta de pesquisa
                    }
                  },
                ),
        ),
      ],
    );
  }
}