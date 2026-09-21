# Guía del subconjunto "Arduino básico" que interpreta MicroSim

## Ejemplo mínimo

```c
void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, HIGH);
  delay(500);
  digitalWrite(13, LOW);
  delay(500);
}
```

## Gramática (forma simplificada)

```
programa      := funcion*
funcion       := 'void' IDENT '(' ')' bloque
bloque        := '{' sentencia* '}'
sentencia     := varDecl ';' | asignacion ';' | llamada ';' | si | para | mientras
varDecl       := ('int' | 'bool') IDENT ('=' expr)?
asignacion    := IDENT '=' expr
si            := 'if' '(' expr ')' bloque ('else' bloque)?
para          := 'for' '(' varDecl ';' expr ';' asignacion ')' bloque
mientras      := 'while' '(' expr ')' bloque
expr          := or
or            := and ('||' and)*
and           := igualdad ('&&' igualdad)*
igualdad      := comparacion (('==' | '!=') comparacion)*
comparacion   := termino (('<' | '>' | '<=' | '>=') termino)*
termino       := factor (('+' | '-') factor)*
factor        := unario (('*' | '/' | '%') unario)*
unario        := ('!' | '-') unario | primario
primario      := NUMERO | 'true' | 'false' | IDENT | llamada | '(' expr ')'
llamada       := IDENT ('.' IDENT)? '(' (expr (',' expr)*)? ')'
```

## Funciones nativas soportadas

| Función | Firma | Efecto |
|---|---|---|
| `pinMode` | `(pin: int, modo: OUTPUT\|INPUT\|INPUT_PULLUP)` | Configura un pin digital |
| `digitalWrite` | `(pin: int, valor: HIGH\|LOW)` | Escribe un nivel digital |
| `digitalRead` | `(pin: int) -> int` | Lee un nivel digital (0 o 1) |
| `analogWrite` | `(pin: int, valor: 0-255)` | Escribe PWM (solo pines 3,5,6,9,10,11) |
| `analogRead` | `(pin: int 0-5) -> int` | Lee un valor analógico (0-1023) |
| `delay` | `(ms: int)` | Avanza el reloj virtual |
| `Serial.begin` | `(baudios: int)` | Sin efecto simulado (compatibilidad) |
| `Serial.println` | `(valor: int\|bool)` | Agrega una línea al monitor serial |

## Qué NO soporta (y por qué)

| Construcción de Arduino real | Por qué se excluyó del MVP |
|---|---|
| Arrays (`int pines[3]`) | Añade complejidad de parsing e interpretación sin ser necesaria para los 5 módulos del MVP |
| Funciones propias con parámetros | El patrón `setup()`/`loop()` cubre todos los ejercicios planteados |
| `#include <Librería.h>` | Implicaría simular librerías completas (Servo, LiquidCrystal, etc.) |
| `float`, `String` como tipos manipulables | `int`/`bool` alcanzan para todos los escenarios de E/S del MVP |
| Otras placas (ESP32, STM32) | Arduino Uno es la placa de referencia explícita del encargo |

## Extender el lenguaje (para quien continúe el proyecto)

Para agregar una construcción nueva (p. ej. arrays): 1) agregar el caso al prototipo Python y probarlo, 2) agregar el nodo AST correspondiente en `lib/core/mcu/ast.dart`, 3) agregar la regla de parseo en `parser.dart`, 4) agregar la evaluación en `interpreter.dart`, 5) agregar la plantilla de explicación en `code_explainer.dart` si aplica. Ese orden (prototipo validado → AST → parser → intérprete → asistente) es el mismo que se siguió para todo el lenguaje actual.
