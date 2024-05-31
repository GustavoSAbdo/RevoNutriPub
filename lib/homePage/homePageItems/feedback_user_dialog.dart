import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';
import 'package:complete/homePage/drawerItems/meal_goal_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:complete/hive/hive_user.dart';
import 'package:provider/provider.dart';

class FeedbackUserDialog extends StatefulWidget {
  @override
  _FeedbackUserDialogState createState() => _FeedbackUserDialogState();
}

class _FeedbackUserDialogState extends State<FeedbackUserDialog> {
  final TextEditingController _pesoController = TextEditingController();

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

  HiveUser? getUser() {
    final Box<HiveUser> userBox = Hive.box<HiveUser>('userBox');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return userBox.get(uid);
  }

  @override
  Widget build(BuildContext context) {
    final HiveUser? currentUser = getUser();

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showFeedbackDialog(currentUser);
    });

    return const SizedBox
        .shrink(); // Retorna um widget vazio, pois a UI é tratada pelo dialog.
  }

  Future<void> showFeedbackDialog(HiveUser currentUser) async {
    final dialogData = getDialogData(currentUser);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogData['title']),
          content: SingleChildScrollView(
            child: ListBody(children: dialogData['content']),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                showCancelConfirmationDialog();
              },
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                dialogData['updateFunction']();
                updateLastFeedbackDate();
              },
              child: const Text('Atualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showCancelConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(''),
          content:
              const Text('Você realmente deseja pular a atualização do peso?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                updateLastFeedbackDate();
                Navigator.of(context).pop(); // Fecha a confirmação
                Navigator.of(context).pop(); // Fecha o diálogo de feedback
                Navigator.pushNamed(context, '/home');
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> getDialogData(HiveUser currentUser) {
    String title = '';
    List<Widget> content = [];
    Function updateFunction;
    String feedbackText = '';

    switch (currentUser.objetivo) {
      case 'perderPeso':
        title = 'Atualização de Emagrecimento';
        feedbackText =
            'conte-nos como foram seus resultados de emagrecimento nessas últimas semanas.';
        updateFunction = () => updateForWeightLoss();
        content = [
          Text(
              'Oi ${toTitleCase(toTitleCase(currentUser.nome))}, $feedbackText'),
          TextField(
            controller: _pesoController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Digite seu peso atual:'),
          ),
          const SizedBox(height: 20),
        ];
        break;
      case 'manterPeso':
        title = 'Feedback de Manutenção de Peso';
        feedbackText =
            'conte-nos como foram seus resultados de manutenção de peso nessas últimas semanas.';
        updateFunction = () => updateForWeightMaintenance();
        content = [
          Text(
              'Oi ${toTitleCase(toTitleCase(currentUser.nome))}, $feedbackText'),
          TextField(
            controller: _pesoController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Digite seu peso atual:'),
          ),
          const SizedBox(height: 20),
        ];
        break;
      case 'ganharPeso':
        title = 'Feedback de Ganho de Peso';
        feedbackText =
            'conte-nos como foram seus resultados de ganho de peso nessas últimas semanas.';
        updateFunction = () => updateForWeightGain();
        content = [
          Text(
              'Oi ${toTitleCase(toTitleCase(currentUser.nome))}, $feedbackText'),
          TextField(
            controller: _pesoController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Digite seu peso atual:'),
          ),
          const SizedBox(height: 20),
        ];
        break;
      default:
        return {};
    }

    return {
      'title': title,
      'content': content,
      'updateFunction': updateFunction,
    };
  }

  Future<void> updateLastFeedbackDate() async {
    final Box<HiveUser> userBox = Hive.box<HiveUser>('userBox');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      HiveUser? user = userBox.get(uid);
      if (user != null) {
        final now = DateTime.now();
        DateTime normalizedNow;

        if (now.hour < 10) {
          // Se a hora atual é antes das 10h, salva a data de hoje às 00h
          normalizedNow = DateTime(now.year, now.month, now.day);
        } else {
          // Se a hora atual é após as 10h, salva a data do dia seguinte às 00h
          final nextDay = now.add(const Duration(days: 1));
          normalizedNow = DateTime(nextDay.year, nextDay.month, nextDay.day);
        }

        user.lastFeedbackDate = normalizedNow;
        await userBox.put(uid, user);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'lastFeedbackDate': Timestamp.fromDate(normalizedNow)});
      }
    }
  }

  Future<void> saveUserData(currentUser, pesoNovo, carbs, attKcal) async {
    final Box<HiveUser> userBox = Hive.box<HiveUser>('userBox');
    print('CAIU NO SAVE 1');

    final uid = FirebaseAuth.instance.currentUser?.uid;
    userBox.put(uid, currentUser);
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'peso': pesoNovo,
        'macrosDiarios.totalCalories': attKcal,
        'macrosDiarios.totalCarbs': carbs,
      });
    }
  }

  Future<void> saveUserDataTwo(pesoNovo) async {
    print('CAIU NO SAVE 2');
    final userBox = Hive.box<HiveUser>('userBox');
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      HiveUser? hiveUser = userBox.get(uid);

      if (hiveUser != null) {
        hiveUser.peso = pesoNovo;
        await userBox.put(uid, hiveUser);
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'peso': pesoNovo,
      });
    }
  }

  Future<void> updateForWeightLoss() async {
    final currentUser = getUser();
    if (currentUser != null) {
      double pesoNovo = double.tryParse(_pesoController.text) ?? 0.0;
      double resultado = currentUser.peso - pesoNovo;
      double attKcal;
      double attCarbs;
      String feedbackMessage;
      late String feedbackMessageTwo;

      if (resultado < -0.5) {
        feedbackMessage =
            "${toTitleCase(toTitleCase(currentUser.nome))}, você ganhou peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa perder peso de maneira saudável.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 0.9;
        attCarbs = currentUser.macrosDiarios!.totalCarbs -
            (currentUser.macrosDiarios!.totalCalories - attKcal) / 4;
      } else if (resultado > 0.5 && resultado < 2.5) {
        feedbackMessage =
            "Parabéns ${toTitleCase(currentUser.nome)}, você perdeu $resultado kgs.";
        feedbackMessageTwo = " Estamos felizes por você. Continue assim!";
        attKcal = currentUser.macrosDiarios!.totalCalories;
        attCarbs = currentUser.macrosDiarios!.totalCarbs;
      } else if (resultado >= 2.5) {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você perdeu muito peso rapidamente.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa perder peso de maneira saudável.";   
        attKcal = currentUser.macrosDiarios!.totalCalories * 1.1;
        attCarbs = currentUser.macrosDiarios!.totalCarbs +
            (attKcal - currentUser.macrosDiarios!.totalCalories) / 4;
      } else if (resultado < 0 && resultado > -0.5) {
        feedbackMessage =
            "${toTitleCase(toTitleCase(currentUser.nome))}, você ganhou peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa perder peso de maneira saudável.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 0.95;
        attCarbs = currentUser.macrosDiarios!.totalCarbs -
            (currentUser.macrosDiarios!.totalCalories - attKcal) / 4;
      } else {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você perdeu peso de forma bem ligeira.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa perder peso de maneira saudável.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 0.95;
        attCarbs = currentUser.macrosDiarios!.totalCarbs -
            (currentUser.macrosDiarios!.totalCalories - attKcal) / 4;
      }

      final mealGoalData = Provider.of<MealGoalData>(context, listen: false);

      currentUser.peso = pesoNovo;
      currentUser.macrosDiarios!.totalCalories = attKcal;
      currentUser.macrosDiarios!.totalCarbs = attCarbs;

      if (!mealGoalData.hasCustomMacros()) {
        await saveUserData(currentUser, pesoNovo, attCarbs, attKcal);
        showAlertDialog(feedbackMessage, feedbackMessageTwo);
      } else {
        await saveUserDataTwo(pesoNovo);
        feedbackMessageTwo = " Como você está manuseando seus macros, não iremos fazer nenhuma alteração.";
        showAlertDialog(feedbackMessage, feedbackMessageTwo);
      }
    }
  }

  Future<void> updateForWeightMaintenance() async {
    final currentUser = getUser();
    if (currentUser != null) {
      double pesoNovo = double.tryParse(_pesoController.text) ?? 0.0;
      double resultado = currentUser.peso - pesoNovo;
      double attKcal;
      double attCarbs;
      String feedbackMessage;
      late String feedbackMessageTwo;

      if (resultado > -0.5 && resultado < 0.5) {
        feedbackMessage =
            "Parabéns ${toTitleCase(currentUser.nome)}, você manteve seu peso com sucesso!";
        feedbackMessageTwo = " Pequenas variações são normais.";
        attKcal = currentUser.macrosDiarios!.totalCalories;
        attCarbs = currentUser.macrosDiarios!.totalCarbs;
      } else if (resultado <= -0.5 && resultado > -1) {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você ganhou um pouco de peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa manter o peso.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 0.95;
        attCarbs = currentUser.macrosDiarios!.totalCarbs -
            (currentUser.macrosDiarios!.totalCalories - attKcal) / 4;
      } else if (resultado <= -1) {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você ganhou muito peso.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 0.9;
        attCarbs = currentUser.macrosDiarios!.totalCarbs -
            (currentUser.macrosDiarios!.totalCalories - attKcal) / 4;
      } else if (resultado > 1) {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você perdeu um pouco de peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa manter o peso.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 1.05;
        attCarbs = currentUser.macrosDiarios!.totalCarbs +
            (attKcal - currentUser.macrosDiarios!.totalCalories) / 4;
      } else {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você perdeu muito peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa manter o peso.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 1.1;
        attCarbs = currentUser.macrosDiarios!.totalCarbs +
            (attKcal - currentUser.macrosDiarios!.totalCalories) / 4;
      }

      final mealGoalData = Provider.of<MealGoalData>(context, listen: false);

      currentUser.peso = pesoNovo;
      currentUser.macrosDiarios!.totalCalories = attKcal;
      currentUser.macrosDiarios!.totalCarbs = attCarbs;

      if (!mealGoalData.hasCustomMacros()) {
        await saveUserData(currentUser, pesoNovo, attCarbs, attKcal);
        showAlertDialog(feedbackMessage, feedbackMessageTwo);
      } else {
        await saveUserDataTwo(pesoNovo);
        feedbackMessageTwo = " Como você está manuseando seus macros, não iremos fazer nenhuma alteração.";
        showAlertDialog(feedbackMessage, feedbackMessageTwo);
      }
    }
  }

  Future<void> updateForWeightGain() async {
    final currentUser = getUser();
    if (currentUser != null) {
      double pesoNovo = double.tryParse(_pesoController.text) ?? 0.0;
      double resultado = pesoNovo - currentUser.peso;
      double attKcal;
      double attCarbs;
      String feedbackMessage;
      late String feedbackMessageTwo;

      if (resultado < 0 && resultado > -1) {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você perdeu um pouco de peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa ganhar peso da melhor forma.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 1.05;
        attCarbs = currentUser.macrosDiarios!.totalCarbs +
            (attKcal - currentUser.macrosDiarios!.totalCalories) / 4;
      } else if (resultado < -1) {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você perdeu muito peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa ganhar peso da melhor forma.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 1.1;
        attCarbs = currentUser.macrosDiarios!.totalCarbs +
            (attKcal - currentUser.macrosDiarios!.totalCalories) / 4;
      } else if (resultado >= 0 && resultado <= 1.2) {
        feedbackMessage =
            "Parabéns ${toTitleCase(currentUser.nome)}, você ganhou $resultado kgs.";
        feedbackMessageTwo = ' Estamos felizes por você. Continue assim!';
        attKcal = currentUser.macrosDiarios!.totalCalories;
        attCarbs = currentUser.macrosDiarios!.totalCarbs;
      } else if (resultado > 1.2 && resultado < 1.5) {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você ganhou peso ligeiramente maior do que o esperado.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa ganhar peso da melhor forma.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 0.95;
        attCarbs = currentUser.macrosDiarios!.totalCarbs +
            (attKcal - currentUser.macrosDiarios!.totalCalories) / 4;
      } else {
        feedbackMessage =
            "${toTitleCase(currentUser.nome)}, você ganhou muito peso.";
        feedbackMessageTwo = " Vamos ajustar sua ingestão calórica para que possa ganhar peso da melhor forma.";
        attKcal = currentUser.macrosDiarios!.totalCalories * 0.9;
        attCarbs = currentUser.macrosDiarios!.totalCarbs +
            (attKcal - currentUser.macrosDiarios!.totalCalories) / 4;
      }

      final mealGoalData = Provider.of<MealGoalData>(context, listen: false);

      currentUser.peso = pesoNovo;
      currentUser.macrosDiarios!.totalCalories = attKcal;
      currentUser.macrosDiarios!.totalCarbs = attCarbs;

      if (!mealGoalData.hasCustomMacros()) {
        await saveUserData(currentUser, pesoNovo, attCarbs, attKcal);
        showAlertDialog(feedbackMessage, feedbackMessageTwo);
      } else {
        await saveUserDataTwo(pesoNovo);
        feedbackMessageTwo = " Como você está manuseando seus macros, não iremos fazer nenhuma alteração.";
        showAlertDialog(feedbackMessage, feedbackMessageTwo);
      }
    }
  }

  void showAlertDialog(String message, String messageTwo) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Feedback'),
        content: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(message)),
              Expanded(child: Text(messageTwo)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              var box = Hive.box<HiveMealGoalList>('mealGoalListBox');
              var mealGoalsList =
                  box.get('mealGoalsList'); // Fecha o diálogo de feedback
              if (mealGoalsList != null &&
                  mealGoalsList.mealGoals.isNotEmpty) {
                Navigator.pushReplacementNamed(context, '/macrosRefPage');
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
        ],
      );
    },
  );
}

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }
}
