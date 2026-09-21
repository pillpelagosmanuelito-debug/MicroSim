import 'interpreter.dart';
import 'mcu_exceptions.dart';
import 'mcu_state.dart';
import 'parser.dart';

/// Resultado de compilar + ejecutar un sketch del estudiante: exito con
/// el estado final del MCU, o un mensaje de error listo para mostrar
/// (lexico, sintactico, de ejecucion, o limite de pasos excedido).
class ResultadoEjecucion {
  const ResultadoEjecucion.exito(this.state) : mensajeError = null, exitoso = true;
  const ResultadoEjecucion.error(this.mensajeError)
      : state = null,
        exitoso = false;

  final MCUState? state;
  final String? mensajeError;
  final bool exitoso;
}

/// Compila (lexer+parser) y ejecuta `setup()` una vez y `loop()`
/// [iteraciones] veces sobre un [MCUState] ya preparado con las entradas
/// del escenario (botones/sensores simulados). Centraliza el manejo de
/// errores para que todos los modulos (2-5) lo reutilicen igual.
ResultadoEjecucion ejecutarPrograma(
  String codigo,
  MCUState state, {
  int iteraciones = 5,
  int maxPasos = 20000,
}) {
  try {
    final programa = analizar(codigo);
    final interprete = Interpreter(programa, state, maxPasos: maxPasos);
    interprete.ejecutarSetup();
    for (int i = 0; i < iteraciones; i++) {
      interprete.ejecutarLoopUnaVez();
    }
    return ResultadoEjecucion.exito(state);
  } on ErrorLexico catch (e) {
    return ResultadoEjecucion.error(e.toString());
  } on ErrorSintactico catch (e) {
    return ResultadoEjecucion.error(e.toString());
  } on ErrorEjecucion catch (e) {
    return ResultadoEjecucion.error(e.toString());
  } on LimiteDePasosExcedido catch (e) {
    return ResultadoEjecucion.error(e.toString());
  }
}
