import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:complete/homePage/hive/hive_food_item.dart'; // Caminho para sua classe HiveFoodItem

class SearchAndSelectFoodCombinedWidget extends StatefulWidget {
  final Function(SelectedFoodItem) onFoodSelected;
  final String nutrientDominant;
  final Box<HiveFoodItem> dataBaseFoods;
  final Box<HiveFoodItem> foodBox;

  const SearchAndSelectFoodCombinedWidget({
    super.key,
    required this.onFoodSelected,
    required this.nutrientDominant,
    required this.dataBaseFoods,
    required this.foodBox,
  });

  @override
  State<SearchAndSelectFoodCombinedWidget> createState() => _SearchAndSelectFoodCombinedWidgetState();
}

class _SearchAndSelectFoodCombinedWidgetState extends State<SearchAndSelectFoodCombinedWidget> {
  String searchQuery = '';
  List<SelectedFoodItem> searchResults = [];
  final TextEditingController searchController = TextEditingController();
  List<SelectedFoodItem> selectedFoods = []; // Lista para gerenciar alimentos selecionados

  void addFoodToSelected(SelectedFoodItem selectedFood) {
    if (selectedFoods.length >= 3) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Limite Atingido"),
          content: const Text("Só é possível adicionar 3 alimentos. Caso queira adicionar outro, delete um da lista primeiro."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        selectedFoods.add(selectedFood);
      });
      widget.onFoodSelected(selectedFood); // Adapte conforme a necessidade do retorno
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

  void searchFoods() {
    final query = searchQuery.toLowerCase();
    final List<SelectedFoodItem> results = [];

    results.addAll(widget.dataBaseFoods.values
        .where((item) => item.name.toLowerCase().contains(query) && item.dominantNutrient == widget.nutrientDominant)
        .map((item) => SelectedFoodItem(foodItem: item, source: 'Tabela TACO'))
        .toList());

    results.addAll(widget.foodBox.values
        .where((item) => item.name.toLowerCase().contains(query) && item.dominantNutrient == widget.nutrientDominant)
        .map((item) => SelectedFoodItem(foodItem: item, source: 'Tabela Própria'))
        .toList());

    setState(() {
      searchResults = results;
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
            labelText: 'Pesquisar Alimento',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
            searchFoods();
          },
        ),
      ),
      Expanded(
        child: searchQuery.isEmpty
          ? ListView.builder(
              itemCount: selectedFoods.length,
              itemBuilder: (context, index) {
                final item = selectedFoods[index];
                return ListTile(
                  title: Text('${item.foodItem.name} (${item.source})'),
                  subtitle: Text('Calorias: ${item.foodItem.calories.toStringAsFixed(2)}, Carboidrato: ${item.foodItem.carbs.toStringAsFixed(2)}, Proteina: ${item.foodItem.protein.toStringAsFixed(2)}, Gordura: ${item.foodItem.fats.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => removeFoodAt(index),
                  ),
                );
              },
            )
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final item = searchResults[index];
                return ListTile(
                  title: Text('${item.foodItem.name} (${item.source})'),
                  subtitle: Text('Calorias: ${item.foodItem.calories.toStringAsFixed(2)}, Carboidrato: ${item.foodItem.carbs.toStringAsFixed(2)}, Proteina: ${item.foodItem.protein.toStringAsFixed(2)}, Gordura: ${item.foodItem.fats.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => addFoodToSelected(item),
                  ),
                );
              },
            ),
      ),
    ],
  );
}
}

class SelectedFoodItem {
  final HiveFoodItem foodItem;
  final String source; // "tabela própria" ou "tabela TACO"

  SelectedFoodItem({required this.foodItem, required this.source});
}