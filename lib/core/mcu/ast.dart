/// AST del subconjunto de "Arduino básico" que MicroSim interpreta.
///
/// Alcance deliberado del MVP (ver docs/03_Arquitectura_Tecnica.md):
/// dos funciones fijas (setup/loop), tipos int y bool, if/for/while,
/// operadores aritméticos/lógicos/comparación, y las funciones nativas
/// de Arduino (pinMode, digitalWrite, digitalRead, analogWrite,
/// analogRead, delay, Serial.begin, Serial.println). Sin arrays, sin
/// funciones propias con parámetros, sin #include, sin clases.

// ---------------------------------------------------------------------
// Sentencias
// ---------------------------------------------------------------------

abstract class Stmt {
  const Stmt();
}

class FuncDecl {
  const FuncDecl({required this.nombre, required this.cuerpo});
  final String nombre;
  final List<Stmt> cuerpo;
}

class Programa {
  const Programa(this.funciones);
  final List<FuncDecl> funciones;

  FuncDecl? buscar(String nombre) {
    for (final FuncDecl f in funciones) {
      if (f.nombre == nombre) return f;
    }
    return null;
  }
}

class VarDecl extends Stmt {
  const VarDecl({required this.tipo, required this.nombre, this.inicial});
  final String tipo; // 'int' | 'bool'
  final Expr? inicial;
  final String nombre;
}

class Asignacion extends Stmt {
  const Asignacion({required this.nombre, required this.expr});
  final String nombre;
  final Expr expr;
}

class SentenciaExpr extends Stmt {
  const SentenciaExpr(this.expr);
  final Expr expr;
}

class Si extends Stmt {
  const Si({required this.condicion, required this.entonces, this.sino});
  final Expr condicion;
  final List<Stmt> entonces;
  final List<Stmt>? sino;
}

class Para extends Stmt {
  const Para({
    required this.init,
    required this.condicion,
    required this.actualizacion,
    required this.cuerpo,
  });
  final VarDecl init;
  final Expr condicion;
  final Asignacion actualizacion;
  final List<Stmt> cuerpo;
}

class Mientras extends Stmt {
  const Mientras({required this.condicion, required this.cuerpo});
  final Expr condicion;
  final List<Stmt> cuerpo;
}

// ---------------------------------------------------------------------
// Expresiones
// ---------------------------------------------------------------------

abstract class Expr {
  const Expr();
}

class NumeroLiteral extends Expr {
  const NumeroLiteral(this.valor);
  final int valor;
}

class BoolLiteral extends Expr {
  const BoolLiteral(this.valor);
  final bool valor;
}

class VarRef extends Expr {
  const VarRef(this.nombre);
  final String nombre;
}

class OperacionBinaria extends Expr {
  const OperacionBinaria({
    required this.operador,
    required this.izq,
    required this.der,
  });
  final String operador;
  final Expr izq;
  final Expr der;
}

class OperacionUnaria extends Expr {
  const OperacionUnaria({required this.operador, required this.expr});
  final String operador;
  final Expr expr;
}

class Llamada extends Expr {
  const Llamada({required this.nombre, required this.argumentos});
  final String nombre; // p.ej. 'digitalWrite' o 'Serial.println'
  final List<Expr> argumentos;
}
