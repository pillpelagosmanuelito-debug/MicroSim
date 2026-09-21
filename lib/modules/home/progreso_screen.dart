import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/state/progress_provider.dart';

class ProgresoScreen extends ConsumerWidget {
  const ProgresoScreen({super.key});

  static const Map<String, String> _nombres = {
    'm1': 'Módulo 1 · Arquitectura MCU',
    'm2': 'Módulo 2 · Entradas digitales',
    'm3': 'Módulo 3 · Salidas digitales',
    'm4': 'Módulo 4 · Sensores',
    'm5': 'Módulo 5 · Comunicación',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProgresoState estado = ref.watch(progresoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tu progreso')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${estado.total()}',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const Text('ejercicios completados en total'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._nombres.entries.map((entry) {
            final int completados = estado.completados[entry.key] ?? 0;
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(completados.toString())),
                title: Text(entry.value),
                subtitle: LinearProgressIndicator(
                  value: (completados / 5).clamp(0, 1).toDouble(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
