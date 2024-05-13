import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:complete/hive/hive_refeicao.dart';

class MacrosManualPage extends StatelessWidget {
  const MacrosManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    Box<HiveRefeicao> refeicaoBox =
                    Provider.of<Box<HiveRefeicao>>(context, listen: false);

    void showDataAlert(String routename ) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Atenção!'),
            content: const Text('Você já possui refeições cadastradas. Se já tiver ingerido as refeições, recomendamos que espere o dia seguinte para alterar os dados. Caso queira prosseguir, aperte Continuar, porém iremos apagar suas refeições.'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Melhor distribuição dos botões
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      refeicaoBox.clear();
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => checkDataAndNavigate('/macrosDaDietaManualmente'),
              child: const Text('Macros da Dieta'),
            ),
            const SizedBox(height: 20), // Espaço entre os botões
            ElevatedButton(
              onPressed: () => checkDataAndNavigate('/macrosRefPage'),
              child: const Text('Macros das Refeições'),
            ),
          ],
        ),
      ),
    );
  }
}
