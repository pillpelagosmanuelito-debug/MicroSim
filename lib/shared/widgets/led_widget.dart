import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// LED simulado: circulo que se ilumina segun [encendido], con brillo
/// proporcional a [brillo] (0-255) cuando se usa para representar PWM.
class LedWidget extends StatelessWidget {
  const LedWidget({
    super.key,
    required this.encendido,
    this.brillo = 255,
    this.color = AppTheme.ledVerde,
    this.etiqueta,
  });

  final bool encendido;
  final int brillo; // 0-255, solo relevante si encendido
  final Color color;
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final double opacidad =
        encendido ? (0.25 + 0.75 * (brillo / 255)).clamp(0.25, 1.0) : 0.08;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacidad),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
            boxShadow: encendido
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: opacidad * 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        if (etiqueta != null) ...[
          const SizedBox(height: 6),
          Text(etiqueta!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
