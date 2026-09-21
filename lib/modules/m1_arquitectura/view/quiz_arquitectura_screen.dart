import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/state/progress_provider.dart';
import '../model/quiz_arquitectura.dart';

class QuizArquitecturaScreen extends ConsumerStatefulWidget {
  const QuizArquitecturaScreen({super.key});

  @override
  ConsumerState<QuizArquitecturaScreen> createState() =>
      _QuizArquitecturaScreenState();
}

class _QuizArquitecturaScreenState
    extends ConsumerState<QuizArquitecturaScreen> {
  int _indice = 0;
  int _correctas = 0;
  int? _opcionElegida;

  void _responder(int indiceOpcion) {
    if (_opcionElegida != null) return;
    setState(() {
      _opcionElegida = indiceOpcion;
      if (indiceOpcion == preguntasArquitectura[_indice].indiceCorrecto) {
        _correctas++;
      }
    });
  }

  void _siguiente() {
    setState(() {
      _indice++;
      _opcionElegida = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool terminado = _indice >= preguntasArquitectura.length;

    if (terminado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultado')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  '$_correctas / ${preguntasArquitectura.length} correctas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_correctas >= (preguntasArquitectura.length * 0.6)) {
                      ref
                          .read(progresoProvider.notifier)
                          .registrarEjercicioCompletado('m1');
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final PreguntaArquitectura pregunta = preguntasArquitectura[_indice];

    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${_indice + 1}/${preguntasArquitectura.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pregunta.enunciado,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...List.generate(pregunta.opciones.length, (i) {
              Color? color;
              if (_opcionElegida != null) {
                if (i == pregunta.indiceCorrecto) {
                  color = Colors.green.withValues(alpha: 0.25);
                } else if (i == _opcionElegida) {
                  color = Colors.red.withValues(alpha: 0.25);
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade700),
                    ),
                    title: Text(pregunta.opciones[i]),
                    onTap: () => _responder(i),
                  ),
                ),
              );
            }),
            if (_opcionElegida != null) ...[
              Text(
                pregunta.explicacion,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _siguiente,
                  child: const Text('Siguiente'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
