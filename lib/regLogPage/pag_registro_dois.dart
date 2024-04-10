import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

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
                  title: const Text('Perder peso agressivamente'),
                  value: 'perderPesoAgressivamente',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                      textoObjetivo = "Perder peso agressivamente";
                    });
                    Navigator.pop(context);
                  },
                ),
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
                RadioListTile<String>(
                  title: const Text('Ganhar peso agressivamente'),
                  value: 'ganharPesoAgressivamente',
                  groupValue: _objetivo,
                  onChanged: (value) {
                    setState(() {
                      _objetivo = value!;
                      textoObjetivo = "Ganhar peso agressivamente";
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
    if (_objetivo == 'perderPesoAgressivamente') {
      textoObjetivo = "Perder peso agressivamente";
    } else if (_objetivo == 'perderPeso') {
      textoObjetivo = "Perder peso";
    } else if (_objetivo == 'manterPeso') {
      textoObjetivo = "Manter peso";
    } else if (_objetivo == 'ganharPeso') {
      textoObjetivo = "Ganhar peso";
    } else if (_objetivo == 'ganharPesoAgressivamente') {
      textoObjetivo = "Ganhar peso agressivamente";
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
        double peso = double.tryParse(_pesoController.text) ?? 0.0;
        double altura = double.tryParse(_alturaController.text) ?? 0.0;
        int idade = int.tryParse(userData['idade'].toString()) ?? 0;

        // Calcula o TMB
        double tmb = calcularTMB(genero, peso, altura, idade);

        // Atualiza os dados no Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'tmb': tmb,
          'numRefeicoes': _numRefeicoes,
          'nivelAtividade': _nivelAtividade,
          'objetivo': _objetivo,
          'multiplicadorProt': _multiplicadorProt,
          'multiplicadorGord': _multiplicadorGord.toStringAsFixed(1),
          'peso': _pesoController.text,
          'altura': _alturaController.text,
          'refeicaoPosTreino': _refeicaoPosTreino,
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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        _pesoController.text = userData['peso']?.toString() ?? '';
        _alturaController.text = userData['altura']?.toString() ?? '';
        _numRefeicoes = userData['numRefeicoes'] as int? ?? 2;
        _nivelAtividade = userData['nivelAtividade'] as String? ?? '';
        _textoNivelAtividade(_nivelAtividade);
        _objetivo = userData['objetivo'] as String? ?? '';
        _textoObjetivo(_objetivo);
        _multiplicadorProt =
            double.tryParse(userData['multiplicadorProt']?.toString() ?? '') ??
                1.0;
        _multiplicadorGord =
            double.tryParse(userData['multiplicadorGord']?.toString() ?? '') ??
                1.0;

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
                  decoration: const InputDecoration(
                      labelText: 'Altura (cm)', hintText: 'Digite sua altura'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua altura';
                    }
                    final altura = int.tryParse(value);
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
                const Text('Objetivo:'),
                ElevatedButton(
                  onPressed: _showObjetivoDialog,
                  child: Text(_objetivo.isEmpty ? 'Selecionar' : textoObjetivo),
                ),
                const SizedBox(height: 20),
                const Text(
                    'Quantos gramas de proteina por KG você quer comer?'),
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
                const Text('Quantos gramas de gordura por KG você quer comer?'),
                Slider(
                  min: 0.3,
                  max: 1.2,
                  divisions: 9,
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
                      onPressed: () {
                      // Valide o Form quando o botão for pressionado
                      if (_formKey.currentState?.validate() ?? false) {
                        _cadastrarDados();
                      }
                    },
                    child: const Text('Confirmar'),
                    ),
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}
