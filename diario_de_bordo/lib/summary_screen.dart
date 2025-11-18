
import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Resumo Diário:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Condução: 0h 0m\nDescanso: 0h 0m',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            Text(
              'Resumo Semanal:',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Condução: 0h 0m\nDescanso: 0h 0m',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
