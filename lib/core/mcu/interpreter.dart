import 'ast.dart';
import 'mcu_exceptions.dart';
import 'mcu_state.dart';

/// Evaluador del AST de "Arduino basico" contra un [MCUState] simulado.
/// Puerto directo (misma logica, sentencia por sentencia) del prototipo
/// validado en `calib/interpreter_prototype.py`.
class Interpreter {
  Interpreter(this.programa, this.state, {this.maxPasos = 20000})
      : globales = Map<String, Object?>.from(_constantes);

  final Programa programa;
  final MCUState state;
  final int maxPasos;
  final Map<String, Object?> globales;
  int _pasos = 0;

  static const Map<String, Object?> _constantes = {
    'HIGH': 1,
    'LOW': 0,
    'OUTPUT': 'OUTPUT',
    'INPUT': 'INPUT',
    'INPUT_PULLUP': 'INPUT_PULLUP',
    'LED_BUILTIN': 13,
  };

  void _tick() {
    _pasos++;
    if (_pasos > maxPasos) {
      throw LimiteDePasosExcedido(
        'El programa supero el limite de $maxPasos pasos de ejecucion. '
        'Revisa si algun while/for no tiene una condicion de salida '
        '(bucle infinito).',
      );
    }
  }

  void ejecutarSetup() {
    final FuncDecl? f = programa.buscar('setup');
    if (f != null) _ejecutarBloque(f.cuerpo, globales);
  }

  void ejecutarLoopUnaVez() {
    final FuncDecl? f = programa.buscar('loop');
    if (f != null) _ejecutarBloque(f.cuerpo, globales);
  }

  void _ejecutarBloque(List<Stmt> stmts, Map<String, Object?> scope) {
    for (final Stmt s in stmts) {
      _ejecutarSentencia(s, scope);
    }
  }

  void _ejecutarSentencia(Stmt stmt, Map<String, Object?> scope) {
    _tick();
    if (stmt is VarDecl) {
      scope[stmt.nombre] =
          stmt.inicial != null ? _evaluar(stmt.inicial!, scope) : 0;
    } else if (stmt is Asignacion) {
      scope[stmt.nombre] = _evaluar(stmt.expr, scope);
    } else if (stmt is SentenciaExpr) {
      _evaluar(stmt.expr, scope);
    } else if (stmt is Si) {
      if (_comoBool(_evaluar(stmt.condicion, scope))) {
        _ejecutarBloque(stmt.entonces, scope);
      } else if (stmt.sino != null) {
        _ejecutarBloque(stmt.sino!, scope);
      }
    } else if (stmt is Para) {
      final Map<String, Object?> local = Map<String, Object?>.from(scope);
      _ejecutarSentencia(stmt.init, local);
      while (_comoBool(_evaluar(stmt.condicion, local))) {
        _tick();
        _ejecutarBloque(stmt.cuerpo, local);
        _ejecutarSentencia(stmt.actualizacion, local);
      }
      for (final String clave in scope.keys.toList()) {
        if (local.containsKey(clave)) scope[clave] = local[clave];
      }
    } else if (stmt is Mientras) {
      while (_comoBool(_evaluar(stmt.condicion, scope))) {
        _tick();
        _ejecutarBloque(stmt.cuerpo, scope);
      }
    } else {
      throw ErrorEjecucion('Sentencia no soportada: ${stmt.runtimeType}');
    }
  }

  bool _comoBool(Object? v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    throw ErrorEjecucion('Se esperaba una condicion booleana, se obtuvo: $v');
  }

  Object? _evaluar(Expr expr, Map<String, Object?> scope) {
    if (expr is NumeroLiteral) return expr.valor;
    if (expr is BoolLiteral) return expr.valor;
    if (expr is VarRef) {
      if (scope.containsKey(expr.nombre)) return scope[expr.nombre];
      if (globales.containsKey(expr.nombre)) return globales[expr.nombre];
      throw ErrorEjecucion('Variable no definida: "${expr.nombre}".');
    }
    if (expr is OperacionBinaria) return _evaluarBinaria(expr, scope);
    if (expr is OperacionUnaria) {
      final Object? v = _evaluar(expr.expr, scope);
      if (expr.operador == '-') return -(v as int);
      if (expr.operador == '!') return !_comoBool(v);
      throw ErrorEjecucion('Operador unario no soportado: ${expr.operador}');
    }
    if (expr is Llamada) return _evaluarLlamada(expr, scope);
    throw ErrorEjecucion('Expresion no soportada: ${expr.runtimeType}');
  }

  Object? _evaluarBinaria(OperacionBinaria expr, Map<String, Object?> scope) {
    final Object? izq = _evaluar(expr.izq, scope);
    if (expr.operador == '&&')
      return _comoBool(izq) && _comoBool(_evaluar(expr.der, scope));
    if (expr.operador == '||')
      return _comoBool(izq) || _comoBool(_evaluar(expr.der, scope));

    final Object? der = _evaluar(expr.der, scope);

    switch (expr.operador) {
      case '+':
        return (izq as int) + (der as int);
      case '-':
        return (izq as int) - (der as int);
      case '*':
        return (izq as int) * (der as int);
      case '/':
        if ((der as int) == 0) throw ErrorEjecucion('Division entre cero.');
        return (izq as int) ~/ der;
      case '%':
        return (izq as int) % (der as int);
      case '==':
        return izq == der;
      case '!=':
        return izq != der;
      case '<':
        return (izq as int) < (der as int);
      case '>':
        return (izq as int) > (der as int);
      case '<=':
        return (izq as int) <= (der as int);
      case '>=':
        return (izq as int) >= (der as int);
      default:
        throw ErrorEjecucion('Operador no soportado: ${expr.operador}');
    }
  }

  Object? _evaluarLlamada(Llamada llamada, Map<String, Object?> scope) {
    final List<Object?> args =
        llamada.argumentos.map((a) => _evaluar(a, scope)).toList();

    switch (llamada.nombre) {
      case 'pinMode':
        _validarPin(args[0] as int);
        state.modoPin[args[0] as int] = args[1] as String;
        return null;

      case 'digitalWrite':
        final int pin = _validarPin(args[0] as int);
        final Object? valor = args[1];
        final int valorEntero =
            valor is bool ? (valor ? 1 : 0) : (valor as int);
        state.digital[pin] = valorEntero != 0 ? 1 : 0;
        state.tomarMuestra();
        return null;

      case 'digitalRead':
        return state.digital[_validarPin(args[0] as int)] ?? 0;

      case 'analogWrite':
        final int pin = _validarPin(args[0] as int);
        if (!MCUState.pinesConPwm.contains(pin)) {
          throw ErrorEjecucion(
            'El pin $pin no soporta PWM (analogWrite). Pines validos: '
            '${MCUState.pinesConPwm.join(", ")}.',
          );
        }
        final int valor = (args[1] as int).clamp(0, 255);
        state.pwm[pin] = valor;
        state.tomarMuestra();
        return null;

      case 'analogRead':
        final int pin = args[0] as int;
        if (pin < 0 || pin > 5) {
          throw ErrorEjecucion(
            'Pin analogico invalido: A$pin (valido: A0-A5).',
          );
        }
        return state.entradaAnalogica[pin] ?? 0;

      case 'delay':
        state.milis += args[0] as int;
        return null;

      case 'Serial.begin':
        return null;

      case 'Serial.println':
        state.serial.add(_paraTexto(args[0]));
        return null;

      default:
        throw ErrorEjecucion(
          'Funcion no reconocida: "${llamada.nombre}". Este es un subconjunto '
          'simplificado de Arduino: revisa la lista de funciones soportadas '
          'en el Modulo 1.',
        );
    }
  }

  int _validarPin(int pin) {
    if (pin < 0 || pin > 13) {
      throw ErrorEjecucion('Pin digital invalido: $pin (valido: 0-13).');
    }
    return pin;
  }

  String _paraTexto(Object? valor) {
    if (valor is bool) return valor ? 'true' : 'false';
    return valor.toString();
  }
}
