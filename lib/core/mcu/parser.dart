import 'ast.dart';
import 'lexer.dart';
import 'mcu_exceptions.dart';

/// Analizador sintáctico descendente recursivo para el subconjunto de
/// "Arduino básico" de MicroSim. La gramática es idéntica, sentencia
/// por sentencia y precedencia por precedencia, a la validada en
/// `calib/interpreter_prototype.py`.
class Parser {
  Parser(this._tokens);

  final List<Token> _tokens;
  int _i = 0;

  Token get _actual => _tokens[_i];

  Token _avanzar() {
    final Token t = _tokens[_i];
    if (_i < _tokens.length - 1) _i++;
    return t;
  }

  Token _esperar(TipoToken tipo, {String? simbolo}) {
    final Token t = _actual;
    final bool tipoOk = t.tipo == tipo;
    final bool simboloOk = simbolo == null || t.valor == simbolo;
    if (!tipoOk || !simboloOk) {
      final String esperado = simbolo ?? tipo.name;
      throw ErrorSintactico(
        'Se esperaba "$esperado" pero se encontró "${t.valor}" en la posición ${t.posicion}.',
      );
    }
    return _avanzar();
  }

  bool _es(TipoToken tipo, [String? simbolo]) {
    return _actual.tipo == tipo &&
        (simbolo == null || _actual.valor == simbolo);
  }

  Programa parsePrograma() {
    final List<FuncDecl> funciones = [];
    while (!_es(TipoToken.fin)) {
      funciones.add(_parseFuncion());
    }
    return Programa(funciones);
  }

  FuncDecl _parseFuncion() {
    _esperar(TipoToken.vacio);
    final String nombre = _esperar(TipoToken.identificador).valor;
    _esperar(TipoToken.simbolo, simbolo: '(');
    _esperar(TipoToken.simbolo, simbolo: ')');
    final List<Stmt> cuerpo = _parseBloque();
    return FuncDecl(nombre: nombre, cuerpo: cuerpo);
  }

  List<Stmt> _parseBloque() {
    _esperar(TipoToken.simbolo, simbolo: '{');
    final List<Stmt> stmts = [];
    while (!_es(TipoToken.simbolo, '}')) {
      stmts.add(_parseSentencia());
    }
    _avanzar(); // '}'
    return stmts;
  }

  Stmt _parseSentencia() {
    if (_es(TipoToken.entero) || _es(TipoToken.booleano)) {
      final VarDecl decl = _parseVarDecl();
      _esperar(TipoToken.simbolo, simbolo: ';');
      return decl;
    }
    if (_es(TipoToken.si)) return _parseSi();
    if (_es(TipoToken.para)) return _parsePara();
    if (_es(TipoToken.mientras)) return _parseMientras();
    if (_es(TipoToken.identificador)) {
      final int inicio = _i;
      String nombre = _avanzar().valor;
      if (_es(TipoToken.simbolo, '.')) {
        _avanzar();
        nombre = '$nombre.${_esperar(TipoToken.identificador).valor}';
      }
      if (_es(TipoToken.simbolo, '=')) {
        _avanzar();
        final Expr expr = _parseExpr();
        _esperar(TipoToken.simbolo, simbolo: ';');
        return Asignacion(nombre: nombre, expr: expr);
      }
      if (_es(TipoToken.simbolo, '(')) {
        _i = inicio;
        final Expr expr = _parseExpr();
        _esperar(TipoToken.simbolo, simbolo: ';');
        return SentenciaExpr(expr);
      }
      throw ErrorSintactico('Sentencia inválida cerca de "${_actual.valor}".');
    }
    throw ErrorSintactico('Sentencia inesperada: "${_actual.valor}".');
  }

  VarDecl _parseVarDecl() {
    final TipoToken tipoTok = _avanzar().tipo; // entero | booleano
    final String nombre = _esperar(TipoToken.identificador).valor;
    Expr? inicial;
    if (_es(TipoToken.simbolo, '=')) {
      _avanzar();
      inicial = _parseExpr();
    }
    final String tipo = tipoTok == TipoToken.entero ? 'int' : 'bool';
    return VarDecl(tipo: tipo, nombre: nombre, inicial: inicial);
  }

  Stmt _parseSi() {
    _esperar(TipoToken.si);
    _esperar(TipoToken.simbolo, simbolo: '(');
    final Expr cond = _parseExpr();
    _esperar(TipoToken.simbolo, simbolo: ')');
    final List<Stmt> entonces = _parseBloque();
    List<Stmt>? sino;
    if (_es(TipoToken.sino)) {
      _avanzar();
      sino = _parseBloque();
    }
    return Si(condicion: cond, entonces: entonces, sino: sino);
  }

  Stmt _parsePara() {
    _esperar(TipoToken.para);
    _esperar(TipoToken.simbolo, simbolo: '(');
    final VarDecl init = _parseVarDecl();
    _esperar(TipoToken.simbolo, simbolo: ';');
    final Expr cond = _parseExpr();
    _esperar(TipoToken.simbolo, simbolo: ';');
    final String nombre = _esperar(TipoToken.identificador).valor;
    _esperar(TipoToken.simbolo, simbolo: '=');
    final Expr actExpr = _parseExpr();
    final Asignacion actualizacion = Asignacion(nombre: nombre, expr: actExpr);
    _esperar(TipoToken.simbolo, simbolo: ')');
    final List<Stmt> cuerpo = _parseBloque();
    return Para(
      init: init,
      condicion: cond,
      actualizacion: actualizacion,
      cuerpo: cuerpo,
    );
  }

  Stmt _parseMientras() {
    _esperar(TipoToken.mientras);
    _esperar(TipoToken.simbolo, simbolo: '(');
    final Expr cond = _parseExpr();
    _esperar(TipoToken.simbolo, simbolo: ')');
    final List<Stmt> cuerpo = _parseBloque();
    return Mientras(condicion: cond, cuerpo: cuerpo);
  }

  // --- expresiones, de menor a mayor precedencia ---

  Expr _parseExpr() => _parseOr();

  Expr _parseOr() {
    Expr izq = _parseAnd();
    while (_es(TipoToken.simbolo, '||')) {
      _avanzar();
      izq = OperacionBinaria(operador: '||', izq: izq, der: _parseAnd());
    }
    return izq;
  }

  Expr _parseAnd() {
    Expr izq = _parseIgualdad();
    while (_es(TipoToken.simbolo, '&&')) {
      _avanzar();
      izq = OperacionBinaria(operador: '&&', izq: izq, der: _parseIgualdad());
    }
    return izq;
  }

  Expr _parseIgualdad() {
    Expr izq = _parseComparacion();
    while (_es(TipoToken.simbolo, '==') || _es(TipoToken.simbolo, '!=')) {
      final String op = _avanzar().valor;
      izq = OperacionBinaria(operador: op, izq: izq, der: _parseComparacion());
    }
    return izq;
  }

  Expr _parseComparacion() {
    Expr izq = _parseTermino();
    while (_es(TipoToken.simbolo, '<') ||
        _es(TipoToken.simbolo, '>') ||
        _es(TipoToken.simbolo, '<=') ||
        _es(TipoToken.simbolo, '>=')) {
      final String op = _avanzar().valor;
      izq = OperacionBinaria(operador: op, izq: izq, der: _parseTermino());
    }
    return izq;
  }

  Expr _parseTermino() {
    Expr izq = _parseFactor();
    while (_es(TipoToken.simbolo, '+') || _es(TipoToken.simbolo, '-')) {
      final String op = _avanzar().valor;
      izq = OperacionBinaria(operador: op, izq: izq, der: _parseFactor());
    }
    return izq;
  }

  Expr _parseFactor() {
    Expr izq = _parseUnario();
    while (_es(TipoToken.simbolo, '*') ||
        _es(TipoToken.simbolo, '/') ||
        _es(TipoToken.simbolo, '%')) {
      final String op = _avanzar().valor;
      izq = OperacionBinaria(operador: op, izq: izq, der: _parseUnario());
    }
    return izq;
  }

  Expr _parseUnario() {
    if (_es(TipoToken.simbolo, '!') || _es(TipoToken.simbolo, '-')) {
      final String op = _avanzar().valor;
      return OperacionUnaria(operador: op, expr: _parseUnario());
    }
    return _parsePrimario();
  }

  Expr _parsePrimario() {
    final Token t = _actual;
    if (t.tipo == TipoToken.numero) {
      _avanzar();
      return NumeroLiteral(int.parse(t.valor));
    }
    if (t.tipo == TipoToken.verdadero) {
      _avanzar();
      return const BoolLiteral(true);
    }
    if (t.tipo == TipoToken.falso) {
      _avanzar();
      return const BoolLiteral(false);
    }
    if (t.tipo == TipoToken.identificador) {
      String nombre = _avanzar().valor;
      if (_es(TipoToken.simbolo, '.')) {
        _avanzar();
        nombre = '$nombre.${_esperar(TipoToken.identificador).valor}';
      }
      if (_es(TipoToken.simbolo, '(')) {
        _avanzar();
        final List<Expr> args = [];
        if (!_es(TipoToken.simbolo, ')')) {
          args.add(_parseExpr());
          while (_es(TipoToken.simbolo, ',')) {
            _avanzar();
            args.add(_parseExpr());
          }
        }
        _esperar(TipoToken.simbolo, simbolo: ')');
        return Llamada(nombre: nombre, argumentos: args);
      }
      return VarRef(nombre);
    }
    if (t.tipo == TipoToken.simbolo && t.valor == '(') {
      _avanzar();
      final Expr expr = _parseExpr();
      _esperar(TipoToken.simbolo, simbolo: ')');
      return expr;
    }
    throw ErrorSintactico(
      'Expresión inesperada: "${t.valor}" en la posición ${t.posicion}.',
    );
  }
}

Programa analizar(String codigo) {
  return Parser(tokenizar(codigo)).parsePrograma();
}
