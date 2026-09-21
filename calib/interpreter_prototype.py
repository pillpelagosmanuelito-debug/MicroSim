"""
MicroSim - Prototipo en Python del interprete de "Arduino basico"
====================================================================

Valida el diseno del lenguaje (lexer + parser + evaluador) ANTES de
escribirlo en Dart, igual que el motor de medicion de OscilloLab se
valido en Python antes de portarse.

Subconjunto de Arduino C deliberadamente reducido (decision de alcance
del MVP, documentada en docs/03_Arquitectura_Tecnica.md del proyecto
Dart): dos funciones fijas (setup/loop), tipos int y bool, if/for/while,
operadores aritmeticos/logicos/comparacion, y las funciones nativas de
Arduino: pinMode, digitalWrite, digitalRead, analogWrite, analogRead,
delay, Serial.begin, Serial.println. Sin arrays, sin funciones propias,
sin #include, sin clases.
"""

import re

# ---------------------------------------------------------------------------
# 1. LEXER
# ---------------------------------------------------------------------------

KEYWORDS = {'void', 'int', 'bool', 'true', 'false', 'if', 'else', 'for', 'while'}

TOKEN_SPEC = [
    ('NUMBER',   r'\d+'),
    ('IDENT',    r'[A-Za-z_][A-Za-z0-9_]*'),
    ('OP2',      r'==|!=|<=|>=|&&|\|\|'),
    ('OP1',      r'[(){};,.=<>!+\-*/%]'),
    ('SKIP',     r'[ \t\n\r]+'),
    ('COMMENT',  r'//[^\n]*'),
]
MASTER_RE = re.compile('|'.join(f'(?P<{name}>{pattern})' for name, pattern in TOKEN_SPEC))


class Token:
    __slots__ = ('type', 'value', 'pos')

    def __init__(self, type_, value, pos):
        self.type = type_
        self.value = value
        self.pos = pos

    def __repr__(self):
        return f'Token({self.type}, {self.value!r})'


class LexError(Exception):
    pass


def tokenize(source):
    tokens = []
    pos = 0
    while pos < len(source):
        m = MASTER_RE.match(source, pos)
        if not m:
            raise LexError(f'Caracter inesperado en la posicion {pos}: {source[pos]!r}')
        kind = m.lastgroup
        text = m.group()
        if kind in ('SKIP', 'COMMENT'):
            pos = m.end()
            continue
        if kind == 'IDENT' and text in KEYWORDS:
            kind = text.upper()
        tokens.append(Token(kind, text, pos))
        pos = m.end()
    tokens.append(Token('EOF', '', pos))
    return tokens


# ---------------------------------------------------------------------------
# 2. AST (tuplas simples: (tipo, *campos))
# ---------------------------------------------------------------------------
# Program        = ('program', [FuncDecl])
# FuncDecl       = ('func', name, [Stmt])
# VarDecl        = ('vardecl', type, name, expr_or_None)
# Assign         = ('assign', name, expr)
# ExprStmt       = ('exprstmt', expr)          # llamada usada como sentencia
# If             = ('if', cond, [Stmt], [Stmt]_or_None)
# For            = ('for', init_vardecl, cond, update_assign, [Stmt])
# While          = ('while', cond, [Stmt])
# Number         = ('num', value)
# Bool           = ('bool', value)
# Var            = ('var', name)
# BinOp          = ('binop', op, left, right)
# UnaryOp        = ('unop', op, expr)
# Call           = ('call', name, [expr])       # name puede ser "Serial.println"


class ParseError(Exception):
    pass


class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.i = 0

    def peek(self):
        return self.tokens[self.i]

    def advance(self):
        tok = self.tokens[self.i]
        self.i += 1
        return tok

    def expect(self, type_):
        tok = self.peek()
        if tok.type != type_:
            raise ParseError(f'Se esperaba {type_} pero se encontro {tok.type} ({tok.value!r}) en la posicion {tok.pos}')
        return self.advance()

    def check(self, type_):
        return self.peek().type == type_

    # --- gramatica ---

    def parse_program(self):
        funcs = []
        while not self.check('EOF'):
            funcs.append(self.parse_func())
        return ('program', funcs)

    def parse_func(self):
        self.expect('VOID')
        name = self.expect('IDENT').value
        self.expect('OP1')  # (
        self.expect('OP1')  # )
        body = self.parse_block()
        return ('func', name, body)

    def parse_block(self):
        self.expect('OP1')  # {
        stmts = []
        while not (self.check('OP1') and self.peek().value == '}'):
            stmts.append(self.parse_statement())
        self.advance()  # }
        return stmts

    def parse_statement(self):
        tok = self.peek()
        if tok.type in ('INT', 'BOOL'):
            decl = self.parse_vardecl()
            self.expect_symbol(';')
            return decl
        if tok.type == 'IF':
            return self.parse_if()
        if tok.type == 'FOR':
            return self.parse_for()
        if tok.type == 'WHILE':
            return self.parse_while()
        if tok.type == 'IDENT':
            # puede ser asignacion (x = expr;) o llamada (foo(...);)
            save = self.i
            name = self.advance().value
            if self.check('OP1') and self.peek().value == '.':
                self.advance()
                name = name + '.' + self.expect('IDENT').value
            if self.check('OP1') and self.peek().value == '=':
                self.advance()
                expr = self.parse_expr()
                self.expect_symbol(';')
                return ('assign', name, expr)
            if self.check('OP1') and self.peek().value == '(':
                self.i = save
                expr = self.parse_expr()
                self.expect_symbol(';')
                return ('exprstmt', expr)
            raise ParseError(f'Sentencia invalida cerca de {tok}')
        raise ParseError(f'Sentencia inesperada: {tok}')

    def parse_vardecl(self):
        type_tok = self.advance()  # INT | BOOL
        name = self.expect('IDENT').value
        init = None
        if self.check('OP1') and self.peek().value == '=':
            self.advance()
            init = self.parse_expr()
        return ('vardecl', type_tok.type.lower(), name, init)

    def parse_if(self):
        self.expect('IF')
        self.expect_symbol('(')
        cond = self.parse_expr()
        self.expect_symbol(')')
        then_block = self.parse_block()
        else_block = None
        if self.check('ELSE'):
            self.advance()
            else_block = self.parse_block()
        return ('if', cond, then_block, else_block)

    def parse_for(self):
        self.expect('FOR')
        self.expect_symbol('(')
        init = self.parse_vardecl()
        self.expect_symbol(';')
        cond = self.parse_expr()
        self.expect_symbol(';')
        name = self.expect('IDENT').value
        self.expect_symbol('=')
        update_expr = self.parse_expr()
        update = ('assign', name, update_expr)
        self.expect_symbol(')')
        body = self.parse_block()
        return ('for', init, cond, update, body)

    def parse_while(self):
        self.expect('WHILE')
        self.expect_symbol('(')
        cond = self.parse_expr()
        self.expect_symbol(')')
        body = self.parse_block()
        return ('while', cond, body)

    def expect_symbol(self, sym):
        tok = self.peek()
        if not (tok.type == 'OP1' and tok.value == sym) and not (tok.type == 'OP2' and tok.value == sym):
            raise ParseError(f'Se esperaba {sym!r} pero se encontro {tok.value!r} en la posicion {tok.pos}')
        self.advance()

    # --- expresiones (precedencia) ---

    def parse_expr(self):
        return self.parse_or()

    def parse_or(self):
        left = self.parse_and()
        while self.check('OP2') and self.peek().value == '||':
            self.advance()
            right = self.parse_and()
            left = ('binop', '||', left, right)
        return left

    def parse_and(self):
        left = self.parse_equality()
        while self.check('OP2') and self.peek().value == '&&':
            self.advance()
            right = self.parse_equality()
            left = ('binop', '&&', left, right)
        return left

    def parse_equality(self):
        left = self.parse_comparison()
        while self.check('OP2') and self.peek().value in ('==', '!='):
            op = self.advance().value
            right = self.parse_comparison()
            left = ('binop', op, left, right)
        return left

    def parse_comparison(self):
        left = self.parse_term()
        while (self.check('OP1') and self.peek().value in ('<', '>')) or \
              (self.check('OP2') and self.peek().value in ('<=', '>=')):
            op = self.advance().value
            right = self.parse_term()
            left = ('binop', op, left, right)
        return left

    def parse_term(self):
        left = self.parse_factor()
        while self.check('OP1') and self.peek().value in ('+', '-'):
            op = self.advance().value
            right = self.parse_factor()
            left = ('binop', op, left, right)
        return left

    def parse_factor(self):
        left = self.parse_unary()
        while self.check('OP1') and self.peek().value in ('*', '/', '%'):
            op = self.advance().value
            right = self.parse_unary()
            left = ('binop', op, left, right)
        return left

    def parse_unary(self):
        if self.check('OP1') and self.peek().value in ('!', '-'):
            op = self.advance().value
            expr = self.parse_unary()
            return ('unop', op, expr)
        return self.parse_primary()

    def parse_primary(self):
        tok = self.peek()
        if tok.type == 'NUMBER':
            self.advance()
            return ('num', int(tok.value))
        if tok.type == 'TRUE':
            self.advance()
            return ('bool', True)
        if tok.type == 'FALSE':
            self.advance()
            return ('bool', False)
        if tok.type == 'IDENT':
            name = self.advance().value
            if self.check('OP1') and self.peek().value == '.':
                self.advance()
                name = name + '.' + self.expect('IDENT').value
            if self.check('OP1') and self.peek().value == '(':
                self.advance()
                args = []
                if not (self.check('OP1') and self.peek().value == ')'):
                    args.append(self.parse_expr())
                    while self.check('OP1') and self.peek().value == ',':
                        self.advance()
                        args.append(self.parse_expr())
                self.expect_symbol(')')
                return ('call', name, args)
            return ('var', name)
        if tok.type == 'OP1' and tok.value == '(':
            self.advance()
            expr = self.parse_expr()
            self.expect_symbol(')')
            return expr
        raise ParseError(f'Expresion inesperada: {tok}')


def parse(source):
    return Parser(tokenize(source)).parse_program()


# ---------------------------------------------------------------------------
# 3. ESTADO DE MCU + EVALUADOR
# ---------------------------------------------------------------------------

class RuntimeErrorMCU(Exception):
    pass


class MaxStepsExceeded(Exception):
    pass


class MCUState:
    """Estado simulado de un Arduino Uno: 14 pines digitales (0-13) y 6
    analogicos (A0-A5), reloj virtual y buffer serial."""

    def __init__(self):
        self.pin_mode = {i: 'INPUT' for i in range(14)}
        self.digital = {i: 0 for i in range(14)}
        self.pwm = {i: 0 for i in range(14)}
        self.analog_in = {i: 0 for i in range(6)}   # valores inyectados por el escenario (0-1023)
        self.millis = 0
        self.serial = []
        self.history = []  # snapshots (millis, digital copy) para graficar

    def snapshot(self):
        self.history.append((self.millis, dict(self.digital)))


class Interpreter:
    CONSTANTS = {
        'HIGH': 1, 'LOW': 0,
        'OUTPUT': 'OUTPUT', 'INPUT': 'INPUT', 'INPUT_PULLUP': 'INPUT_PULLUP',
        'LED_BUILTIN': 13,
    }

    def __init__(self, program_ast, state: MCUState, max_steps=20000):
        self.funcs = {name: body for (_, name, body) in program_ast[1]}
        self.state = state
        self.globals = dict(self.CONSTANTS)
        self.steps = 0
        self.max_steps = max_steps

    def _tick(self):
        self.steps += 1
        if self.steps > self.max_steps:
            raise MaxStepsExceeded('El programa supero el limite de pasos de ejecucion (posible bucle infinito).')

    def run_setup(self):
        if 'setup' in self.funcs:
            self.exec_block(self.funcs['setup'], self.globals)

    def run_loop_once(self):
        if 'loop' in self.funcs:
            self.exec_block(self.funcs['loop'], self.globals)

    def exec_block(self, stmts, scope):
        for stmt in stmts:
            self.exec_stmt(stmt, scope)

    def exec_stmt(self, stmt, scope):
        self._tick()
        kind = stmt[0]
        if kind == 'vardecl':
            _, _type, name, init = stmt
            scope[name] = self.eval_expr(init, scope) if init is not None else 0
        elif kind == 'assign':
            _, name, expr = stmt
            scope[name] = self.eval_expr(expr, scope)
        elif kind == 'exprstmt':
            self.eval_expr(stmt[1], scope)
        elif kind == 'if':
            _, cond, then_b, else_b = stmt
            if self.eval_expr(cond, scope):
                self.exec_block(then_b, scope)
            elif else_b is not None:
                self.exec_block(else_b, scope)
        elif kind == 'for':
            _, init, cond, update, body = stmt
            local = dict(scope)
            self.exec_stmt(init, local)
            while self.eval_expr(cond, local):
                self._tick()
                self.exec_block(body, local)
                self.exec_stmt(update, local)
            scope.update({k: v for k, v in local.items() if k in scope})
        elif kind == 'while':
            _, cond, body = stmt
            while self.eval_expr(cond, scope):
                self._tick()
                self.exec_block(body, scope)
        else:
            raise RuntimeErrorMCU(f'Sentencia no soportada: {kind}')

    def eval_expr(self, expr, scope):
        kind = expr[0]
        if kind == 'num':
            return expr[1]
        if kind == 'bool':
            return expr[1]
        if kind == 'var':
            name = expr[1]
            if name in scope:
                return scope[name]
            if name in self.globals:
                return self.globals[name]
            raise RuntimeErrorMCU(f'Variable no definida: {name}')
        if kind == 'binop':
            return self.eval_binop(expr[1], expr[2], expr[3], scope)
        if kind == 'unop':
            op, sub = expr[1], expr[2]
            v = self.eval_expr(sub, scope)
            if op == '-':
                return -v
            if op == '!':
                return not v
        if kind == 'call':
            return self.eval_call(expr[1], expr[2], scope)
        raise RuntimeErrorMCU(f'Expresion no soportada: {kind}')

    def eval_binop(self, op, left_e, right_e, scope):
        l = self.eval_expr(left_e, scope)
        if op == '&&':
            return bool(l) and bool(self.eval_expr(right_e, scope))
        if op == '||':
            return bool(l) or bool(self.eval_expr(right_e, scope))
        r = self.eval_expr(right_e, scope)
        if op == '+': return l + r
        if op == '-': return l - r
        if op == '*': return l * r
        if op == '/':
            if r == 0:
                raise RuntimeErrorMCU('Division entre cero')
            return int(l / r) if isinstance(l, int) and isinstance(r, int) else l / r
        if op == '%': return l % r
        if op == '==': return l == r
        if op == '!=': return l != r
        if op == '<': return l < r
        if op == '>': return l > r
        if op == '<=': return l <= r
        if op == '>=': return l >= r
        raise RuntimeErrorMCU(f'Operador no soportado: {op}')

    def eval_call(self, name, arg_exprs, scope):
        args = [self.eval_expr(a, scope) for a in arg_exprs]
        s = self.state
        if name == 'pinMode':
            pin, mode = args
            s.pin_mode[pin] = mode
            return None
        if name == 'digitalWrite':
            pin, value = args
            s.digital[pin] = 1 if value else 0
            s.snapshot()
            return None
        if name == 'digitalRead':
            (pin,) = args
            return s.digital.get(pin, 0)
        if name == 'analogWrite':
            pin, value = args
            s.pwm[pin] = max(0, min(255, value))
            s.snapshot()
            return None
        if name == 'analogRead':
            (pin,) = args
            return s.analog_in.get(pin, 0)
        if name == 'delay':
            (ms,) = args
            s.millis += ms
            return None
        if name == 'Serial.begin':
            return None
        if name == 'Serial.println':
            (value,) = args
            s.serial.append(str(value))
            return None
        raise RuntimeErrorMCU(f'Funcion nativa no soportada: {name}')


# ---------------------------------------------------------------------------
# 4. PROGRAMAS DE PRUEBA
# ---------------------------------------------------------------------------

BLINK = """
void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, HIGH);
  delay(500);
  digitalWrite(13, LOW);
  delay(500);
}
"""

BOTON_LED = """
void setup() {
  pinMode(7, INPUT);
  pinMode(13, OUTPUT);
}

void loop() {
  int estadoBoton = digitalRead(7);
  if (estadoBoton == HIGH) {
    digitalWrite(13, HIGH);
  } else {
    digitalWrite(13, LOW);
  }
}
"""

SENSOR_SERIAL = """
void setup() {
  Serial.begin(9600);
}

void loop() {
  int luz = analogRead(0);
  Serial.println(luz);
  if (luz < 300) {
    Serial.println(1);
  }
  delay(200);
}
"""

FOR_LOOP = """
void setup() {
  pinMode(13, OUTPUT);
  int contador = 0;
  for (int i = 0; i < 5; i = i + 1) {
    contador = contador + i;
  }
  if (contador == 10) {
    digitalWrite(13, HIGH);
  }
}

void loop() {
}
"""

INFINITE_LOOP_GUARD = """
void setup() {
}

void loop() {
  int x = 0;
  while (true) {
    x = x + 1;
  }
}
"""


def test_blink():
    ast = parse(BLINK)
    state = MCUState()
    interp = Interpreter(ast, state)
    interp.run_setup()
    assert state.pin_mode[13] == 'OUTPUT'
    for _ in range(4):
        interp.run_loop_once()
    # Tras 4 iteraciones el pin 13 debe haber alternado HIGH/LOW; el ultimo estado escrito es LOW
    assert state.digital[13] == 0
    assert state.millis == 4000
    print('test_blink OK  (millis totales:', state.millis, ')')


def test_boton_led():
    ast = parse(BOTON_LED)
    state = MCUState()
    interp = Interpreter(ast, state)
    interp.run_setup()

    # Boton no presionado
    state.digital[7] = 0
    interp.run_loop_once()
    assert state.digital[13] == 0

    # Boton presionado
    state.digital[7] = 1
    interp.run_loop_once()
    assert state.digital[13] == 1
    print('test_boton_led OK')


def test_sensor_serial():
    ast = parse(SENSOR_SERIAL)
    state = MCUState()
    state.analog_in[0] = 150  # sensor por debajo del umbral 300
    interp = Interpreter(ast, state)
    interp.run_setup()
    interp.run_loop_once()
    assert state.serial == ['150', '1']
    print('test_sensor_serial OK  (serial:', state.serial, ')')


def test_for_loop():
    ast = parse(FOR_LOOP)
    state = MCUState()
    interp = Interpreter(ast, state)
    interp.run_setup()
    # suma 0+1+2+3+4 = 10 -> enciende el LED
    assert state.digital[13] == 1
    print('test_for_loop OK')


def test_infinite_loop_guard():
    ast = parse(INFINITE_LOOP_GUARD)
    state = MCUState()
    interp = Interpreter(ast, state, max_steps=5000)
    interp.run_setup()
    try:
        interp.run_loop_once()
        raise AssertionError('Se esperaba MaxStepsExceeded')
    except MaxStepsExceeded:
        print('test_infinite_loop_guard OK (se detuvo correctamente)')


if __name__ == '__main__':
    test_blink()
    test_boton_led()
    test_sensor_serial()
    test_for_loop()
    test_infinite_loop_guard()
    print('\nTODAS LAS PRUEBAS DEL INTERPRETE PROTOTIPO PASARON.')
