import 'package:flutter/material.dart';

import '../../../core/assistant/code_explainer.dart';
import '../../../core/mcu/mcu_exceptions.dart';
import '../../../core/mcu/parser.dart';
import '../../../core/mcu/sample_programs.dart';
import '../../../shared/widgets/tarjeta_explicacion_widget.dart';
import '../../editor/widgets/consola_widget.dart';
import '../../editor/widgets/editor_codigo_widget.dart';

/// Asistente tecnico "explicar codigo" como pantalla independiente:
/// el estudiante puede pegar cualquier sketch (de cualquier modulo, o
/// uno propio) y pedir una explicacion linea a linea, sin necesidad de
/// tener un escenario de simulacion armado. Es la misma logica
/// (CodeExplainer) que usan los modulos 2-5 tras ejecutar; aqui se
/// ofrece de forma directa.
class AsistenteScreen extends StatefulWidget {
  const AsistenteScreen({super.key});

  @override
  State<AsistenteScreen> createState() => _AsistenteScreenState();
}

class _AsistenteScreenState extends State<AsistenteScreen> {
  final TextEditingController _controlador =
      TextEditingController(text: SamplePrograms.parpadeoLed);
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
      appBar: AppBar(title: const Text('Asistente · Explicar codigo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pega o escribe un sketch y el asistente explica, linea a '
            'linea, que hace cada instruccion. Es un sistema de reglas '
            'sobre la estructura del codigo, no un modelo de lenguaje: '
            'nunca inventa una funcion que no exista en tu programa.',
          ),
          const SizedBox(height: 12),
          EditorCodigoWidget(controlador: _controlador, alturaMinima: 260),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Explicar codigo'),
            onPressed: _explicar,
          ),
          const SizedBox(height: 12),
          if (_error != null) ConsolaWidget(lineas: [_error!], esError: true),
          TarjetaExplicacionWidget(lineas: _explicacion, advertencias: _advertencias),
        ],
      ),
    );
  }
}
