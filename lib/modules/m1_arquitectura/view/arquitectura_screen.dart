import 'package:flutter/material.dart';

import '../model/arquitectura_catalog.dart';
import 'ficha_detalle_screen.dart';
import 'quiz_arquitectura_screen.dart';

class ArquitecturaScreen extends StatelessWidget {
  const ArquitecturaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modulo 1 · Arquitectura MCU')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Antes de programar un microcontrolador conviene entender que '
            'hay dentro: CPU, memoria, pines y alimentacion.',
          ),
          const SizedBox(height: 16),
          ...catalogoArquitectura.map(
            (ficha) => Card(
              child: ListTile(
                leading: const Icon(Icons.memory),
                title: Text(ficha.titulo),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FichaDetalleScreen(ficha: ficha)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Cuestionario de arquitectura'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QuizArquitecturaScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
