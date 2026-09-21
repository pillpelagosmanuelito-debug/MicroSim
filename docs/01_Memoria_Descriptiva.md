# Memoria Descriptiva — MicroSim

## 1. Objetivo

Enseñar programación y aplicación práctica de microcontroladores mediante simulación: el estudiante escribe código real (un subconjunto de Arduino C) y ve de inmediato cómo controla LEDs, botones, sensores y motores simulados, sin necesitar hardware físico.

## 2. Problema educativo

Los estudiantes de Ingeniería Electrónica entienden código en el papel, pero tienen pocas oportunidades de experimentar la interacción software-hardware: escriben `digitalWrite(13, HIGH)` sin ver qué significa "HIGH" eléctricamente, o `analogRead()` sin entender que devuelve un entero de 10 bits, no un voltaje.

## 3. Usuario objetivo

Estudiantes de Ingeniería Electrónica en líneas de Microcontroladores, Sistemas Embebidos y Automatización.

## 4. Competencias que desarrolla

| Competencia | Cómo se practica |
|---|---|
| Programar microcontroladores | Editor de código real (subconjunto de Arduino C) con compilación y ejecución inmediatas |
| Controlar entradas y salidas | digitalRead/digitalWrite/analogRead/analogWrite sobre hardware simulado (botón, LED, sensor, motor) |
| Diseñar sistemas electrónicos | Conectar el comportamiento del código con la arquitectura real del MCU (Módulo 1) |

## 5. Experiencia de aprendizaje

Cada módulo (excepto el primero, informativo) presenta un editor de código con un sketch inicial editable, un escenario de hardware simulado (botón, sensor con slider, LED, motor PWM), un botón "Ejecutar" que compila e interpreta el código contra ese escenario, y el asistente técnico que explica, línea a línea, qué hace el programa.

## 6. MVP

**Incluye:** Arduino básico (subconjunto de C: setup/loop, tipos int/bool, if/for/while, funciones nativas de E/S y Serial), simulaciones simples de LED/botón/sensor/motor en 5 módulos, asistente de explicación de código por reglas.

**No incluye (fuera de alcance deliberado):** conexión física real (USB/Bluetooth a una placa real), un compilador C++ completo (arrays, structs, funciones propias, punteros, librerías externas), ESP32/otras placas (solo Arduino Uno como referencia).

## 7. Por qué un subconjunto de lenguaje, no Arduino C completo

Implementar un compilador C++ completo está muy por fuera de lo que un MVP educativo necesita: el objetivo es que el estudiante entienda la relación entre una instrucción y su efecto en el hardware, no que MicroSim reemplace al IDE de Arduino. El subconjunto soportado (documentado en `docs/03_Arquitectura_Tecnica.md`) cubre exactamente las construcciones que aparecen en un curso introductorio de microcontroladores. Es una limitación **declarada**, no oculta: el asistente y los mensajes de error dejan claro cuándo una función no está soportada.

## 8. IA: asistente de explicación de código, por reglas

Se evaluó IA generativa para "explicar código" y se descartó para el MVP por la misma razón aplicada en CircuitLab Academy y OscilloLab: el subconjunto de lenguaje que MicroSim interpreta es pequeño y cerrado (~10 funciones nativas, 6 formas de sentencia), así que una plantilla de explicación por tipo de nodo del AST es exacta, instantánea, gratuita y **nunca inventa** una función que el estudiante no usó — algo que un LLM sí podría hacer ocasionalmente. El asistente recorre el mismo árbol de sintaxis que el intérprete ya construyó para ejecutar el programa, así que la explicación siempre es consistente con el comportamiento real del código.

## 9. Diferenciación frente al catálogo existente

MicroSim corresponde al slot 21 del catálogo maestro ("Embedded Systems Academy" — Arduino, ESP32, sensores, sistemas embebidos), un área no cubierta por las apps ya entregadas: CircuitAR enseña a seleccionar componentes discretos, CircuitLab Academy resuelve circuitos analógicos con un motor MNA, OscilloLab enseña a interpretar instrumentos de medición externos. Ninguna de las tres involucra escribir y ejecutar código.

## 10. Riesgos y debilidades identificadas (análisis crítico)

| Riesgo | Mitigación aplicada | Limitación conocida |
|---|---|---|
| Que el "simulador" sea solo un IDE de texto sin comportamiento real | Intérprete real (lexer+parser+evaluador) validado primero en Python (`calib/interpreter_prototype.py`), luego portado a Dart con los mismos casos de prueba | Sin animación en tiempo real del `loop()`; se muestra el estado tras N iteraciones, no un timeline visual continuo |
| Un `while(true){}` del estudiante cuelga la app | Límite de pasos de ejecución (`LimiteDePasosExcedido`) que interrumpe el programa con un mensaje pedagógico | El límite es fijo (20 000 pasos); un bucle legítimo muy largo también se cortaría |
| El asistente "inventa" una explicación incorrecta | Sistema de reglas sobre el AST real del programa, sin generación de texto libre | Explicaciones genéricas por tipo de sentencia, no un análisis semántico profundo (no detecta, por ejemplo, lógica redundante) |
| No se pudo compilar `flutter test`/`flutter build` en este entorno de desarrollo | Intérprete validado en Python; revisión manual de balance de llaves/paréntesis, resolución de imports e identificadores ASCII con scripts (`calib/check_ascii_identifiers.py`) | El primer `flutter pub get && flutter analyze && flutter test` real queda pendiente (ver `docs/03_Arquitectura_Tecnica.md`) |

## 11. Potencial de uso real

Aplicable en cursos de Microcontroladores y Sistemas Embebidos como práctica previa al laboratorio físico con Arduino real, o para estudiantes sin acceso a una placa propia.
