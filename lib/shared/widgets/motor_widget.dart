import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Representa un motor DC (o un LED de brillo variable) controlado por
/// PWM: barra de "velocidad/brillo" de 0 a 255, con el icono girando
/// simbolicamente cuando hay senal.
class MotorWidget extends StatelessWidget {
  const MotorWidget({
    super.key,
    required this.valorPwm,
    this.etiqueta = 'Motor (PWM)',
  });

  final int valorPwm; // 0-255
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final double fraccion = (valorPwm / 255).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings,
              color: valorPwm > 0 ? AppTheme.ambarPwm : Colors.white24,
            ),
            const SizedBox(width: 8),
            Text(etiqueta),
            const Spacer(),
            Text('$valorPwm / 255'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraccion,
            minHeight: 10,
            backgroundColor: Colors.white10,
            color: AppTheme.ambarPwm,
          ),
        ),
      ],
    );
  }
}
