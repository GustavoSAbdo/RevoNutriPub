import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:complete/hive/hive_user.dart';

class FeedbackUserDialog extends StatefulWidget {
  @override
  _FeedbackUserDialogState createState() => _FeedbackUserDialogState();
}

class _FeedbackUserDialogState extends State<FeedbackUserDialog> {
  final TextEditingController _weightController = TextEditingController();
  bool? _feltChange;

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
    final Box<HiveUser> userBox = Hive.box<HiveUser>('userBox');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final HiveUser? currentUser = userBox.get(uid);

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    Future<void> showFeedbackDialog() async {
      String title = '';
      List<Widget> content = [];
      Function updateFunction;

      switch (currentUser.objetivo) {
        case 'perderPeso':
        case 'perderPesoAgressivamente':
          title = 'Atualização de Emagrecimento';
          content = [
            Text(
                'Oi ${toTitleCase(currentUser.nome)}, conte-nos como foram seus resultados de emagrecimento nessas duas últimas semanas.'),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Digite seu peso atual:'),
            ),
            const SizedBox(height: 20),
            const Text('No espelho, você se sentiu mais magro(a)?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    title: const Text('Sim'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _feltChange,
                      onChanged: (bool? value) {
                        setState(() {
                          _feltChange = value;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Não'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _feltChange,
                      onChanged: (bool? value) {
                        setState(() {
                          _feltChange = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ];
          updateFunction = () => updateForWeightLoss();
          break;
        case 'manterPeso':
          title = 'Feedback de Manutenção de Peso';
          content = [
            const Text(
                'Como você se sentiu mantendo seu peso? Alguma dificuldade?'),
            ListTile(
              title: const Text('Você sente que manteve seu peso estável?'),
              leading: Checkbox(
                value: _feltChange ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    _feltChange = value;
                  });
                },
              ),
            ),
          ];
          updateFunction = () => updateForWeightMaintenance();
          break;
        case 'ganharPeso':
        case 'ganharPesoAgressivamente':
          title = 'Feedback de Ganho de Peso';
          content = [
            Text(
                'Oi ${currentUser.nome}, como foi seu progresso em ganhar peso?'),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Digite seu peso atual:'),
            ),
            ListTile(
              title:
                  const Text('Você sente que ganhou massa muscular ou peso?'),
              leading: Checkbox(
                value: _feltChange ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    _feltChange = value;
                  });
                },
              ),
            ),
          ];
          updateFunction = () => updateForWeightGain();
          break;
        default:
          return;
      }

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(children: content),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/home');
                },
              ),
              TextButton(
                child: const Text('Atualizar'),
                onPressed: () {
                  updateFunction();
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/home');
                },
              ),
            ],
          );
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showFeedbackDialog();
    });

    return const SizedBox
        .shrink(); // Retorna um widget vazio, pois a UI é tratada pelo dialog.
  }

  void updateForWeightLoss() {
    // Lógica para atualizar dados após feedback de perda de peso
    print('Atualizando dados para perda de peso...');
  }

  void updateForWeightMaintenance() {
    // Lógica para atualizar dados após feedback de manutenção de peso
    print('Atualizando dados para manutenção de peso...');
  }

  void updateForWeightGain() {
    // Lógica para atualizar dados após feedback de ganho de peso
    print('Atualizando dados para ganho de peso...');
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
}
