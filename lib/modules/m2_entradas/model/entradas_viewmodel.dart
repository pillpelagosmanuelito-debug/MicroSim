import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assistant/code_explainer.dart';
import '../../../core/mcu/ejecutor.dart';
import '../../../core/mcu/mcu_state.dart';
import '../../../core/mcu/parser.dart';
import '../../../core/mcu/sample_programs.dart';

class EntradasState {
  const EntradasState({
    required this.codigo,
    required this.botonPresionado,
    this.state,
    this.mensajeError,
    this.explicacion = const [],
    this.advertencias = const [],
  });

  final String codigo;
  final bool botonPresionado;
  final MCUState? state;
  final String? mensajeError;
  final List<String> explicacion;
  final List<String> advertencias;

  bool get ledEncendido => (state?.digital[13] ?? 0) == 1;

  EntradasState copyWith({
    String? codigo,
    bool? botonPresionado,
    MCUState? state,
    String? mensajeError,
    bool limpiarResultado = false,
    List<String>? explicacion,
    List<String>? advertencias,
  }) {
    return EntradasState(
      codigo: codigo ?? this.codigo,
      botonPresionado: botonPresionado ?? this.botonPresionado,
      state: limpiarResultado ? null : (state ?? this.state),
      mensajeError: limpiarResultado
          ? null
          : (mensajeError ?? this.mensajeError),
      explicacion: explicacion ?? this.explicacion,
      advertencias: advertencias ?? this.advertencias,
    );
  }
}

class EntradasNotifier extends Notifier<EntradasState> {
  @override
  EntradasState build() {
    return const EntradasState(
      codigo: SamplePrograms.botonEncienceLed,
      botonPresionado: false,
    );
  }

  void actualizarCodigo(String codigo) {
    state = state.copyWith(codigo: codigo, limpiarResultado: true);
  }

  void alternarBoton(bool presionado) {
    state = state.copyWith(botonPresionado: presionado);
  }

  void ejecutar() {
    final MCUState mcu = MCUState();
    mcu.digital[7] = state.botonPresionado ? 1 : 0;

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
    } catch (_) {
      // Si el codigo no compila, ejecutarPrograma ya reporta el error;
      // el explicador simplemente no tiene nada que mostrar.
    }

    // Se reconstruye el estado completo (en vez de usar copyWith) para
    // que un exito limpie un error previo y viceversa sin ambiguedad.
    state = EntradasState(
      codigo: state.codigo,
      botonPresionado: state.botonPresionado,
      state: resultado.exitoso ? resultado.state : null,
      mensajeError: resultado.exitoso ? null : resultado.mensajeError,
      explicacion: explicacion,
      advertencias: advertencias,
    );
  }
}

final NotifierProvider<EntradasNotifier, EntradasState> entradasProvider =
    NotifierProvider<EntradasNotifier, EntradasState>(EntradasNotifier.new);
