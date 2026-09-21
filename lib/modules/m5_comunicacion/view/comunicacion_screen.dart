import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/state/progress_provider.dart';
import '../../../shared/widgets/tarjeta_explicacion_widget.dart';
import '../../editor/widgets/consola_widget.dart';
import '../../editor/widgets/editor_codigo_widget.dart';
import '../model/comunicacion_viewmodel.dart';

class ComunicacionScreen extends ConsumerStatefulWidget {
  const ComunicacionScreen({super.key});

  @override
  ConsumerState<ComunicacionScreen> createState() => _ComunicacionScreenState();
}

class _ComunicacionScreenState extends ConsumerState<ComunicacionScreen> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(
      text: ref.read(comunicacionProvider).codigo,
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ComunicacionState estado = ref.watch(comunicacionProvider);
    final ComunicacionNotifier notifier = ref.read(
      comunicacionProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Módulo 5 · Comunicación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Serial.begin/println envían datos al monitor serial de la '
            'computadora, igual que en un Arduino conectado por USB. '
            'Sensor simulado en A1.',
          ),
          const SizedBox(height: 12),
          EditorCodigoWidget(controlador: _controlador),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => notifier.actualizarCodigo(_controlador.text),
            child: const Text('Aplicar cambios del editor'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Sensor (A1): ${estado.valorSensor}'),
                  Slider(
                    value: estado.valorSensor.toDouble(),
                    min: 0,
                    max: 1023,
                    divisions: 1023,
                    label: '${estado.valorSensor}',
                    onChanged: (v) => notifier.actualizarSensor(v.round()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Ejecutar (5 vueltas de loop)'),
            onPressed: () => notifier.ejecutar(),
          ),
          const SizedBox(height: 12),
          Text('Monitor serial', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          if (estado.mensajeError != null)
            ConsolaWidget(lineas: [estado.mensajeError!], esError: true)
          else
            ConsolaWidget(lineas: estado.state?.serial ?? const []),
          const SizedBox(height: 12),
          TarjetaExplicacionWidget(
            lineas: estado.explicacion,
            advertencias: estado.advertencias,
          ),
          if (estado.state != null && estado.mensajeError == null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref
                  .read(progresoProvider.notifier)
                  .registrarEjercicioCompletado('m5'),
              child: const Text('Marcar ejercicio como completado'),
            ),
          ],
        ],
      ),
    );
  }
}
