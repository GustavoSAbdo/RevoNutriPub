import 'package:complete/hive/hive_user.dart';
import 'package:complete/main.dart';
import 'package:complete/homePage/floatingButton/own_food_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:complete/homePage/floatingButton/search_food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complete/homePage/classes.dart';
import 'dart:math';
import 'package:complete/hive/hive_food_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:complete/hive/hive_refeicao.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddRemoveFoodWidget extends StatefulWidget {
  final String userId;
  final Function(int, FoodItem, double) onFoodAdded;
  final Function onRefeicaoChanged;

  const AddRemoveFoodWidget(
      {super.key,
      required this.userId,
      required this.onFoodAdded,
      required this.onRefeicaoChanged});
  @override
  _AddRemoveFoodWidgetState createState() => _AddRemoveFoodWidgetState();
}

class _AddRemoveFoodWidgetState extends State<AddRemoveFoodWidget> {
  int selectedRefeicaoIndex = 0;
  late MealGoal mealGoal;
  FoodDialogs? foodDialogs;
  List<int> modifiedMeals = [];
  bool verificationProt = false;
  bool verificationCarb = false;
  bool verificationGord = false;
  List<FoodItemWithQuantity> allSelectedFoodsWithQuantities = [];
  Offset position = const Offset(0, 0);

  Future<void> _showSuggestionsDialog(int numRef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? dontShowAgain = prefs.getBool('dontShowSuggestionsDialog') ?? false;

    if (dontShowAgain) {
      _showRefeicaoDialog(numRef);
      return;
    }

    bool dontShowAgainValue = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Sugestões'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Exemplos de alimentos em que as calorias são majoritariamente fonte de carboidratos: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'macarrão, arroz, banana, feijão, etc...',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Exemplos de alimentos em que as calorias são majoritariamente fonte de proteína: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                'frango peito, carne bovina patinho, porco lombo, etc...',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Exemplos de alimentos em que as calorias são majoritariamente fonte de gordura: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                'azeite, amendoim, castanha, abacate, ovo, etc...',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Obs.: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                'Recomendamos fortemente a ingestão de legumes, frutas e vegetais. Você pode consumir vegetais à vontade, sem precisar calcular no aplicativo.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: dontShowAgainValue,
                          onChanged: (bool? value) {
                            setState(() {
                              dontShowAgainValue = value!;
                            });
                          },
                        ),
                        const Text("Não mostrar novamente"),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    if (dontShowAgainValue) {
                      prefs.setBool('dontShowSuggestionsDialog', true);
                    }
                    Navigator.of(context).pop();
                    _showRefeicaoDialog(numRef);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRefeicaoDialog(int numRef) {
    int? selectedRefeicao;

    Box<HiveRefeicao> refeicaoBox =
        Provider.of<Box<HiveRefeicao>>(context, listen: false);

    User? user = FirebaseAuth.instance.currentUser;
    final userBox = Hive.box<HiveUser>('userBox');
    HiveUser? hiveUser = userBox.get(user!.uid);

    int refPosTreino = hiveUser!.refeicaoPosTreino;

    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Escolha uma Refeição'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: List<Widget>.generate(
                    numRef,
                    (i) {
                      // Verifica se a refeição atual já tem alimentos
                      bool isRefeicaoModified =
                          refeicaoBox.getAt(i)?.items.isNotEmpty ?? false;
                      return ListTile(
                        title: Text(i + 1 == refPosTreino
                            ? 'Refeição Pós Treino'
                            : 'Refeição ${i + 1}'),
                        leading: Radio<int>(
                          value: i,
                          groupValue: selectedRefeicao,
                          onChanged: isRefeicaoModified
                              ? null // Desabilita se a refeição já tem alimentos
                              : (int? value) {
                                  setStateDialog(() {
                                    selectedRefeicao = value;
                                  });
                                },
                        ),
                      );
                    },
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedRefeicao != null) {
                      Navigator.of(context).pop(selectedRefeicao);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Próximo'),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedRefeicaoResult) {
      if (selectedRefeicaoResult != null) {
        setState(() {
          selectedRefeicaoIndex = selectedRefeicaoResult;
        });
        _showAddFoodDialog(selectedRefeicaoResult);
      }
    });
  }

  void _showAddFoodDialog(int selectedRefeicaoIndex) async {
    List<FoodItem> tempSelectedFoodsCarb = [];
    List<FoodItem> tempSelectedFoodsProtein = [];
    List<FoodItem> tempSelectedFoodsFat = [];
    bool shouldContinue = true;
    var dataBaseFoodsBox = Hive.box<HiveFoodItem>('dataBaseFoods');
    var foodBox = Hive.box<HiveFoodItem>('foodBox');

    Future<void> selectFoodByNutrient(
        String nutrient, List<FoodItem> targetList) async {
      bool selectionComplete = false;
      bool wasCancelled = false;

      while (!selectionComplete) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  'Selecione um alimento em que a maioria das calorias é $nutrient'),
              content: SizedBox(
                height: 300,
                width: double.maxFinite,
                child: SearchAndSelectFoodCombinedWidget(
                  nutrientDominant: nutrient,
                  dataBaseFoods: dataBaseFoodsBox,
                  foodBox: foodBox,
                  onFoodSelected: (SelectedFoodItem selectedFood) {
                    targetList
                        .add(FoodItem.fromMap(selectedFood.foodItem.toMap()));
                  },
                  onFoodRemoved: (SelectedFoodItem removedFood) {
                    targetList.removeWhere(
                        (item) => item.name == removedFood.foodItem.name);
                  },
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        shouldContinue = false;
                        wasCancelled = true;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Próximo'),
                    ),
                  ],
                )
              ],
            );
          },
        );

        if (!wasCancelled && targetList.isEmpty) {
          bool proceed = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Nenhum alimento selecionado'),
                content: Text(
                    'Você não selecionou nenhum alimento que seja fonte de $nutrient. Ao continuar, possivelmente irá ter falta desse macronutriente na refeição. Deseja continuar mesmo assim?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Não'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Sim'),
                  ),
                ],
              );
            },
          );

          if (proceed) {
            selectionComplete = true;
          }
        } else {
          selectionComplete = true;
        }
      }
    }

    await selectFoodByNutrient('carboidrato', tempSelectedFoodsCarb);
    if (!shouldContinue) return;
    await selectFoodByNutrient('proteina', tempSelectedFoodsProtein);
    if (!shouldContinue) return;
    await selectFoodByNutrient('gordura', tempSelectedFoodsFat);
    if (!shouldContinue) return;

    var box = Hive.box<HiveMealGoalList>('mealGoalListBox');
    var mealGoalsList = box.get('mealGoalsList');
    User? user = FirebaseAuth.instance.currentUser;
    final userBox = Hive.box<HiveUser>('userBox');
    HiveUser? hiveUser = userBox.get(user!.uid);
    var autBox = Hive.box<HiveMealGoalList>('mealGoalListBoxAut');
    var autMealGoalsList = autBox.get('mealGoalListBoxAut');

    if (mealGoalsList != null &&
        selectedRefeicaoIndex < mealGoalsList.mealGoals.length) {
      mealGoal = MealGoal.fromHiveMealGoal(
          mealGoalsList.mealGoals[selectedRefeicaoIndex]);
    } else if (autMealGoalsList != null &&
        selectedRefeicaoIndex < autMealGoalsList.mealGoals.length) {
      mealGoal = MealGoal.fromHiveMealGoal(
          autMealGoalsList.mealGoals[selectedRefeicaoIndex]);
    } else {
      if (hiveUser!.macrosRef != null &&
          selectedRefeicaoIndex < hiveUser.macrosRef!.mealGoals.length) {
        mealGoal = MealGoal.fromHiveMealGoal(
            hiveUser.macrosRef!.mealGoals[selectedRefeicaoIndex]);
      }
    }

    bool controllerProteinMais = verificaAliMaisUm(tempSelectedFoodsProtein);
    bool controllerCarbsMais = verificaAliMaisUm(tempSelectedFoodsCarb);
    bool controllerFatsMais = verificaAliMaisUm(tempSelectedFoodsFat);

    bool controllerProteinMaisDois =
        verificaAliMaisDois(tempSelectedFoodsProtein);
    bool controllerCarbsMaisDois = verificaAliMaisDois(tempSelectedFoodsCarb);
    bool controllerFatsMaisDois = verificaAliMaisDois(tempSelectedFoodsFat);
    if (controllerProteinMaisDois ||
        controllerCarbsMaisDois ||
        controllerFatsMaisDois) {
      allSelectedFoodsWithQuantities = calculateFoodQuantitiesDoisAMais(
          tempSelectedFoodsCarb,
          tempSelectedFoodsProtein,
          tempSelectedFoodsFat,
          mealGoal);
    } else if (controllerFatsMais ||
        controllerCarbsMais ||
        controllerProteinMais) {
      allSelectedFoodsWithQuantities = calculateFoodQuantitiesUmAMais(
          tempSelectedFoodsCarb,
          tempSelectedFoodsProtein,
          tempSelectedFoodsFat,
          mealGoal);
    } else {
      allSelectedFoodsWithQuantities = calculateFoodQuantities(
          tempSelectedFoodsCarb,
          tempSelectedFoodsProtein,
          tempSelectedFoodsFat,
          mealGoal);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confira os alimentos e quantidades selecionados'),
          content: SingleChildScrollView(
            child: ListBody(
              children: allSelectedFoodsWithQuantities
                  .map((item) => ListTile(
                        title: Text(item.foodItem.name),
                        trailing: Text('${item.quantity.toStringAsFixed(2)}g'),
                      ))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                for (var foodItemWithQuantity
                    in allSelectedFoodsWithQuantities) {
                  FoodItem foodItem = foodItemWithQuantity.foodItem;
                  double quantity = foodItemWithQuantity.quantity;

                  widget.onFoodAdded(selectedRefeicaoIndex, foodItem, quantity);
                }
                Box<HiveRefeicao> refeicaoBox =
                    Provider.of<Box<HiveRefeicao>>(context, listen: false);
                HiveRefeicao hiveRefeicao =
                    refeicaoBox.getAt(selectedRefeicaoIndex) ?? HiveRefeicao();
                hiveRefeicao.modified = true;
                refeicaoBox.putAt(selectedRefeicaoIndex, hiveRefeicao);

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void removeRefeicao(int index) {
    Box<HiveRefeicao> refeicaoBox =
        Provider.of<Box<HiveRefeicao>>(context, listen: false);
    HiveRefeicao hiveRefeicao = refeicaoBox.getAt(index) ?? HiveRefeicao();

    hiveRefeicao.items.clear();

    refeicaoBox.putAt(index, hiveRefeicao);
    widget.onRefeicaoChanged.call();
  }

  void _showRemoveRefeicaoDialog() {
    Box<HiveRefeicao> refeicaoBox =
        Provider.of<Box<HiveRefeicao>>(context, listen: false);

    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int?
            tempSelectedRefeicao; // Estado local para armazenar a seleção temporária

        return StatefulBuilder(
            // Usando StatefulBuilder para gerenciar o estado local
            builder: (BuildContext context, StateSetter setStateDialog) {
          return AlertDialog(
            title: const Text('Remover Refeição'),
            content: SingleChildScrollView(
              child: ListBody(
                children: List<Widget>.generate(
                  refeicaoBox.length,
                  (i) {
                    bool isRefeicaoNotEmpty =
                        refeicaoBox.getAt(i)?.items.isNotEmpty ?? false;
                    return isRefeicaoNotEmpty
                        ? ListTile(
                            title: Text('Refeição ${i + 1}'),
                            leading: Radio<int>(
                              value: i,
                              groupValue: tempSelectedRefeicao,
                              onChanged: (int? value) {
                                setStateDialog(() {
                                  // Atualiza o estado dentro do StatefulBuilder
                                  tempSelectedRefeicao = value;
                                });
                              },
                            ),
                          )
                        : Container();
                  },
                ).where((element) => element is! Container).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (tempSelectedRefeicao != null) {
                    removeRefeicao(tempSelectedRefeicao!);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Remover'),
              ),
            ],
          );
        });
      },
    );
  }

 

  @override
  void initState() {
    super.initState();
    foodDialogs =
        foodDialogs ?? FoodDialogs(context: context, foodBox: foodBox);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      setState(() {
        position = Offset(screenSize.width - 56, screenSize.height - 56);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    foodDialogs =
        foodDialogs ?? FoodDialogs(context: context, foodBox: foodBox);
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var numRef = userData['numRefeicoes'] ?? 0;

          return Stack(
            children: [
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      var newX = position.dx + details.delta.dx;
                      var newY = position.dy + details.delta.dy;

                      const leftPadding = 30.0;
                      const topPadding = 55.0;

                      newX = newX.clamp(leftPadding, screenSize.width - 56);
                      newY = newY.clamp(
                          statusBarHeight + appBarHeight + topPadding,
                          screenSize.height - 56);

                      position = Offset(newX, newY);
                    });
                  },
                  child: FloatingActionButton(
                    onPressed: () {},
                    child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == 'add') {
                          _showSuggestionsDialog(numRef);
                        } else if (value == 'remove') {
                          _showRemoveRefeicaoDialog();
                        } else if (value == 'removeOwn') {
                          foodDialogs!.showDeleteFoodDialog(context);
                        } else if (value == 'addOwn') {
                          foodDialogs!.showAddOwnFoodDialog();
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'add',
                          child: Text('Adicionar Refeição'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'remove',
                          child: Text(
                              'Remover Refeição'), // Opção para remover refeição
                        ),
                        const PopupMenuItem<String>(
                          value: 'addOwn',
                          child: Text('Adicionar Alimento Próprio'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'removeOwn',
                          child: Text('Remover Alimento Próprio'),
                        ),
                      ],
                      icon: const Icon(Icons.add),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // Quando os dados estão sendo carregados...
          return const Center(child: CircularProgressIndicator());
        } else {
          // Para outros estados, como erro ou dados não encontrados
          return const Center(
              child: Text("Não foi possível carregar os dados."));
        }
      },
    );
  }
}
