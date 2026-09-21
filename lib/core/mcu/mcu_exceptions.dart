/// Errores del pipeline lexer -> parser -> interprete. Se muestran al
/// estudiante tal cual, como "errores de compilacion/ejecucion" de su
/// sketch, igual que el IDE de Arduino real.
class ErrorLexico implements Exception {
  ErrorLexico(this.mensaje);
  final String mensaje;
  @override
  String toString() => 'Error lexico: $mensaje';
}

class ErrorSintactico implements Exception {
  ErrorSintactico(this.mensaje);
  final String mensaje;
  @override
  String toString() => 'Error de sintaxis: $mensaje';
}

class ErrorEjecucion implements Exception {
  ErrorEjecucion(this.mensaje);
  final String mensaje;
  @override
  String toString() => 'Error de ejecucion: $mensaje';
}

/// Se lanza cuando el programa del estudiante supera el limite de pasos
/// de ejecucion: protege contra `while(true){}` sin control, algo que
/// un estudiante escribe por error con más frecuencia de la que
/// imagina.
class LimiteDePasosExcedido implements Exception {
  LimiteDePasosExcedido(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}
