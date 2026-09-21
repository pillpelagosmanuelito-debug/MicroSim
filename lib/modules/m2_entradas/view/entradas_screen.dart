import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/state/progress_provider.dart';
import '../../../shared/widgets/led_widget.dart';
import '../../../shared/widgets/tarjeta_explicacion_widget.dart';
import '../../editor/widgets/consola_widget.dart';
import '../../editor/widgets/editor_codigo_widget.dart';
import '../model/entradas_viewmodel.dart';

class EntradasScreen extends ConsumerStatefulWidget {
  const EntradasScreen({super.key});

  @override
  ConsumerState<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends ConsumerState<EntradasScreen> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(
      text: ref.read(entradasProvider).codigo,
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EntradasState estado = ref.watch(entradasProvider);
    final EntradasNotifier notifier = ref.read(entradasProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Módulo 2 · Entradas digitales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Botón virtual conectado al pin 7. Escribe (o edita) el sketch '
            'que enciende el LED del pin 13 cuando el botón está presionado.',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('Botón (pin 7)'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTapDown: (_) => notifier.alternarBoton(true),
                        onTapUp: (_) => notifier.alternarBoton(false),
                        onTapCancel: () => notifier.alternarBoton(false),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: estado.botonPresionado
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          child: const Icon(Icons.touch_app),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        estado.botonPresionado ? 'presionado' : 'suelto',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  LedWidget(
                    encendido: estado.ledEncendido,
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
            ConsolaWidget(lineas: [estado.mensajeError!], esError: true),
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
                  .registrarEjercicioCompletado('m2'),
              child: const Text('Marcar ejercicio como completado'),
            ),
          ],
        ],
      ),
    );
  }
}
