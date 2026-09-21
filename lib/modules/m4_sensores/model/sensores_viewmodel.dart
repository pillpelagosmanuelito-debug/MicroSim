import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assistant/code_explainer.dart';
import '../../../core/mcu/ejecutor.dart';
import '../../../core/mcu/mcu_state.dart';
import '../../../core/mcu/parser.dart';
import '../../../core/mcu/sample_programs.dart';

class SensoresState {
  const SensoresState({
    required this.codigo,
    required this.valorSensor,
    this.state,
    this.mensajeError,
    this.explicacion = const [],
    this.advertencias = const [],
  });

  final String codigo;
  final int valorSensor; // 0-1023, simula A0
  final MCUState? state;
  final String? mensajeError;
  final List<String> explicacion;
  final List<String> advertencias;

  bool get led13Encendido => (state?.digital[13] ?? 0) == 1;
  double get voltajeEquivalente => valorSensor * 5.0 / 1023;

  SensoresState copyWith({
    String? codigo,
    int? valorSensor,
    bool limpiarResultado = false,
  }) {
    return SensoresState(
      codigo: codigo ?? this.codigo,
      valorSensor: valorSensor ?? this.valorSensor,
      state: limpiarResultado ? null : state,
      mensajeError: limpiarResultado ? null : mensajeError,
      explicacion: limpiarResultado ? const [] : explicacion,
      advertencias: limpiarResultado ? const [] : advertencias,
    );
  }
}

class SensoresNotifier extends Notifier<SensoresState> {
  @override
  SensoresState build() {
    return const SensoresState(
      codigo: SamplePrograms.sensorConUmbral,
      valorSensor: 512,
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
    mcu.entradaAnalogica[0] = state.valorSensor;

    final ResultadoEjecucion resultado = ejecutarPrograma(
      state.codigo,
      mcu,
      iteraciones: 1,
    );

    List<String> explicacion = const [];
    List<String> advertencias = const [];
    try {
      final programa = analizar(state.codigo);
      explicacion = CodeExplainer.explicar(programa);
      advertencias = CodeExplainer.advertencias(programa);
    } catch (_) {}

    state = SensoresState(
      codigo: state.codigo,
      valorSensor: state.valorSensor,
      state: resultado.exitoso ? resultado.state : null,
      mensajeError: resultado.exitoso ? null : resultado.mensajeError,
      explicacion: explicacion,
      advertencias: advertencias,
    );
  }
}

final NotifierProvider<SensoresNotifier, SensoresState> sensoresProvider =
    NotifierProvider<SensoresNotifier, SensoresState>(SensoresNotifier.new);
