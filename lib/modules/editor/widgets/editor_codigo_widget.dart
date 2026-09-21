import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Editor de codigo de texto plano (sin resaltado de sintaxis: fuera de
/// alcance del MVP) para escribir sketches del subconjunto de Arduino
/// basico que interpreta MicroSim.
class EditorCodigoWidget extends StatelessWidget {
  const EditorCodigoWidget({super.key, required this.controlador, this.alturaMinima = 220});

  final TextEditingController controlador;
  final double alturaMinima;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: alturaMinima),
      decoration: BoxDecoration(
        color: AppTheme.placaOscura,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cianCobre.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controlador,
        maxLines: null,
        minLines: 10,
        style: AppTheme.textoCodigo.copyWith(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
