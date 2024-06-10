import 'dart:io';

import 'package:complete/homePage/classes.dart';
import 'package:complete/homePage/homePageItems/feedback_user_dialog.dart';
import 'package:complete/homePage/homePageItems/nutrition_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
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

  late int refPosTreino;

  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFats = 0;
  double currentCalories = 0;
  double currentProtein = 0;
  double currentCarbs = 0;
  double currentFats = 0;

  final NutritionService nutritionService = NutritionService();

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
          totalCalories = hiveUser.macrosDiarios?.totalCalories ?? 0;
          totalProtein = hiveUser.macrosDiarios?.totalProtein ?? 0;
          totalCarbs = hiveUser.macrosDiarios?.totalCarbs ?? 0;
          totalFats = hiveUser.macrosDiarios?.totalFats ?? 0;
          checkBirthday(hiveUser.dataNascimento);
        });
        await adjustRefeicaoBoxSize(numRef);
      }
    }
  }

  Future<void> checkBirthday(DateTime birthDate) async {
    final DateTime today = DateTime.now();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Recuperar a última data em que a mensagem de aniversário foi mostrada
    String lastBirthdayShown = prefs.getString('lastBirthdayShown') ?? '';

    // Checar se hoje é o aniversário do usuário e se a mensagem já foi mostrada neste ano
    if (today.day == birthDate.day && today.month == birthDate.month) {
      // Formatar a data de hoje como string para comparação e armazenamento
      String formattedToday = "${today.year}-${today.month}-${today.day}";

      if (lastBirthdayShown != formattedToday) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DocumentSnapshot userData = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userData.exists) {
            Map<String, dynamic> userInfo =
                userData.data() as Map<String, dynamic>;
            String userName = toTitleCase(userInfo['nome'] ?? 'Usuário');
            int userAge = userInfo['idade'] ?? 0;

            // Exibir AlertDialog para o aniversário
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Feliz Aniversário!'),
                  content: Text(
                      'Olá $userName, gostariamos de lhe parabenizar pelos ${userAge + 1} anos! Nós da RevoNutri desejamos muitas felicidades e um ano maravilhoso pela frente.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        updateAgeInFirestore(user.uid, userAge + 1);
                      },
                      child: const Text('Obrigado(a)!'),
                    ),
                  ],
                );
              },
            );

            await prefs.setString('lastBirthdayShown', formattedToday);
          }
        }
      }
    }
  }

  Future<void> updateAgeInFirestore(String userId, int newAge) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'idade': newAge});
    } catch (e) {
      print('Erro ao atualizar idade: $e');
    }
  }

  Future<void> adjustRefeicaoBoxSize(int newSize) async {
    final refeicaoBox = Provider.of<Box<HiveRefeicao>>(context, listen: false);

    while (refeicaoBox.length < newSize) {
      await refeicaoBox.add(HiveRefeicao(items: []));
    }

    while (refeicaoBox.length > newSize) {
      await refeicaoBox.deleteAt(refeicaoBox.length - 1);
    }

    setState(() {});
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

    _initAsync();
  }

  Future<void> _initAsync() async {
    try {
      await checkAndResetRefeicoes();
      await fetchUserData();
      await loadRefeicoesFromHive();
      await checkLastFeedbackDate();
    } catch (e) {
      // Handle exceptions by logging or showing a user-friendly message
    }
  }

  Future<void> checkLastFeedbackDate() async {
    final userBox = Hive.box<HiveUser>('userBox');
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      HiveUser? hiveUser = userBox.get(uid);

      if (hiveUser != null && hiveUser.lastFeedbackDate != null) {
        final lastFeedbackDate = hiveUser.lastFeedbackDate!;
        final normalizedLastFeedbackDate = DateTime(lastFeedbackDate.year,
            lastFeedbackDate.month, lastFeedbackDate.day);

        final now = DateTime.now();
        final normalizedNow = DateTime(now.year, now.month, now.day);

        if (normalizedNow.difference(normalizedLastFeedbackDate).inDays >= 15) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FeedbackUserDialog();
            },
          );
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
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

  void reloadRefeicoes() async {
    await loadRefeicoesFromHive();
    updateNutritionFromLoadedRefeicoes();
  }

  void updateNutritionFromLoadedRefeicoes() {
    // Reseta os contadores para evitar duplicação ao somar
    double newTotalCalories = 0;
    double newTotalProtein = 0;
    double newTotalCarbs = 0;
    double newTotalFats = 0;

    // Itera sobre cada refeição carregada e soma os valores nutricionais
    for (Refeicao refeicao in refeicoes) {
      for (FoodItem foodItem in refeicao.items) {
        newTotalCalories += foodItem.calories;
        newTotalProtein += foodItem.protein;
        newTotalCarbs += foodItem.carbs;
        newTotalFats += foodItem.fats;
      }
    }

    // Atualiza o estado com os novos totais
    setState(() {
      currentCalories = newTotalCalories;
      currentProtein = newTotalProtein;
      currentCarbs = newTotalCarbs;
      currentFats = newTotalFats;
    });
  }

  void openWhatsapp(
      {required BuildContext context,
      required String text,
      required String number}) async {
    var whatsapp = number; //+92xx enter like this
    var whatsappURlAndroid =
        "whatsapp://send?phone=$whatsapp&text=$text";
    var whatsappURLIos = "https://wa.me/$whatsapp?text=${Uri.tryParse(text)}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(Uri.parse(whatsappURLIos))) {
        await launchUrl(Uri.parse(
          whatsappURLIos,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Whatsapp not installed")));
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(whatsappURlAndroid))) {
        await launchUrl(Uri.parse(whatsappURlAndroid));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Whatsapp not installed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    final userBox = Hive.box<HiveUser>('userBox');
    HiveUser? hiveUser = userBox.get(userId);
    refPosTreino = hiveUser!.refeicaoPosTreino;
    Box<HiveRefeicao> refeicaoBox =
        Provider.of<Box<HiveRefeicao>>(context, listen: false);
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não identificado.")),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Scaffold(
            body: Center(child: Text("Dados do usuário não disponíveis.")),
          );
        }

        String userName = toTitleCase(hiveUser.nome);

        void showDataAlert(String routename) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Atenção!'),
                content: const Text(
                    'Você já possui refeições cadastradas. Se já tiver ingerido as refeições, recomendamos que espere o dia seguinte para alterar os dados. Caso queira prosseguir, aperte Continuar, porém iremos apagar suas refeições caso você faça alterações.'),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, routename);
                        },
                        child: const Text('Continuar'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        }

        bool checkForModifiedItems() {
          return refeicaoBox.values.any((refeicao) => refeicao.modified);
        }

        void checkDataAndNavigate(String routeName) {
          if (refeicaoBox.isNotEmpty && checkForModifiedItems()) {
            showDataAlert(routeName);
          } else {
            Navigator.pushNamed(context, routeName);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(""),
          ),
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'RevoNutri',
                        style: TextStyle(
                          fontSize: 24,
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
                    checkDataAndNavigate('/registerDois');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Definir manualmente'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/macrosPage');
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.paid),
                //   title: const Text('Teste'),
                //   onTap: () {
                //     showDialog(
                //       context: context,
                //       builder: (BuildContext context) {
                //         return FeedbackUserDialog();
                //       },
                //     );
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sair'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (Route<dynamic> route) => false);
                    }
                  },
                ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text('Fale conosco'),
                  onTap: () async {
                    openWhatsapp(context: context, number: '+553184926620', text: 'Olá, tudo bem?');
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: AddRemoveFoodWidget(
            userId: userId,
            onFoodAdded: addFoodToRefeicao,
            onRefeicaoChanged: reloadRefeicoes,
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
                      totalCalories:
                          mealGoalData.mealGoal?.totalCalories ?? totalCalories,
                      totalProtein:
                          mealGoalData.mealGoal?.totalProtein ?? totalProtein,
                      totalCarbs:
                          mealGoalData.mealGoal?.totalCarbs ?? totalCarbs,
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
                      numRef: numRef,
                      refPosTreino: refPosTreino,
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
