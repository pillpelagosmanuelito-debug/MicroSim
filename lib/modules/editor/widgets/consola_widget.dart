import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Consola/monitor serial: muestra errores de compilacion/ejecucion o
/// la salida de Serial.println, imitando el Monitor Serie del IDE de
/// Arduino real.
class ConsolaWidget extends StatelessWidget {
  const ConsolaWidget({super.key, required this.lineas, this.esError = false});

  final List<String> lineas;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    final Color color = esError ? AppTheme.ledRojo : AppTheme.ledVerde;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.placaOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: lineas.isEmpty
          ? Text('Sin salida todavia. Presiona "Ejecutar".',
              style: AppTheme.textoCodigo.copyWith(color: Colors.white38))
          : ListView(
              shrinkWrap: true,
              children: lineas
                  .map((l) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(l, style: AppTheme.textoCodigo.copyWith(color: color)),
                      ))
                  .toList(),
            ),
    );
  }
}
