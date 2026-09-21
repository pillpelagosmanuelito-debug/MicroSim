import 'mcu_exceptions.dart';

enum TipoToken {
  numero,
  identificador,
  vacio, // 'void'
  entero, // 'int'
  booleano, // 'bool'
  verdadero,
  falso,
  si, // 'if'
  sino, // 'else'
  para, // 'for'
  mientras, // 'while'
  simbolo, // ( ) { } ; , . = + - * / % < > ! y compuestos == != <= >= && ||
  fin,
}

const Map<String, TipoToken> _palabrasClave = {
  'void': TipoToken.vacio,
  'int': TipoToken.entero,
  'bool': TipoToken.booleano,
  'true': TipoToken.verdadero,
  'false': TipoToken.falso,
  'if': TipoToken.si,
  'else': TipoToken.sino,
  'for': TipoToken.para,
  'while': TipoToken.mientras,
};

class Token {
  const Token({
    required this.tipo,
    required this.valor,
    required this.posicion,
  });
  final TipoToken tipo;
  final String valor;
  final int posicion;

  @override
  String toString() => 'Token(${tipo.name}, $valor)';
}

const List<String> _simbolosDobles = ['==', '!=', '<=', '>=', '&&', '||'];
const String _simbolosSimples = '(){};,.=<>!+-*/%';

/// Convierte el codigo fuente del estudiante en una lista de tokens.
List<Token> tokenizar(String codigo) {
  final List<Token> tokens = [];
  int i = 0;
  final int n = codigo.length;

  bool esDigito(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool esLetra(String c) {
    final int u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122) || c == '_';
  }

  while (i < n) {
    final String c = codigo[i];

    // Espacios en blanco
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
      i++;
      continue;
    }

    // Comentarios de linea
    if (c == '/' && i + 1 < n && codigo[i + 1] == '/') {
      while (i < n && codigo[i] != '\n') {
        i++;
      }
      continue;
    }

    // Numeros
    if (esDigito(c)) {
      final int inicio = i;
      while (i < n && esDigito(codigo[i])) {
        i++;
      }
      tokens.add(
        Token(
          tipo: TipoToken.numero,
          valor: codigo.substring(inicio, i),
          posicion: inicio,
        ),
      );
      continue;
    }

    // Identificadores / palabras clave
    if (esLetra(c)) {
      final int inicio = i;
      while (i < n && (esLetra(codigo[i]) || esDigito(codigo[i]))) {
        i++;
      }
      final String texto = codigo.substring(inicio, i);
      final TipoToken? clave = _palabrasClave[texto];
      tokens.add(
        Token(
          tipo: clave ?? TipoToken.identificador,
          valor: texto,
          posicion: inicio,
        ),
      );
      continue;
    }

    // Simbolos compuestos (2 caracteres)
    if (i + 1 < n) {
      final String dos = codigo.substring(i, i + 2);
      if (_simbolosDobles.contains(dos)) {
        tokens.add(Token(tipo: TipoToken.simbolo, valor: dos, posicion: i));
        i += 2;
        continue;
      }
    }

    // Simbolos simples
    if (_simbolosSimples.contains(c)) {
      tokens.add(Token(tipo: TipoToken.simbolo, valor: c, posicion: i));
      i++;
      continue;
    }

    throw ErrorLexico('Caracter inesperado "$c" en la posicion $i.');
  }

  tokens.add(Token(tipo: TipoToken.fin, valor: '', posicion: n));
  return tokens;
}
