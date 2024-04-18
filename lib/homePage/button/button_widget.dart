import 'package:complete/main.dart';
import 'package:complete/homePage/button/own_food_dialog.dart';
import 'package:flutter/material.dart';
import 'package:complete/homePage/button/search_food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complete/homePage/classes.dart';
import 'dart:math';
import 'package:complete/hive/hive_food_item.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:complete/hive/hive_refeicao.dart';

class AddRemoveFoodWidget extends StatefulWidget {
  final String userId;
  final Function(int, FoodItem, double) onFoodAdded;
  final MealGoal mealGoal;

  const AddRemoveFoodWidget(
      {super.key,
      required this.userId,
      required this.onFoodAdded,
      required this.mealGoal});
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

  void showRefeicaoDialog(int numRef) {
    int? selectedRefeicao;

    Box<HiveRefeicao> refeicaoBox =
        Provider.of<Box<HiveRefeicao>>(context, listen: false);

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
                        title: Text('Refeição ${i + 1}'),
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

    // Função para mostrar o diálogo de seleção de alimentos por macronutriente
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
                  dataBaseFoods:
                      dataBaseFoodsBox, // Ajuste para sua caixa do Hive para "tabela TACO"
                  foodBox:
                      foodBox, // Ajuste para sua caixa do Hive para alimentos próprios
                  onFoodSelected: (SelectedFoodItem selectedFood) {
                    targetList
                        .add(FoodItem.fromMap(selectedFood.foodItem.toMap()));
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

    mealGoal = widget.mealGoal;
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
          widget.mealGoal);
    } else if (controllerFatsMais ||
        controllerCarbsMais ||
        controllerProteinMais) {
      allSelectedFoodsWithQuantities = calculateFoodQuantitiesUmAMais(
          tempSelectedFoodsCarb,
          tempSelectedFoodsProtein,
          tempSelectedFoodsFat,
          widget.mealGoal);
    } else {
      allSelectedFoodsWithQuantities = calculateFoodQuantities(
          tempSelectedFoodsCarb,
          tempSelectedFoodsProtein,
          tempSelectedFoodsFat,
          widget.mealGoal);
    }

    // Apresenta a visão geral das quantidades de alimentos selecionados para confirmação
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
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  List<FoodItemWithQuantity> calculateQuantities(
      FoodItem carbs, FoodItem protein, FoodItem fats, MealGoal goal) {
    double currentProt = 0, currentCarb = 0, currentGord = 0;

    List<FoodItemWithQuantity> result = [];
    double porcMaisProt = goal.totalProtein * 1.05;
    double porcMaisCarb = goal.totalCarbs * 1.05;
    double porcMaisGord = goal.totalFats * 1.05;
    double porcMenosProt = goal.totalProtein * 0.95;
    double porcMenosCarb = goal.totalCarbs * 0.95;
    double porcMenosGord = goal.totalFats * 0.95;

    double protAlimentoProt = protein.protein / 100;
    double carbAlimentoProt = protein.carbs / 100;
    double gordAlimentoProt = protein.fats / 100;
    double totalProtAlimentoProt = 0;
    double totalCarbAlimentoProt = 0;
    double totalGordAlimentoProt = 0;
    double qntAlimentoProt = 0;

    double protAlimentoCarb = carbs.protein / 100;
    double carbAlimentoCarb = carbs.carbs / 100;
    double gordAlimentoCarb = carbs.fats / 100;
    double totalProtAlimentoCarb = 0;
    double totalCarbAlimentoCarb = 0;
    double totalGordAlimentoCarb = 0;
    double qntAlimentoCarb = 0;

    double protAlimentoGord = fats.protein / 100;
    double carbAlimentoGord = fats.carbs / 100;
    double gordAlimentoGord = fats.fats / 100;
    double totalProtAlimentoGord = 0;
    double totalCarbAlimentoGord = 0;
    double totalGordAlimentoGord = 0;
    double qntAlimentoGord = 0;

    void calculaAlimentoProt() {
      totalProtAlimentoProt = protAlimentoProt * qntAlimentoProt;
      totalCarbAlimentoProt = carbAlimentoProt * qntAlimentoProt;
      totalGordAlimentoProt = gordAlimentoProt * qntAlimentoProt;
    }

    void calculaAlimentoGord() {
      totalProtAlimentoGord = protAlimentoGord * qntAlimentoGord;
      totalCarbAlimentoGord = carbAlimentoGord * qntAlimentoGord;
      totalGordAlimentoGord = gordAlimentoGord * qntAlimentoGord;
    }

    void calculaAlimentoCarb() {
      totalProtAlimentoCarb = protAlimentoCarb * qntAlimentoCarb;
      totalCarbAlimentoCarb = carbAlimentoCarb * qntAlimentoCarb;
      totalGordAlimentoCarb = gordAlimentoCarb * qntAlimentoCarb;
    }

    void calculaProt() {
      currentProt =
          totalProtAlimentoProt + totalProtAlimentoCarb + totalProtAlimentoGord;
    }

    void calculaCarb() {
      currentCarb =
          totalCarbAlimentoGord + totalCarbAlimentoCarb + totalCarbAlimentoProt;
    }

    void calculaGord() {
      currentGord =
          totalGordAlimentoGord + totalGordAlimentoCarb + totalGordAlimentoProt;
    }

    void calculaTudo() {
      calculaCarb();
      calculaProt();
      calculaGord();
    }

    // double holderGord = goal.totalFats * 0.7;
    // qntAlimentoGord = holderGord / gordAlimentoGord;
    // calculaAlimentoGord();
    // calculaTudo();

    double holderProt = goal.totalProtein * 0.7;
    qntAlimentoProt = holderProt / protAlimentoProt;
    calculaAlimentoProt();
    calculaTudo();

    qntAlimentoGord = (goal.totalFats - currentGord) / gordAlimentoGord * 0.8;
    calculaAlimentoGord();
    calculaTudo();

    // qntAlimentoProt =
    //     ((goal.totalProtein - currentProt) / protAlimentoProt) * 0.9;
    // calculaAlimentoProt();
    // calculaTudo();

    qntAlimentoCarb = (goal.totalCarbs - currentCarb) / carbAlimentoCarb;
    calculaAlimentoCarb();
    calculaTudo();

    for (int i = 0; i < 4; i++) {
      // Carboidrato
      if (currentCarb > porcMaisCarb || currentCarb < porcMenosCarb) {
        if (currentCarb < porcMenosCarb) {
          qntAlimentoCarb = qntAlimentoCarb +
              ((goal.totalCarbs - currentCarb) / carbAlimentoCarb);
        } else {
          qntAlimentoCarb = qntAlimentoCarb -
              ((currentCarb - goal.totalCarbs) / carbAlimentoCarb);
        }
        qntAlimentoCarb = max(qntAlimentoCarb, 0);
        calculaAlimentoCarb();
        calculaTudo();
      }

      // Gordura
      if (currentGord > porcMaisGord || currentGord < porcMenosGord) {
        if (currentGord < porcMenosGord) {
          qntAlimentoGord = qntAlimentoGord +
              ((goal.totalFats - currentGord) / gordAlimentoGord);
        } else {
          qntAlimentoGord = qntAlimentoGord -
              ((currentGord - goal.totalFats) / gordAlimentoGord);
        }
        qntAlimentoGord = max(qntAlimentoGord, 0);
        calculaAlimentoGord();
        calculaTudo();
      }

      // Proteína
      if (currentProt > porcMaisProt || currentProt < porcMenosProt) {
        if (currentProt < porcMenosProt) {
          qntAlimentoProt = qntAlimentoProt +
              ((goal.totalProtein - currentProt) / protAlimentoProt);
        } else {
          qntAlimentoProt = qntAlimentoProt -
              ((currentProt - goal.totalProtein) / protAlimentoProt);
        }
        qntAlimentoProt = max(qntAlimentoProt, 0);
        calculaAlimentoProt();
        calculaTudo();
      }
    }

    result.add(
        FoodItemWithQuantity(foodItem: protein, quantity: qntAlimentoProt));
    result
        .add(FoodItemWithQuantity(foodItem: carbs, quantity: qntAlimentoCarb));
    result.add(FoodItemWithQuantity(foodItem: fats, quantity: qntAlimentoGord));

    return result;
  }

  bool verificaAliMaisUm(List macro) {
    return macro.length >= 2;
  }

  bool verificaAliMaisDois(List macro) {
    return macro.length == 3;
  }

  bool verificaAliMenos(List macro) {
    return macro.isEmpty;
  }

  List<FoodItem> funcListaVazia(List<FoodItem> lista, String nutrientType) {
    List<FoodItem> result = [];

    if (verificaAliMenos(lista)) {
      if (nutrientType == "proteina") {
        FoodItem foodItemVazio = FoodItem(
          name: 'Proteína',
          calories: 0,
          protein: 1,
          carbs: 0,
          fats: 0,
          quantity: 100,
          dominantNutrient: 'proteina',
        );
        result.add(foodItemVazio);
      } else if (nutrientType == "carboidrato") {
        FoodItem foodItemVazio = FoodItem(
          name: 'Carboidrato',
          calories: 0,
          protein: 0,
          carbs: 1,
          fats: 0,
          quantity: 100,
          dominantNutrient: 'carboidrato',
        );
        result.add(foodItemVazio);
      } else if (nutrientType == "gordura") {
        FoodItem foodItemVazio = FoodItem(
          name: 'Gordura',
          calories: 0,
          protein: 0,
          carbs: 0,
          fats: 1,
          quantity: 100,
          dominantNutrient: 'gordura',
        );
        result.add(foodItemVazio);
      }
    } else {
      result = lista;
    }
    return result;
  }

  List<FoodItemWithQuantity> calculateFoodQuantities(List<FoodItem> carbs,
      List<FoodItem> protein, List<FoodItem> fats, MealGoal goal) {
    List<FoodItemWithQuantity> result = [];
    protein = funcListaVazia(protein, "proteina");
    carbs = funcListaVazia(carbs, "carboidrato");
    fats = funcListaVazia(fats, "gordura");
    result = calculateQuantities(carbs[0], protein[0], fats[0], goal);
    result.removeWhere((item) =>
        item.foodItem.name == 'Carboidrato' ||
        item.foodItem.name == 'Proteína' ||
        item.foodItem.name == 'Gordura');
    return result;
  }

  List<FoodItemWithQuantity> calculateFoodQuantitiesUmAMais(
      List<FoodItem> carbs,
      List<FoodItem> protein,
      List<FoodItem> fats,
      MealGoal goal) {
    bool controllerProtein = false;
    bool controllerCarbs = false;
    bool controllerFats = false;

    List<FoodItemWithQuantity> resultUm = [];
    List<FoodItemWithQuantity> resultDois = [];
    List<FoodItemWithQuantity> result = [];

    MealGoal goalSessenta = MealGoal(
        totalCalories: goal.totalCalories * 0.60,
        totalProtein: goal.totalProtein * 0.60,
        totalCarbs: goal.totalCarbs * 0.60,
        totalFats: goal.totalFats * 0.60);

    MealGoal goalQuarenta = MealGoal(
        totalCalories: goal.totalCalories * 0.40,
        totalProtein: goal.totalProtein * 0.40,
        totalCarbs: goal.totalCarbs * 0.40,
        totalFats: goal.totalFats * 0.40);

    protein = funcListaVazia(protein, "proteina");
    carbs = funcListaVazia(carbs, "carboidrato");
    fats = funcListaVazia(fats, "gordura");

    controllerProtein = verificaAliMaisUm(protein);
    controllerCarbs = verificaAliMaisUm(carbs);
    controllerFats = verificaAliMaisUm(fats);
    if (!controllerProtein) {
      protein.add(protein[0]);
    }
    if (!controllerCarbs) {
      carbs.add(carbs[0]);
    }
    if (!controllerFats) {
      fats.add(fats[0]);
    }

    resultUm = calculateQuantities(carbs[0], protein[0], fats[0], goalSessenta);
    resultDois =
        calculateQuantities(carbs[1], protein[1], fats[1], goalQuarenta);
    resultUm.addAll(resultDois);

    Map<String, FoodItemWithQuantity> foodMap = {};

    for (var item in resultUm) {
      if (foodMap.containsKey(item.foodItem.name)) {
        foodMap[item.foodItem.name]?.quantity += item.quantity;
      } else {
        foodMap[item.foodItem.name] = item;
      }
    }

    result = foodMap.values.toList();
    result.removeWhere((item) =>
        item.foodItem.name == 'Carboidrato' ||
        item.foodItem.name == 'Proteína' ||
        item.foodItem.name == 'Gordura');
    return result;
  }

  List<FoodItemWithQuantity> calculateFoodQuantitiesDoisAMais(
      List<FoodItem> carbs,
      List<FoodItem> protein,
      List<FoodItem> fats,
      MealGoal goal) {
    bool controllerProtein = false;
    bool controllerCarbs = false;
    bool controllerFats = false;
    bool controllerDoisProtein = false;
    bool controllerDoisCarbs = false;
    bool controllerDoisFats = false;

    List<FoodItemWithQuantity> resultUm = [];
    List<FoodItemWithQuantity> resultDois = [];
    List<FoodItemWithQuantity> resultTres = [];
    List<FoodItemWithQuantity> result = [];

    MealGoal goalTrinta = MealGoal(
        totalCalories: goal.totalCalories * 0.30,
        totalProtein: goal.totalProtein * 0.30,
        totalCarbs: goal.totalCarbs * 0.30,
        totalFats: goal.totalFats * 0.30);

    MealGoal goalQuarenta = MealGoal(
        totalCalories: goal.totalCalories * 0.40,
        totalProtein: goal.totalProtein * 0.40,
        totalCarbs: goal.totalCarbs * 0.40,
        totalFats: goal.totalFats * 0.40);

    protein = funcListaVazia(protein, "proteina");
    carbs = funcListaVazia(carbs, "carboidrato");
    fats = funcListaVazia(fats, "gordura");

    controllerProtein = verificaAliMaisUm(protein);
    controllerCarbs = verificaAliMaisUm(carbs);
    controllerFats = verificaAliMaisUm(fats);
    controllerDoisProtein = verificaAliMaisDois(protein);
    controllerDoisCarbs = verificaAliMaisDois(carbs);
    controllerDoisFats = verificaAliMaisDois(fats);
    if (!controllerDoisProtein) {
      if (!controllerProtein) {
        protein.add(protein[0]);
      }
      protein.add(protein[1]);
    }
    if (!controllerDoisCarbs) {
      if (!controllerCarbs) {
        carbs.add(carbs[0]);
      }
      carbs.add(carbs[1]);
    }
    if (!controllerDoisFats) {
      if (!controllerFats) {
        fats.add(fats[0]);
      }
      fats.add(fats[1]);
    }

    resultUm = calculateQuantities(carbs[0], protein[0], fats[0], goalQuarenta);
    resultDois = calculateQuantities(carbs[1], protein[1], fats[1], goalTrinta);
    resultTres = calculateQuantities(carbs[2], protein[2], fats[2], goalTrinta);
    resultUm.addAll(resultDois);
    resultUm.addAll(resultTres);

    Map<String, FoodItemWithQuantity> foodMap = {};

    for (var item in resultUm) {
      if (foodMap.containsKey(item.foodItem.name)) {
        foodMap[item.foodItem.name]?.quantity += item.quantity;
      } else {
        foodMap[item.foodItem.name] = item;
      }
    }

    result = foodMap.values.toList();
    result.removeWhere((item) =>
        item.foodItem.name == 'Carboidrato' ||
        item.foodItem.name == 'Proteína' ||
        item.foodItem.name == 'Gordura');
    return result;
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
                          showRefeicaoDialog(numRef);
                        } else if (value == 'remove') {
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
                          value: 'addOwn',
                          child: Text('Adicionar Alimento Próprio'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'remove',
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
