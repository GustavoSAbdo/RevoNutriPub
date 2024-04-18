import 'package:flutter/material.dart';

class MacrosManualPage extends StatelessWidget {
  const MacrosManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Macros'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/macrosDaDietaManualmente');
              },
              child: const Text('Macros da Dieta'),
            ),
            const SizedBox(height: 20), // Espaço entre os botões
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/macrosRefPage');
              },
              child: const Text('Macros das Refeições'),
            ),
          ],
        ),
      ),
    );
  }
}
