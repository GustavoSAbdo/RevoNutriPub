import 'package:complete/homePage/classes.dart';
import 'package:complete/homePage/homePageItems/nutrition_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homePageItems/calorie_tracker.dart';
import 'homePageItems/panel_list.dart';
import 'floatingButton/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:complete/style/theme_changer.dart';
import 'package:provider/provider.dart';
import 'package:complete/hive/hive_food_item.dart';
import 'package:complete/hive/hive_refeicao.dart';
import 'package:hive/hive.dart';
import 'package:complete/homePage/drawerItems/meal_goal_data.dart';
import 'package:complete/hive/hive_user.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  List<Refeicao> refeicoes = [];
  int? selectedRefeicaoIndex;
  int numRef = 0;
  late MealGoal singleMealGoal;

  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFats = 0;
  double currentCalories = 0;
  double currentProtein = 0;
  double currentCarbs = 0;
  double currentFats = 0;

  final NutritionService nutritionService = NutritionService();

  MealGoal calculateMealGoalForSingleMeal(double totalCalories,
      double totalProtein, double totalCarbs, double totalFats, int numRef) {
    // Assegura que você tenha o total diário e o número de refeições
    final double mealCalories = totalCalories / numRef;
    final double mealProtein = totalProtein / numRef;
    final double mealCarbs = totalCarbs / numRef;
    final double mealFats = totalFats / numRef;

    return MealGoal(
      totalCalories: mealCalories,
      totalProtein: mealProtein,
      totalCarbs: mealCarbs,
      totalFats: mealFats,
    );
  }

  Future<void> addFoodToRefeicao(
      int refeicaoIndex, FoodItem foodItem, double quantity) async {
    // Obtenha a refeicaoBox do Provider
    final refeicaoBox = Provider.of<Box<HiveRefeicao>>(context, listen: false);
    double newQuantity = quantity;
    double calories = foodItem.calories * quantity / 100;
    double protein = foodItem.protein * quantity / 100;
    double carbs = foodItem.carbs * quantity / 100;
    double fats = foodItem.fats * quantity / 100;
    // Converte FoodItem para HiveFoodItem
    HiveFoodItem hiveFoodItem = HiveFoodItem(
      name: foodItem.name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      quantity: newQuantity,
      dominantNutrient: foodItem.dominantNutrient,
    );

    // Obtém a HiveRefeicao atual
    HiveRefeicao hiveRefeicao =
        refeicaoBox.getAt(refeicaoIndex) ?? HiveRefeicao(items: []);

    // Adiciona o HiveFoodItem à HiveRefeicao
    List<HiveFoodItem> newItems = List<HiveFoodItem>.from(hiveRefeicao.items);
    newItems.add(hiveFoodItem);
    hiveRefeicao = HiveRefeicao(items: newItems);

    setState(() {
      foodItem.quantity = quantity; // Define a quantidade do alimento
      foodItem
          .adjustForQuantity(); // Ajusta os valores nutricionais baseados na quantidade

      var newItems = List<FoodItem>.from(refeicoes[refeicaoIndex].items);
      newItems.add(foodItem);
      refeicoes[refeicaoIndex] = Refeicao(items: newItems);

      updateNutrition(
        foodItem.calories,
        foodItem.protein,
        foodItem.carbs,
        foodItem.fats,
      );
    });

    // Salva a HiveRefeicao atualizada no Hive
    await refeicaoBox.putAt(refeicaoIndex, hiveRefeicao);
  }

  void onRefeicaoUpdated(int index, Refeicao refeicao) {
    setState(() {
      refeicoes[index] = refeicao;
    });
  }

  void updateNutrition(
      double calories, double protein, double carbs, double fats) {
    setState(() {
      currentProtein += protein;
      currentCarbs += carbs;
      currentFats += fats;
      currentCalories = currentProtein * 4 + currentCarbs * 4 + currentFats * 9;
    });
  }

  Future<void> fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String uid = user.uid;
    final userBox = Hive.box<HiveUser>('userBox');
    HiveUser? hiveUser = userBox.get(uid);

    if (hiveUser != null) {
      setState(() {
        numRef = hiveUser.numRefeicoes;
        refeicoes = List<Refeicao>.generate(numRef, (_) => Refeicao());
        MealGoal goal = NutritionService().calculateNutritionalGoals(hiveUser);
        totalCalories = goal.totalCalories;
        totalProtein = goal.totalProtein;
        totalCarbs = goal.totalCarbs;
        totalFats = goal.totalFats;
        singleMealGoal = calculateMealGoalForSingleMeal(
            totalCalories, 
            totalProtein, 
            totalCarbs, 
            totalFats, 
            numRef);
      });
      await adjustRefeicaoBoxSize(numRef);
    }
  }
}



  Future<void> adjustRefeicaoBoxSize(int newSize) async {
    final refeicaoBox = Provider.of<Box<HiveRefeicao>>(context, listen: false);

    // Expandir ou reduzir o tamanho da refeicaoBox para corresponder a newSize
    while (refeicaoBox.length < newSize) {
      await refeicaoBox.add(HiveRefeicao(items: []));
    }

    // Se por algum motivo o tamanho da box for maior que o necessário, você pode remover os excessos
    // Isso deve ser usado com cuidado para não perder dados inadvertidamente
    while (refeicaoBox.length > newSize) {
      await refeicaoBox.deleteAt(refeicaoBox.length - 1);
    }

    // Atualize o estado para refletir as mudanças na UI, se necessário
    setState(() {
      // Atualize o estado conforme necessário
    });
  }

  Future<void> checkAndResetRefeicoes() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('lastResetDate');
    final today = DateTime.now();
    final lastReset = DateTime.tryParse(lastResetDate ?? '') ?? DateTime(2000);

    if (!isSameDay(lastReset, today)) {
      final refeicaoBox =
          Provider.of<Box<HiveRefeicao>>(context, listen: false);
      await refeicaoBox.clear();

      await prefs.setString('lastResetDate', today.toIso8601String());

      setState(() {
        refeicoes = List<Refeicao>.generate(numRef, (_) => Refeicao());
      });
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  void initState() {
    super.initState();
      
    checkAndResetRefeicoes().then((_) {
      fetchUserData().then((_) => loadRefeicoesFromHive());
    });
  }

  Future<void> loadRefeicoesFromHive() async {
    // Acessa a refeicaoBox do Provider sem ouvir por mudanças.
    final Box<HiveRefeicao> refeicaoBox =
        Provider.of<Box<HiveRefeicao>>(context, listen: false);

    final List<Refeicao> loadedRefeicoes = [];

    // Itera sobre todas as HiveRefeicao armazenadas na refeicaoBox.
    for (var hiveRefeicao in refeicaoBox.values) {
      // Converte HiveFoodItem para FoodItem e cria uma lista de FoodItem.
      final foodItems = hiveRefeicao.items
          .map((hiveFoodItem) => FoodItem(
                name: hiveFoodItem.name,
                calories: hiveFoodItem.calories,
                protein: hiveFoodItem.protein,
                carbs: hiveFoodItem.carbs,
                fats: hiveFoodItem.fats,
                quantity: hiveFoodItem.quantity,
                dominantNutrient: hiveFoodItem.dominantNutrient,
              ))
          .toList();

      // Adiciona a nova Refeicao convertida à lista de loadedRefeicoes.
      loadedRefeicoes.add(Refeicao(items: foodItems));
    }
    for (var hiveRefeicao in refeicaoBox.values) {
      for (var hiveFoodItem in hiveRefeicao.items) {
        updateNutrition(hiveFoodItem.calories, hiveFoodItem.protein,
            hiveFoodItem.carbs, hiveFoodItem.fats);
      }
    }
    // Atualiza o estado para refletir as refeições carregadas.
    setState(() {
      refeicoes = loadedRefeicoes;
    });
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  String toTitleCase(String text) {
    if (text.length <= 1) {
      return text.toUpperCase();
    }
    var words = text.split(' ');
    var capitalizedWords = words.map((word) {
      var first = word.substring(0, 1).toUpperCase();
      var rest = word.substring(1);
      return '$first$rest';
    });
    return capitalizedWords.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Retorne um widget de erro ou redirecionamento aqui
      return const Scaffold(
        body: Center(child: Text("Usuário não identificado.")),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Enquanto os dados estão carregando, exibe um indicador de carregamento
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          // Se não houver dados, retorna um widget de erro ou um texto informativo
          return const Scaffold(
            body: Center(child: Text("Dados do usuário não disponíveis.")),
          );
        }

        // Se houver dados disponíveis, processa-os
        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String userName = toTitleCase(userData['nome'] ?? 'Usuário');

        // Construção do layout principal com os dados atualizados
        return Scaffold(
          appBar: AppBar(
            title: const Text(""),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'RevoNutri',
                        style: TextStyle(
                          fontSize: 24, // Ou o tamanho que você preferir
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Olá $userName',
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.brightness_6),
                            onPressed: () {
                              Provider.of<ThemeNotifier>(context, listen: false)
                                  .toggleTheme();
                            },
                          ),
                          const Text('Alterar Tema'),
                        ],
                      )
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Modificar dados pessoais'),
                  onTap: () {
                    Navigator.pop(context); // Fecha o Drawer
                    Navigator.pushNamed(context, '/registerDois');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Definir manualmente'),
                  onTap: () {
                    Navigator.pop(context); // Fecha o Drawer
                    Navigator.pushNamed(context, '/macrosPage');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sair'),
                  onTap: () async {
                    // Fecha o Drawer
                    Navigator.pop(context);

                    // Desloga o usuário
                    await FirebaseAuth.instance.signOut();

                    // Verifica se o widget ainda está montado antes de prosseguir
                    if (mounted) {
                      // Navega para a tela de login e remove todas as rotas anteriores
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (Route<dynamic> route) => false);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Resetar Refeiçoes'),
                  onTap: () async {
                    final refeicaoBox =
                        Provider.of<Box<HiveRefeicao>>(context, listen: false);
                    await refeicaoBox.clear();

                    Navigator.pop(context); // Fecha o Drawer
                    // Navigator.pushNamed(
                    //     context, '/profile'); // Navega para a página de perfil
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: AddRemoveFoodWidget(
            userId: userId,
            onFoodAdded: addFoodToRefeicao,
            mealGoal: singleMealGoal,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Consumer<MealGoalData>(
                  builder: (context, mealGoalData, child) {
                    return NutritionProgress(
                      onUpdateNutrition: updateNutrition,
                      currentCalories: currentCalories,
                      currentProtein: currentProtein,
                      currentCarbs: currentCarbs,
                      currentFats: currentFats,
                      totalCalories: mealGoalData.mealGoal?.totalCalories ?? totalCalories,
                      totalProtein: mealGoalData.mealGoal?.totalProtein ?? totalProtein,
                      totalCarbs: mealGoalData.mealGoal?.totalCarbs ?? totalCarbs,
                      totalFats: mealGoalData.mealGoal?.totalFats ?? totalFats,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Consumer<MealGoalData>(
                  builder: (context, mealGoalData, child) {
                    return MyExpansionPanelListWidget(
                      refeicoes: refeicoes,
                      onRefeicaoUpdated: onRefeicaoUpdated,
                      totalDailyCalories: mealGoalData.mealGoal?.totalCalories ?? totalCalories,
                      totalDailyProtein: mealGoalData.mealGoal?.totalProtein ?? totalProtein,
                      totalDailyCarbs: mealGoalData.mealGoal?.totalCarbs ?? totalCarbs,
                      totalDailyFats: mealGoalData.mealGoal?.totalFats ?? totalFats,
                      numRef: numRef,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
