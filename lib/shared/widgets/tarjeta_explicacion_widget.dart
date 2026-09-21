import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Tarjeta reutilizable para mostrar la explicacion del asistente
/// tecnico (CodeExplainer) sobre el sketch actual del estudiante.
class TarjetaExplicacionWidget extends StatelessWidget {
  const TarjetaExplicacionWidget({
    super.key,
    required this.lineas,
    required this.advertencias,
  });

  final List<String> lineas;
  final List<String> advertencias;

  @override
  Widget build(BuildContext context) {
    if (lineas.isEmpty && advertencias.isEmpty) return const SizedBox.shrink();
    return Card(
      color: AppTheme.cianCobre.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.memory, color: AppTheme.cianCobre),
                const SizedBox(width: 8),
                Text(
                  'Asistente: explicacion del codigo',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...lineas.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(l, style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            if (advertencias.isNotEmpty) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.ambarPwm,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Advertencias',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...advertencias.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    a,
                    style: TextStyle(
                      color: AppTheme.ambarPwm.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
