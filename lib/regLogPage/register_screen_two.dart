import 'package:complete/hive/hive_refeicao.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complete/hive/hive_user.dart';
import 'package:hive/hive.dart';
import 'package:complete/homePage/homePageItems/nutrition_service.dart';
import 'package:complete/homePage/classes.dart';
import 'package:complete/hive/hive_meal_goal.dart';
import 'package:provider/provider.dart';

class RegistroParteDois extends StatefulWidget {
  const RegistroParteDois({super.key});

  @override
  _RegistroParteDoisState createState() => _RegistroParteDoisState();
}

class _RegistroParteDoisState extends State<RegistroParteDois> {
  int _numRefeicoes = 2;
  int _refeicaoPosTreino = 0;
  double _multiplicadorProt = 1;
  double _multiplicadorGord = 1;
  String _nivelAtividade = '';
  String _objetivo = '';
  String textoObjetivo = '';
  String textoNivelAtividade = '';
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  bool _isLoading = false;
  bool _readOnlyPeso = false;
  bool _readOnlyAltura = false;
  Map<String, dynamic> initialData = {};

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  final NutritionService nutritionService = NutritionService();

  void _showObjetivoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione seu objetivo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RadioListTile<String>(
                  title: const Text('Perder peso'),
                  value: 'perderPeso',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                      textoObjetivo = "Perder peso";
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Manter peso'),
                  value: 'manterPeso',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                      textoObjetivo = "Manter peso";
                    });
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Ganhar peso'),
                  value: 'ganharPeso',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                      textoObjetivo = "Ganhar peso";
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _textoObjetivo(objetivo) {
    if (_objetivo == 'perderPeso') {
      textoObjetivo = "Perder peso";
    } else if (_objetivo == 'manterPeso') {
      textoObjetivo = "Manter peso";
    } else if (_objetivo == 'ganharPeso') {
      textoObjetivo = "Ganhar peso";
    }
  }

  void _showAtividadeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione seu nível de atividade física'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: const Text('Sedentário'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'sedentario';
                      textoNivelAtividade = "Sedentário";
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                      'Levemente ativo (Atividade 1-3 dias por semana)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'atividadeLeve';
                      textoNivelAtividade = "Levemente ativo";
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                      'Moderadamente ativo (Atividade 3-5 vezes por semana)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'atividadeModerada';
                      textoNivelAtividade = "Moderadamente ativo";
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Ativo (Atividade de 6-7 dias na semana)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'muitoAtivo';
                      textoNivelAtividade = "Ativo";
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                      'Extremamente Ativo (Trabalho braçal mais atividade pesada ou atividade pesada 2x ao dia)'),
                  onTap: () {
                    setState(() {
                      _nivelAtividade = 'extremamenteAtivo';
                      textoNivelAtividade = "Extremamente Ativo";
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _textoNivelAtividade(nivelAtividade) {
    if (_nivelAtividade == 'sedentario') {
      textoNivelAtividade = "Sedentário";
    } else if (_nivelAtividade == 'atividadeLeve') {
      textoNivelAtividade = "Levemente ativo";
    } else if (_nivelAtividade == 'atividadeModerada') {
      textoNivelAtividade = "Moderadamente ativo";
    } else if (_nivelAtividade == 'muitoAtivo') {
      textoNivelAtividade = "Ativo";
    } else if (_nivelAtividade == 'extremamenteAtivo') {
      textoNivelAtividade = "Extremamente Ativo";
    }
  }

  double calcularTMB(String genero, double peso, double altura, int idade) {
    if (genero == 'masculino') {
      return 66 + (13.8 * peso) + (5.0 * altura) - (6.8 * idade);
    } else {
      return 655 + (9.6 * peso) + (1.9 * altura) - (4.7 * idade);
    }
  }

  void _showRefeicaoPosTreinoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione a refeição pós-treino'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _numRefeicoes,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('Refeição ${index + 1}'),
                  onTap: () {
                    setState(() {
                      _refeicaoPosTreino = index + 1;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _cadastrarDados() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        // Pega os dados necessários do usuário
        String genero = userData['genero'];
        String nome = userData['nome'];
        double peso = double.tryParse(_pesoController.text) ?? 0.0;
        double altura = double.tryParse(_alturaController.text) ?? 0.0;
        DateTime dataNascimento =
            (userData['dataNascimento'] as Timestamp).toDate();
        int idade = int.tryParse(userData['idade'].toString()) ?? 0;
        int numRefeicoes = int.tryParse(_numRefeicoes.toString()) ?? 0;
        double multiplicadorProt =
            double.tryParse(_multiplicadorProt.toString()) ?? 0.0;
        double multiplicadorGord =
            double.tryParse(_multiplicadorGord.toString()) ?? 0.0;
        String nivelAtividade = _nivelAtividade;
        String objetivo = _objetivo;
        int refeicaoPosTreino =
            int.tryParse(_refeicaoPosTreino.toString()) ?? 0;

        double tmb = calcularTMB(genero, peso, altura, idade);

        final now = DateTime.now();
        DateTime lastFeedbackDate;

        if (now.hour < 10) {
          lastFeedbackDate = DateTime(now.year, now.month, now.day);
        } else {
          final nextDay = now.add(const Duration(days: 1));
          lastFeedbackDate = DateTime(nextDay.year, nextDay.month, nextDay.day);
        }

        DateTime lastObjectiveChange = DateTime(now.year, now.month, now.day);

        HiveUser newUser = HiveUser(
            altura: altura,
            idade: idade,
            dataNascimento: dataNascimento,
            multiplicadorGord: multiplicadorGord,
            multiplicadorProt: multiplicadorProt,
            numRefeicoes: numRefeicoes,
            peso: peso,
            nivelAtividade: nivelAtividade,
            objetivo: objetivo,
            refeicaoPosTreino: refeicaoPosTreino,
            tmb: tmb,
            nome: nome,
            genero: genero,
            lastFeedbackDate: lastFeedbackDate,
            lastObjectiveChange: lastObjectiveChange);

        MealGoal goal = NutritionService().calculateNutritionalGoals(newUser);

        newUser.macrosDiarios = HiveMealGoal(
          totalCalories: goal.totalCalories,
          totalProtein: goal.totalProtein,
          totalCarbs: goal.totalCarbs,
          totalFats: goal.totalFats,
        );

        newUser.macrosRef = nutritionService.calculateRefGoals(newUser);

        // Salva no Hive
        final userBox = Hive.box<HiveUser>('userBox');
        await userBox.put(uid, newUser);

        // Atualiza os dados no Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'tmb': tmb,
          'numRefeicoes': numRefeicoes,
          'nivelAtividade': nivelAtividade,
          'objetivo': objetivo,
          'multiplicadorProt': multiplicadorProt,
          'multiplicadorGord': multiplicadorGord.toStringAsFixed(1),
          'peso': peso,
          'altura': altura,
          'refeicaoPosTreino': refeicaoPosTreino,
          'lastFeedbackDate': Timestamp.fromDate(lastFeedbackDate),
          'lastObjectiveChange': Timestamp.fromDate(lastObjectiveChange),
          'regDois': true
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dados cadastrados com sucesso!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cadastrar dados: $error')),
          );
        });
      }
    }
  }

  Future<void> _updateDados() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userBox = Hive.box<HiveUser>('userBox');
      HiveUser? existingUser = userBox.get(uid);

      if (existingUser != null) {
        bool hasDataChanged = _hasDataChanged();

        if (hasDataChanged) {
          final now = DateTime.now();
          DateTime lastFeedbackDate;

          if (now.hour < 10) {
            lastFeedbackDate = DateTime(now.year, now.month, now.day);
          } else {
            final nextDay = now.add(const Duration(days: 1));
            lastFeedbackDate =
                DateTime(nextDay.year, nextDay.month, nextDay.day);
          }

          if (existingUser.objetivo != _objetivo) {
            DateTime? lastObjectiveChange = existingUser.lastObjectiveChange;
            if (lastObjectiveChange != null &&
                now.difference(lastObjectiveChange).inDays < 60) {
              _showConfirmationDialog(() async {
                MealGoal updatedGoals = nutritionService.updateNutritionObj(
                    existingUser, _objetivo);
                existingUser.lastObjectiveChange =
                    DateTime(now.year, now.month, now.day);

                existingUser.macrosDiarios = HiveMealGoal(
                  totalCalories: updatedGoals.totalCalories,
                  totalProtein: updatedGoals.totalProtein,
                  totalCarbs: updatedGoals.totalCarbs,
                  totalFats: updatedGoals.totalFats,
                );

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                  'macrosDiarios': {
                    'totalCalories': updatedGoals.totalCalories,
                    'totalProtein': updatedGoals.totalProtein,
                    'totalCarbs': updatedGoals.totalCarbs,
                    'totalFats': updatedGoals.totalFats,
                  },
                  'lastObjectiveChange': Timestamp.fromDate(now),
                });

                await _updateUserDetails(existingUser, lastFeedbackDate);
              });
              return;
            } else {
              MealGoal updatedGoals =
                  nutritionService.updateNutritionObj(existingUser, _objetivo);
              existingUser.lastObjectiveChange =
                  DateTime(now.year, now.month, now.day);

              existingUser.macrosDiarios = HiveMealGoal(
                totalCalories: updatedGoals.totalCalories,
                totalProtein: updatedGoals.totalProtein,
                totalCarbs: updatedGoals.totalCarbs,
                totalFats: updatedGoals.totalFats,
              );

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({
                'macrosDiarios': {
                  'totalCalories': updatedGoals.totalCalories,
                  'totalProtein': updatedGoals.totalProtein,
                  'totalCarbs': updatedGoals.totalCarbs,
                  'totalFats': updatedGoals.totalFats,
                },
                'lastObjectiveChange': Timestamp.fromDate(now),
              });
            }
          }

          if (existingUser.nivelAtividade != _nivelAtividade) {
            MealGoal updatedGoals = nutritionService
                .updateNutritionOnActivityChange(existingUser, _nivelAtividade);

            existingUser.macrosDiarios = HiveMealGoal(
              totalCalories: updatedGoals.totalCalories,
              totalProtein: updatedGoals.totalProtein,
              totalCarbs: updatedGoals.totalCarbs,
              totalFats: updatedGoals.totalFats,
            );

            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .update({
              'nivelAtividade': _nivelAtividade,
              'macrosDiarios': {
                'totalCalories': updatedGoals.totalCalories,
                'totalProtein': updatedGoals.totalProtein,
                'totalCarbs': updatedGoals.totalCarbs,
                'totalFats': updatedGoals.totalFats,
              },
            });
          }

          await _updateUserDetails(existingUser, lastFeedbackDate);
        }
      } else {
        await _cadastrarDados();
      }
    }
  }

  Future<void> _updateUserDetails(
      HiveUser existingUser, DateTime lastFeedbackDate) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userBox = Hive.box<HiveUser>('userBox');

    existingUser
      ..peso = double.tryParse(_pesoController.text) ?? existingUser.peso
      ..altura = double.tryParse(_alturaController.text) ?? existingUser.altura
      ..numRefeicoes = _numRefeicoes
      ..nivelAtividade = _nivelAtividade
      ..objetivo = _objetivo
      ..multiplicadorProt = _multiplicadorProt
      ..multiplicadorGord = _multiplicadorGord
      ..refeicaoPosTreino = _refeicaoPosTreino
      ..lastFeedbackDate = lastFeedbackDate;

    await userBox.put(uid, existingUser);

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'peso': existingUser.peso,
      'altura': existingUser.altura,
      'numRefeicoes': existingUser.numRefeicoes,
      'nivelAtividade': existingUser.nivelAtividade,
      'objetivo': existingUser.objetivo,
      'multiplicadorProt': existingUser.multiplicadorProt,
      'multiplicadorGord': existingUser.multiplicadorGord.toStringAsFixed(1),
      'refeicaoPosTreino': existingUser.refeicaoPosTreino,
      'lastFeedbackDate': Timestamp.fromDate(lastFeedbackDate),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar dados: $error')),
      );
    });
  }

  void _showConfirmationDialog(Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: const Text(
              'Você alterou seu objetivo recentemente. A gente recomenda manter por pelo menos dois meses para alterá-lo novamente. Deseja prosseguir mesmo assim?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData().then((_) {
      initialData = {
        'peso': _pesoController.text,
        'altura': _alturaController.text,
        'numRefeicoes': _numRefeicoes,
        'nivelAtividade': _nivelAtividade,
        'objetivo': _objetivo,
        'multiplicadorProt': _multiplicadorProt,
        'multiplicadorGord': _multiplicadorGord,
        'refeicaoPosTreino': _refeicaoPosTreino,
      };
    });
  }

  bool _hasDataChanged() {
    return _pesoController.text != initialData['peso'] ||
        _alturaController.text != initialData['altura'] ||
        _numRefeicoes != initialData['numRefeicoes'] ||
        _nivelAtividade != initialData['nivelAtividade'] ||
        _objetivo != initialData['objetivo'] ||
        _multiplicadorProt != initialData['multiplicadorProt'] ||
        _multiplicadorGord != initialData['multiplicadorGord'] ||
        _refeicaoPosTreino != initialData['refeicaoPosTreino'];
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userBox = Hive.box<HiveUser>('userBox');
      HiveUser? user = userBox.get(uid);
      if (user != null) {
        _pesoController.text = user.peso.toString();
        _alturaController.text = user.altura.toString();
        _numRefeicoes = user.numRefeicoes;
        _nivelAtividade = user.nivelAtividade;
        _textoNivelAtividade(_nivelAtividade);
        _objetivo = user.objetivo;
        _textoObjetivo(_objetivo);
        _multiplicadorProt = user.multiplicadorProt;
        _multiplicadorGord = user.multiplicadorGord;
        _refeicaoPosTreino = user.refeicaoPosTreino;
        _readOnlyPeso = user.peso != 0;
        _readOnlyAltura = (user.altura != 0 && user.idade >= 21);
        setState(() {});
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _alturaController,
                  enabled:
                      !_readOnlyAltura, // Controle de edição baseado em idade e dados existentes
                  decoration: const InputDecoration(
                      labelText: 'Altura (cm)', hintText: 'Digite sua altura'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua altura';
                    }
                    final altura = double.tryParse(value);
                    if (altura == null) {
                      return 'Por favor, insira um número válido!';
                    } else if (altura < 50 || altura > 300) {
                      return 'Altura inválida!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pesoController,
                  enabled:
                      !_readOnlyPeso, // Controle de edição baseado em dados existentes
                  decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      hintText: 'Digite seu peso atual'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu peso';
                    }
                    final peso = double.tryParse(value.replaceAll(',', '.'));
                    if (peso == null) {
                      return 'Por favor, insira um número válido';
                    } else if (peso < 15 || peso > 300) {
                      return 'O peso deve estar entre 15kg e 300kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Quantas refeições você quer fazer por dia?'),
                Slider(
                  min: 2,
                  max: 7,
                  divisions: 5,
                  label: '$_numRefeicoes',
                  value: _numRefeicoes.toDouble(),
                  onChanged: (double value) {
                    setState(() {
                      _numRefeicoes = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text('Refeição pós treino:'),
                ElevatedButton(
                  onPressed: _showRefeicaoPosTreinoDialog,
                  child: Text(_refeicaoPosTreino == 0
                      ? 'Selecionar'
                      : 'Refeição $_refeicaoPosTreino'),
                ),
                const SizedBox(height: 20),
                const Text('Nível de atividade física:'),
                ElevatedButton(
                  onPressed: _showAtividadeDialog,
                  child: Text(_nivelAtividade.isEmpty
                      ? 'Selecionar'
                      : textoNivelAtividade),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                      child: Text('Objetivo:'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _showObjetivoDialog,
                  child: Text(_objetivo.isEmpty ? 'Selecionar' : textoObjetivo),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                          'Quantos gramas de proteína por KG você quer comer?'),
                    ),
                    Tooltip(
                      message:
                          'Para dieta de perda de peso, recomendamos a utilização de 2.0 a 2.5 gramas de proteína por KG para praticantes de musculação, e 1.2 a 1.5 para não praticantes. Para dietas de ganhar e manter peso, recomendamos 1.8 a 2.2 gramas de proteína por KG para praticantes de musculação, e 1 a 1.2 para não praticantes.',
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(color: Colors.white),
                      child: Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                Slider(
                  min: 1,
                  max: 5,
                  divisions: 40,
                  label: '$_multiplicadorProt',
                  value: _multiplicadorProt,
                  onChanged: (double value) {
                    setState(() {
                      _multiplicadorProt = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                          'Quantos gramas de gordura por KG você quer comer?'),
                    ),
                    Tooltip(
                      message:
                          'Recomendamos a utilização de 0.8 a 1.2 gramas de gordura por KG.',
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(color: Colors.white),
                      child: Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                Slider(
                  min: 0.3,
                  max: 1.5,
                  divisions: 12,
                  label: _multiplicadorGord.toStringAsFixed(1),
                  value: _multiplicadorGord,
                  onChanged: (double value) {
                    setState(() {
                      _multiplicadorGord = value;
                    });
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(
                        16.0), // Ajuste o padding conforme necessário
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _updateDados();

                                if (_hasDataChanged()) {
                                  Box<HiveRefeicao> refeicaoBox =
                                      Provider.of<Box<HiveRefeicao>>(context,
                                          listen: false);

                                  bool checkForModifiedItems() {
                                    return refeicaoBox.values
                                        .any((refeicao) => refeicao.modified);
                                  }

                                  if (refeicaoBox.isNotEmpty &&
                                      checkForModifiedItems()) {
                                    refeicaoBox.clear();
                                  }
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading
                            ? Colors.blueGrey
                            : Theme.of(context)
                                .colorScheme
                                .primary, // Cor de fundo do botão
                        foregroundColor:
                            Colors.white, // Cor do texto e ícones do botão
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Confirmar'), // Texto exibido no botão
                    ),
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}
