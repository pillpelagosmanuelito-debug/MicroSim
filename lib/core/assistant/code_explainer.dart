import '../mcu/ast.dart';

/// Asistente tecnico "explicar codigo": recorre el AST del sketch del
/// estudiante y genera una explicacion linea a linea en espanol llano.
///
/// Es un sistema de reglas sobre la estructura del programa (no un
/// modelo de lenguaje): cada tipo de sentencia/llamada tiene una
/// plantilla de explicacion fija. Se eligio este enfoque por la misma
/// razon que en OscilloLab y CircuitLab Academy: el dominio es cerrado
/// (un subconjunto de ~10 funciones nativas y ~6 formas de sentencia),
/// asi que una plantilla determinista es mas confiable, instantanea y
/// gratuita que invocar un LLM, y nunca "inventa" una explicacion de
/// una funcion que el estudiante no llamo.
class CodeExplainer {
  static List<String> explicar(Programa programa) {
    final List<String> lineas = [];
    final FuncDecl? setup = programa.buscar('setup');
    final FuncDecl? loop = programa.buscar('loop');

    if (setup != null) {
      lineas.add('— En setup() (se ejecuta una sola vez, al iniciar):');
      lineas.addAll(setup.cuerpo.map((s) => '   ${_explicarSentencia(s)}'));
    }
    if (loop != null) {
      lineas.add('— En loop() (se repite sin parar):');
      lineas.addAll(loop.cuerpo.map((s) => '   ${_explicarSentencia(s)}'));
    }
    if (setup == null && loop == null) {
      lineas.add(
        'Este sketch no define setup() ni loop(): un programa de '
        'Arduino necesita ambas funciones para poder ejecutarse.',
      );
    }
    return lineas;
  }

  /// Revisa, de forma estatica y conservadora, si algun pin se usa con
  /// digitalWrite/digitalRead/analogWrite antes de tener un pinMode()
  /// correspondiente en setup() con un numero de pin literal (no
  /// variable). Es una heuristica simple, no un analisis de flujo
  /// completo: si el pin viene de una variable, no se valida.
  static List<String> advertencias(Programa programa) {
    final List<String> avisos = [];
    final Set<int> pinesConfigurados = {};
    final FuncDecl? setup = programa.buscar('setup');
    if (setup != null) {
      for (final Stmt s in setup.cuerpo) {
        if (s is SentenciaExpr && s.expr is Llamada) {
          final Llamada l = s.expr as Llamada;
          if (l.nombre == 'pinMode' &&
              l.argumentos.isNotEmpty &&
              l.argumentos[0] is NumeroLiteral) {
            pinesConfigurados.add((l.argumentos[0] as NumeroLiteral).valor);
          }
        }
      }
    }
    final FuncDecl? loop = programa.buscar('loop');
    if (loop != null) {
      for (final Stmt s in loop.cuerpo) {
        _buscarUsosDePin(s, pinesConfigurados, avisos);
      }
    }
    return avisos;
  }

  static void _buscarUsosDePin(
    Stmt s,
    Set<int> configurados,
    List<String> avisos,
  ) {
    if (s is SentenciaExpr && s.expr is Llamada) {
      final Llamada l = s.expr as Llamada;
      if ((l.nombre == 'digitalWrite' || l.nombre == 'analogWrite') &&
          l.argumentos.isNotEmpty &&
          l.argumentos[0] is NumeroLiteral) {
        final int pin = (l.argumentos[0] as NumeroLiteral).valor;
        if (!configurados.contains(pin)) {
          avisos.add(
            'El pin $pin se usa en ${l.nombre}() pero no se configuro '
            'con pinMode($pin, OUTPUT) en setup(). Arduino real puede '
            'comportarse de forma impredecible en este caso.',
          );
        }
      }
    } else if (s is Si) {
      for (final Stmt inner in s.entonces) {
        _buscarUsosDePin(inner, configurados, avisos);
      }
      for (final Stmt inner in s.sino ?? const []) {
        _buscarUsosDePin(inner, configurados, avisos);
      }
    } else if (s is Para) {
      for (final Stmt inner in s.cuerpo) {
        _buscarUsosDePin(inner, configurados, avisos);
      }
    } else if (s is Mientras) {
      for (final Stmt inner in s.cuerpo) {
        _buscarUsosDePin(inner, configurados, avisos);
      }
    }
  }

  static String _explicarSentencia(Stmt s) {
    if (s is VarDecl) {
      final String tipo = s.tipo == 'int' ? 'entero' : 'booleano';
      return 'Declara la variable "${s.nombre}" (tipo $tipo)'
          '${s.inicial != null ? ', con un valor inicial.' : '.'}';
    }
    if (s is Asignacion) {
      return 'Asigna un nuevo valor a la variable "${s.nombre}".';
    }
    if (s is SentenciaExpr && s.expr is Llamada) {
      return _explicarLlamada(s.expr as Llamada);
    }
    if (s is Si) {
      return 'Evalua una condicion: si se cumple, ejecuta un bloque de '
          'instrucciones${s.sino != null ? '; si no, ejecuta otro bloque distinto.' : '.'}';
    }
    if (s is Para) {
      return 'Repite un bloque de instrucciones con un contador (bucle for).';
    }
    if (s is Mientras) {
      return 'Repite un bloque de instrucciones mientras una condicion sea verdadera (bucle while).';
    }
    return 'Sentencia.';
  }

  static String _explicarLlamada(Llamada l) {
    switch (l.nombre) {
      case 'pinMode':
        return 'Configura un pin como entrada o salida (pinMode).';
      case 'digitalWrite':
        return 'Escribe un nivel digital (HIGH/LOW) en un pin de salida.';
      case 'digitalRead':
        return 'Lee el nivel digital (HIGH/LOW) de un pin de entrada.';
      case 'analogWrite':
        return 'Escribe una senal PWM (0-255) en un pin, para controlar '
            'brillo de un LED o velocidad de un motor.';
      case 'analogRead':
        return 'Lee el valor analogico (0-1023) de un pin, tipicamente de un sensor.';
      case 'delay':
        return 'Pausa la ejecucion durante un numero de milisegundos.';
      case 'Serial.begin':
        return 'Inicializa la comunicacion serial con la computadora.';
      case 'Serial.println':
        return 'Envia un valor al monitor serial, en una linea nueva.';
      default:
        return 'Llama a la funcion "${l.nombre}".';
    }
  }
}
