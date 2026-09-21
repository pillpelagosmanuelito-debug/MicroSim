import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/state/progress_provider.dart';
import '../../theme/app_theme.dart';
import '../m1_arquitectura/view/arquitectura_screen.dart';
import '../m2_entradas/view/entradas_screen.dart';
import '../m3_salidas/view/salidas_screen.dart';
import '../m4_sensores/view/sensores_screen.dart';
import '../m5_comunicacion/view/comunicacion_screen.dart';

class _ModuloInfo {
  const _ModuloInfo(this.clave, this.titulo, this.icono, this.pantalla);
  final String clave;
  final String titulo;
  final IconData icono;
  final Widget pantalla;
}

/// Portada con una grilla de 5 modulos (2 columnas), visualmente
/// distinta a la lista vertical de tarjetas de OscilloLab y a la
/// portada de CircuitLab Academy/CircuitAR.
class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProgresoState progreso = ref.watch(progresoProvider);
    final List<_ModuloInfo> modulos = [
      const _ModuloInfo('m1', 'Arquitectura\nMCU', Icons.memory, ArquitecturaScreen()),
      const _ModuloInfo('m2', 'Entradas\ndigitales', Icons.touch_app, EntradasScreen()),
      const _ModuloInfo('m3', 'Salidas\ndigitales', Icons.lightbulb_outline, SalidasScreen()),
      const _ModuloInfo('m4', 'Sensores', Icons.sensors, SensoresScreen()),
      const _ModuloInfo('m5', 'Comunicacion', Icons.cable, ComunicacionScreen()),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.placaPanel, AppTheme.placaOscura],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cianCobre.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.developer_board, size: 48, color: AppTheme.cianCobre),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Programa una placa simulada y observa como tu codigo '
                  'controla LEDs, sensores y motores en tiempo real.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: modulos.map((m) {
            final int completados = progreso.completados[m.clave] ?? 0;
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => m.pantalla),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m.icono, size: 34, color: AppTheme.cianCobre),
                      const SizedBox(height: 10),
                      Text(m.titulo, textAlign: TextAlign.center),
                      if (completados > 0) ...[
                        const SizedBox(height: 6),
                        Chip(label: Text('$completados ✓'), visualDensity: VisualDensity.compact),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
