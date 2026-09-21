import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/state/progress_provider.dart';
import '../../../shared/widgets/led_widget.dart';
import '../../../shared/widgets/tarjeta_explicacion_widget.dart';
import '../../editor/widgets/consola_widget.dart';
import '../../editor/widgets/editor_codigo_widget.dart';
import '../model/sensores_viewmodel.dart';

class SensoresScreen extends ConsumerStatefulWidget {
  const SensoresScreen({super.key});

  @override
  ConsumerState<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends ConsumerState<SensoresScreen> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(
      text: ref.read(sensoresProvider).codigo,
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SensoresState estado = ref.watch(sensoresProvider);
    final SensoresNotifier notifier = ref.read(sensoresProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Modulo 4 · Sensores')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sensor analogico simulado en A0 (potenciometro o LDR). '
            'analogRead(0) devuelve un entero de 0 a 1023.',
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
                  Text(
                    'Sensor (A0): ${estado.valorSensor}  ·  '
                    '${estado.voltajeEquivalente.toStringAsFixed(2)} V equivalentes',
                  ),
                  Slider(
                    value: estado.valorSensor.toDouble(),
                    min: 0,
                    max: 1023,
                    divisions: 1023,
                    label: '${estado.valorSensor}',
                    onChanged: (v) => notifier.actualizarSensor(v.round()),
                  ),
                  const SizedBox(height: 8),
                  LedWidget(
                    encendido: estado.led13Encendido,
                    etiqueta: 'LED (pin 13)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Ejecutar'),
            onPressed: () => notifier.ejecutar(),
          ),
          const SizedBox(height: 12),
          if (estado.mensajeError != null)
            ConsolaWidget(lineas: [estado.mensajeError!], esError: true)
          else if (estado.state != null)
            ConsolaWidget(lineas: estado.state!.serial),
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
                  .registrarEjercicioCompletado('m4'),
              child: const Text('Marcar ejercicio como completado'),
            ),
          ],
        ],
      ),
    );
  }
}
