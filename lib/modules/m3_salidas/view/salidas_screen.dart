import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/state/progress_provider.dart';
import '../../../shared/widgets/led_widget.dart';
import '../../../shared/widgets/motor_widget.dart';
import '../../../shared/widgets/tarjeta_explicacion_widget.dart';
import '../../editor/widgets/consola_widget.dart';
import '../../editor/widgets/editor_codigo_widget.dart';
import '../model/salidas_viewmodel.dart';

class SalidasScreen extends ConsumerStatefulWidget {
  const SalidasScreen({super.key});

  @override
  ConsumerState<SalidasScreen> createState() => _SalidasScreenState();
}

class _SalidasScreenState extends ConsumerState<SalidasScreen> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(text: ref.read(salidasProvider).codigo);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SalidasState estado = ref.watch(salidasProvider);
    final SalidasNotifier notifier = ref.read(salidasProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Modulo 3 · Salidas digitales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'LED en el pin 13 (digitalWrite) y motor/LED de brillo variable '
            'en el pin 9 (analogWrite, PWM). Se ejecutan 6 vueltas de loop().',
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
                  LedWidget(encendido: estado.led13Encendido, etiqueta: 'LED (pin 13)'),
                  const SizedBox(height: 16),
                  MotorWidget(valorPwm: estado.pwmPin9, etiqueta: 'Motor / LED PWM (pin 9)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Ejecutar (6 vueltas de loop)'),
            onPressed: () => notifier.ejecutar(),
          ),
          const SizedBox(height: 12),
          if (estado.mensajeError != null)
            ConsolaWidget(lineas: [estado.mensajeError!], esError: true),
          if (estado.state != null && estado.lineaDeTiempo.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Linea de tiempo (pin 13)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            ConsolaWidget(lineas: estado.lineaDeTiempo),
          ],
          const SizedBox(height: 12),
          TarjetaExplicacionWidget(lineas: estado.explicacion, advertencias: estado.advertencias),
          if (estado.state != null && estado.mensajeError == null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.read(progresoProvider.notifier).registrarEjercicioCompletado('m3'),
              child: const Text('Marcar ejercicio como completado'),
            ),
          ],
        ],
      ),
    );
  }
}
