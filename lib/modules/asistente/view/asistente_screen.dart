import 'package:flutter/material.dart';

import '../../../core/assistant/code_explainer.dart';
import '../../../core/mcu/mcu_exceptions.dart';
import '../../../core/mcu/parser.dart';
import '../../../core/mcu/sample_programs.dart';
import '../../../shared/widgets/tarjeta_explicacion_widget.dart';
import '../../editor/widgets/consola_widget.dart';
import '../../editor/widgets/editor_codigo_widget.dart';

/// Asistente técnico "explicar código" como pantalla independiente:
/// el estudiante puede pegar cualquier sketch (de cualquier módulo, o
/// uno propio) y pedir una explicación línea a línea, sin necesidad de
/// tener un escenario de simulación armado. Es la misma lógica
/// (CodeExplainer) que usan los módulos 2-5 tras ejecutar; aquí se
/// ofrece de forma directa.
class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});

  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  final TextEditingController _controlador = TextEditingController(
    text: SamplePrograms.parpadeoLed,
  );
  List<String> _explicacion = const [];
  List<String> _advertencias = const [];
  String? _error;

  void _explicar() {
    setState(() {
      _error = null;
      _explicacion = const [];
      _advertencias = const [];
    });
    try {
      final programa = analizar(_controlador.text);
      setState(() {
        _explicacion = CodeExplainer.explicar(programa);
        _advertencias = CodeExplainer.advertencias(programa);
      });
    } on ErrorLexico catch (e) {
      setState(() => _error = e.toString());
    } on ErrorSintactico catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente · Explicar código')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pega o escribe un sketch y el asistente explica, línea a '
            'línea, qué hace cada instrucción. Es un sistema de reglas '
            'sobre la estructura del código, no un modelo de lenguaje: '
            'nunca inventa una función que no exista en tu programa.',
          ),
          const SizedBox(height: 12),
          EditorCodigoWidget(controlador: _controlador, alturaMinima: 260),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Explicar código'),
            onPressed: _explicar,
          ),
          const SizedBox(height: 12),
          if (_error != null) ConsolaWidget(lineas: [_error!], esError: true),
          TarjetaExplicacionWidget(
            lineas: _explicacion,
            advertencias: _advertencias,
          ),
        ],
      ),
    );
  }
}
