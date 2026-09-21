# Manual de Usuario — MicroSim

## Navegación general

MicroSim usa un menú lateral (Drawer, icono ☰ en la esquina superior izquierda) con tres destinos: **Inicio** (los 5 módulos), **Progreso** y **Asistente: explicar código**. La portada de Inicio muestra una grilla con los 5 módulos y tu progreso en cada uno.

## Módulo 1 · Arquitectura MCU

Fichas sobre CPU, memoria (Flash/SRAM/EEPROM), pines digitales, pines analógicos y alimentación de un Arduino Uno. Al final, un cuestionario de 4 preguntas.

## Módulo 2 · Entradas digitales

Editor de código con un sketch que enciende un LED (pin 13) cuando un botón virtual (pin 7) está presionado. Mantén presionado el círculo "Boton (pin 7)" y presiona **Ejecutar** para ver el LED reaccionar. Puedes editar el código libremente — solo recuerda presionar "Aplicar cambios del editor" antes de ejecutar.

## Módulo 3 · Salidas digitales

Editor de código con un sketch que alterna un LED (pin 13, digitalWrite) y controla el brillo de un motor/LED (pin 9, analogWrite/PWM). Presiona **Ejecutar** para correr 6 vueltas de `loop()` y ver el estado final del LED, la barra de PWM del motor, y una línea de tiempo con los cambios del pin 13.

## Módulo 4 · Sensores

Un slider simula un sensor analógico (potenciómetro o LDR) conectado a A0, con valores de 0 a 1023 (y su voltaje equivalente). El sketch de ejemplo enciende un LED cuando el sensor está por debajo de un umbral. Mueve el slider y presiona **Ejecutar** para ver cómo cambia el resultado.

## Módulo 5 · Comunicación

Un slider simula un segundo sensor (A1). El sketch usa `Serial.begin()`/`Serial.println()` para enviar datos al **monitor serial** simulado, que se muestra abajo con la salida de 5 vueltas de `loop()`, igual que el Monitor Serie del IDE de Arduino real.

## Asistente: explicar código

Pega cualquier sketch (del subconjunto que MicroSim soporta) y presiona **Explicar código**: el asistente describe, línea a línea, qué hace `setup()` y qué hace `loop()`, y advierte si usas un pin sin configurarlo antes con `pinMode()`.

## Errores comunes que vas a ver (y qué significan)

| Mensaje | Causa típica |
|---|---|
| "Error de sintaxis: se esperaba..." | Falta un `;`, un paréntesis o una llave en tu código |
| "Pin digital invalido" / "Pin analogico invalido" | Usaste un número de pin fuera de rango (digital: 0-13, analógico: A0-A5) |
| "El pin X no soporta PWM" | `analogWrite()` solo funciona en los pines 3, 5, 6, 9, 10 y 11 |
| "El programa supero el limite de pasos de ejecucion" | Tu `while`/`for` no tiene una condición que lo detenga (bucle infinito) |

## Progreso

Se guarda automáticamente en el dispositivo, sin necesidad de cuenta ni conexión a internet.
