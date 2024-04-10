import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NutritionProgress extends StatefulWidget {

  final Function(double calories, double protein, double carbs, double fats)
      onUpdateNutrition;
  // Adicionando os novos parâmetros
  final double currentCalories;
  final double currentProtein;
  final double currentCarbs;
  final double currentFats;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;

  const NutritionProgress({super.key, 

    required this.onUpdateNutrition,
    required this.currentCalories,
    required this.currentProtein,
    required this.currentCarbs,
    required this.currentFats,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });

  @override
  _NutritionProgressState createState() => _NutritionProgressState();
}

class _NutritionProgressState extends State<NutritionProgress> {
  Widget _buildProgressBar(
      String label, double currentValue, double totalValue, Color color) {
    double percent = currentValue / totalValue;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 6),
      child: Column(
        children: [
          Text(
            '$label: ${currentValue.toStringAsFixed(1)} / ${totalValue.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 16),
          ),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double currentCalories = widget.currentCalories;
    double currentProtein = widget.currentProtein;
    double currentCarbs = widget.currentCarbs;
    double currentFats = widget.currentFats;
    double totalCalories = widget.totalCalories;
    double totalProtein = widget.totalProtein;
    double totalCarbs = widget.totalCarbs;
    double totalFats = widget.totalFats;
    return SingleChildScrollView(
        child: Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 20,
                ),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 80,
                    startDegreeOffset: 270, // Ajuste para meia lua
                    sections: [
                      PieChartSectionData(
                        color: Colors.blueAccent,
                        value: currentCalories >= totalCalories ? 100 : (currentCalories / totalCalories) * 100,
                        title: '',
                        radius: 30,
                      ),
                      PieChartSectionData(
                        color: const Color.fromARGB(123, 240, 240, 240),
                        value: currentCalories >= totalCalories ? 0 : 100 - (currentCalories / totalCalories) * 100, // Completa o círculo
                        title: '',
                        radius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Calorias\n${currentCalories.toStringAsFixed(1)}/${totalCalories.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _buildProgressBar(
            'Proteínas',
            currentProtein,
            totalProtein,
            Colors.green,
          ),
        ),
        _buildProgressBar(
          'Carboidratos',
          currentCarbs,
          totalCarbs,
          Colors.red,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: _buildProgressBar(
            'Gorduras',
            currentFats,
            totalFats,
            Colors.orange,
          ),
        )
      ],
    ));
  }
}
