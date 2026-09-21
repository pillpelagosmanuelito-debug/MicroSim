# Arquitectura Técnica — MicroSim

## Patrón: MVVM + Riverpod

- **Model:** catálogos de datos (`lib/modules/*/model/`) y el núcleo de dominio compartido: el intérprete del lenguaje (`lib/core/mcu/`) y el asistente (`lib/core/assistant/`).
- **ViewModel:** un `Notifier<State>` por pantalla interactiva, expuesto vía `NotifierProvider`.
- **View:** widgets `Consumer(State)Widget` sin lógica de negocio.

## Por qué la estructura es distinta a las apps anteriores de la fábrica

CircuitLab Academy y CircuitAR organizan por capa técnica con Drawer; OscilloLab organiza por módulo con barra inferior de 3 destinos. MicroSim combina: organiza `lib/modules/` por módulo pedagógico (como OscilloLab) **pero** navega con un Drawer lateral con portada ilustrada de "placa" (como CircuitLab Academy), y la portada de Inicio es una **grilla** de 2 columnas en vez de una lista vertical. Además introduce una carpeta sin equivalente en las apps anteriores: `lib/modules/editor/`, con los widgets del editor de código y la consola, compartidos por los módulos 2 a 5.

## El intérprete (`lib/core/mcu/`)

| Archivo | Responsabilidad |
|---|---|
| `lexer.dart` | Tokeniza el código fuente del estudiante |
| `ast.dart` | Nodos del árbol de sintaxis (sentencias y expresiones) |
| `parser.dart` | Analizador descendente recursivo (gramática documentada en el archivo) |
| `interpreter.dart` | Evalúa el AST contra un `MCUState`, con límite de pasos |
| `mcu_state.dart` | Estado simulado del Arduino Uno: pines, reloj virtual, buffer serial |
| `ejecutor.dart` | Punto de entrada único (compilar+ejecutar+manejar errores) que usan los módulos 2-5 |

### Subconjunto de lenguaje soportado (Arduino básico)

- Dos funciones fijas: `void setup()` y `void loop()`.
- Tipos `int` y `bool`; declaración con inicialización opcional.
- Sentencias: asignación, llamada como sentencia, `if`/`else`, `for`, `while`.
- Operadores: aritméticos (`+ - * / %`), comparación (`== != < > <= >=`), lógicos (`&& || !`).
- Funciones nativas: `pinMode`, `digitalWrite`, `digitalRead`, `analogWrite`, `analogRead`, `delay`, `Serial.begin`, `Serial.println`.
- Constantes: `HIGH`, `LOW`, `OUTPUT`, `INPUT`, `INPUT_PULLUP`, `LED_BUILTIN`.

**Explícitamente fuera de alcance:** arrays, funciones propias con parámetros, `#include`, clases, punteros, otros tipos (`float`, `String` como tipo de dato manipulable), otras placas (ESP32, etc.).

### Validación antes del port a Dart

El mismo diseño de lenguaje (lexer, parser, evaluador) se implementó primero en Python (`calib/interpreter_prototype.py`) y se probó con 5 programas representativos (parpadeo de LED, botón que enciende un LED, sensor con umbral y Serial, bucle `for`, bucle infinito con límite de pasos) antes de escribirse en Dart. El port es línea por línea, mismo nombre de función y misma estructura de control, precisamente para poder verificar cada pieza contra su contraparte ya probada.

## El asistente (`lib/core/assistant/code_explainer.dart`)

Recorre el mismo AST que el intérprete ya construyó y genera una explicación por plantilla, tipo de nodo por tipo de nodo. No es un modelo de lenguaje (justificación completa en `docs/01_Memoria_Descriptiva.md §8`). También hace una advertencia estática simple: detecta pines usados en `digitalWrite`/`analogWrite` con un número literal que no tienen un `pinMode()` correspondiente en `setup()`.

## Lecciones aplicadas del post-mortem de CircuitLab Academy

1. **Identificadores Dart en ASCII puro.** Se verificó con `calib/check_ascii_identifiers.py`, que separa strings/comentarios del resto del código y confirma que ningún identificador tiene tildes.
2. **Evitar romper CI por desajuste de versión de Flutter.** El workflow de CI (`.github/workflows/ci.yml`) usa el canal `stable` de Flutter **sin fijar una versión concreta**, para que siempre compile contra las mismas APIs (`Color.withValues`, `CardThemeData`) con las que se escribió el código — el problema que sí afectó a CircuitLab Academy.
3. **No versionar `android/`/`ios/`.** Se generan en CI con `flutter create --platforms=android,ios .`.
4. **Contenido como dato declarativo**, no código: catálogos y sketches de ejemplo son listas/constantes, no lógica.

## Limitación de este entorno de construcción

Igual que en OscilloLab, este contenedor no pudo descargar el SDK de Dart/Flutter (bloqueado por política de red), así que:

- El intérprete se validó de forma independiente en Python antes del port.
- El resto del código (UI, viewmodels, navegación) se escribió y se revisó manualmente: balance de llaves/paréntesis e imports resueltos con un script (excluyendo literales de string, donde el parser legítimamente contiene caracteres `{`/`}` como datos), más el chequeo de identificadores ASCII.
- **No se ejecutó `flutter analyze` ni `flutter test` de verdad en este entorno.** El primer `flutter pub get && flutter analyze && flutter test`, local o en el primer run de CI, es la validación real pendiente.
