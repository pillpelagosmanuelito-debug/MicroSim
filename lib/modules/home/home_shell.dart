import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../asistente/view/asistente_screen.dart';
import 'inicio_screen.dart';
import 'progreso_screen.dart';

/// Cascaron de navegacion de MicroSim: Drawer lateral con Inicio,
/// Progreso y Asistente. A diferencia de OscilloLab (barra inferior de
/// 3 destinos), aqui se usa un Drawer con encabezado ilustrado de
/// "placa de desarrollo", y el contenido de Inicio es una grilla de
/// modulos en vez de una lista vertical.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MicroSim')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.placaPanel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.developer_board, size: 40, color: AppTheme.cianCobre),
                  const SizedBox(height: 8),
                  Text('MicroSim', style: Theme.of(context).textTheme.titleLarge),
                  const Text('Simulador de microcontroladores', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Inicio'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Progreso'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProgresoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Asistente: explicar codigo'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AsistenteScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: const InicioScreen(),
    );
  }
}
