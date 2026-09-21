import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assistant/code_explainer.dart';
import '../../../core/mcu/ejecutor.dart';
import '../../../core/mcu/mcu_state.dart';
import '../../../core/mcu/parser.dart';
import '../../../core/mcu/sample_programs.dart';

class SalidasState {
  const SalidasState({
    required this.codigo,
    this.state,
    this.mensajeError,
    this.explicacion = const [],
    this.advertencias = const [],
  });

  final String codigo;
  final MCUState? state;
  final String? mensajeError;
  final List<String> explicacion;
  final List<String> advertencias;

  bool get led13Encendido => (state?.digital[13] ?? 0) == 1;
  int get pwmPin9 => state?.pwm[9] ?? 0;

  List<String> get lineaDeTiempo {
    final List<MuestraHistorial> h = state?.historial ?? const [];
    return h
        .take(12)
        .map(
          (m) =>
              't=${m.milis}ms  →  pin13=${m.digital[13] == 1 ? "HIGH" : "LOW"}',
        )
        .toList();
  }

  SalidasState copyWith({String? codigo, bool limpiarResultado = false}) {
    return SalidasState(
      codigo: codigo ?? this.codigo,
      state: limpiarResultado ? null : state,
      mensajeError: limpiarResultado ? null : mensajeError,
      explicacion: limpiarResultado ? const [] : explicacion,
      advertencias: limpiarResultado ? const [] : advertencias,
    );
  }
}

class SalidasNotifier extends Notifier<SalidasState> {
  @override
  SalidasState build() {
    return const SalidasState(codigo: SamplePrograms.brilloPwm);
  }

  void actualizarCodigo(String codigo) {
    state = state.copyWith(codigo: codigo, limpiarResultado: true);
  }

  void ejecutar() {
    final MCUState mcu = MCUState();
    final ResultadoEjecucion resultado = ejecutarPrograma(
      state.codigo,
      mcu,
      iteraciones: 6,
    );

    List<String> explicacion = const [];
    List<String> advertencias = const [];
    try {
      final programa = analizar(state.codigo);
      explicacion = CodeExplainer.explicar(programa);
      advertencias = CodeExplainer.advertencias(programa);
    } catch (_) {}

    state = SalidasState(
      codigo: state.codigo,
      state: resultado.exitoso ? resultado.state : null,
      mensajeError: resultado.exitoso ? null : resultado.mensajeError,
      explicacion: explicacion,
      advertencias: advertencias,
    );
  }
}

final NotifierProvider<SalidasNotifier, SalidasState> salidasProvider =
    NotifierProvider<SalidasNotifier, SalidasState>(SalidasNotifier.new);
