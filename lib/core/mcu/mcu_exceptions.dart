/// Errores del pipeline lexer -> parser -> intérprete. Se muestran al
/// estudiante tal cual, como "errores de compilación/ejecución" de su
/// sketch, igual que el IDE de Arduino real.
class ErrorLexico implements Exception {
  ErrorLexico(this.mensaje);
  final String mensaje;
  @override
  String toString() => 'Error léxico: $mensaje';
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
  String toString() => 'Error de ejecución: $mensaje';
}

/// Se lanza cuando el programa del estudiante supera el límite de pasos
/// de ejecución: protege contra `while(true){}` sin control, algo que
/// un estudiante escribe por error con más frecuencia de la que
/// imagina.
class LimiteDePasosExcedido implements Exception {
  LimiteDePasosExcedido(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}
