import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assistant/code_explainer.dart';
import '../../../core/mcu/ejecutor.dart';
import '../../../core/mcu/mcu_state.dart';
import '../../../core/mcu/parser.dart';
import '../../../core/mcu/sample_programs.dart';

class ComunicacionState {
  const ComunicacionState({
    required this.codigo,
    required this.valorSensor,
    this.state,
    this.mensajeError,
    this.explicacion = const [],
    this.advertencias = const [],
  });

  final String codigo;
  final int valorSensor; // 0-1023, simula A1
  final MCUState? state;
  final String? mensajeError;
  final List<String> explicacion;
  final List<String> advertencias;

  ComunicacionState copyWith({
    String? codigo,
    int? valorSensor,
    bool limpiarResultado = false,
  }) {
    return ComunicacionState(
      codigo: codigo ?? this.codigo,
      valorSensor: valorSensor ?? this.valorSensor,
      state: limpiarResultado ? null : state,
      mensajeError: limpiarResultado ? null : mensajeError,
      explicacion: limpiarResultado ? const [] : explicacion,
      advertencias: limpiarResultado ? const [] : advertencias,
    );
  }
}

class ComunicacionNotifier extends Notifier<ComunicacionState> {
  @override
  ComunicacionState build() {
    return const ComunicacionState(
      codigo: SamplePrograms.comunicacionSerial,
      valorSensor: 620,
    );
  }

  void actualizarCodigo(String codigo) {
    state = state.copyWith(codigo: codigo, limpiarResultado: true);
  }

  void actualizarSensor(int valor) {
    state = state.copyWith(valorSensor: valor, limpiarResultado: true);
  }

  void ejecutar() {
    final MCUState mcu = MCUState();
    mcu.entradaAnalogica[1] = state.valorSensor;

    // 5 vueltas de loop() para que el "monitor serial" muestre varias
    // lineas, como en un Arduino real leyendo un sensor periodicamente.
    final ResultadoEjecucion resultado = ejecutarPrograma(
      state.codigo,
      mcu,
      iteraciones: 5,
    );

    List<String> explicacion = const [];
    List<String> advertencias = const [];
    try {
      final programa = analizar(state.codigo);
      explicacion = CodeExplainer.explicar(programa);
      advertencias = CodeExplainer.advertencias(programa);
    } catch (_) {}

    state = ComunicacionState(
      codigo: state.codigo,
      valorSensor: state.valorSensor,
      state: resultado.exitoso ? resultado.state : null,
      mensajeError: resultado.exitoso ? null : resultado.mensajeError,
      explicacion: explicacion,
      advertencias: advertencias,
    );
  }
}

final NotifierProvider<ComunicacionNotifier, ComunicacionState>
    comunicacionProvider =
    NotifierProvider<ComunicacionNotifier, ComunicacionState>(
  ComunicacionNotifier.new,
);
