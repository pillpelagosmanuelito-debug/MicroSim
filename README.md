# MicroSim

Simulador educativo de microcontroladores para estudiantes de Ingeniería Electrónica (Microcontroladores, Sistemas Embebidos, Automatización). El estudiante escribe un sketch (subconjunto de Arduino C) y lo ejecuta contra hardware simulado: LEDs, botones, sensores y motores.

## Problema educativo

Los estudiantes comprenden código en el papel, pero tienen poca oportunidad de experimentar la interacción real entre software y hardware. MicroSim cierra esa brecha con un intérprete real (no una animación pre-grabada): el código que escribes se compila y se ejecuta de verdad contra un estado de MCU simulado.

## Los 5 módulos

| # | Módulo | Qué practica el estudiante |
|---|--------|------------------------------|
| 1 | Arquitectura MCU | CPU, memoria (Flash/SRAM/EEPROM), pines, alimentación — fichas + quiz |
| 2 | Entradas digitales | `pinMode`, `digitalRead` con un botón virtual |
| 3 | Salidas digitales | `digitalWrite` (LED) y `analogWrite`/PWM (motor) |
| 4 | Sensores | `analogRead` con un sensor simulado (slider 0-1023) y lógica de umbral |
| 5 | Comunicación | `Serial.begin`/`Serial.println` con monitor serial simulado |

Más un **Asistente de explicación de código** (por reglas, no IA generativa), accesible desde el Drawer.

## El intérprete

El núcleo de la app (`lib/core/mcu/`) es un lexer + parser + evaluador de un subconjunto deliberadamente reducido de Arduino C — no una animación con valores fijos. Se diseñó y probó primero en Python (`calib/interpreter_prototype.py`) antes de portarse a Dart. Ver `docs/03_Arquitectura_Tecnica.md` y `docs/04_Guia_Lenguaje_Soportado.md`.

## Stack técnico

- Flutter (canal `stable`), arquitectura MVVM
- Riverpod (`Notifier`/`NotifierProvider`) para estado
- `shared_preferences` para progreso persistente
- CI/CD con GitHub Actions → APK de release (ver `.github/workflows/ci.yml`)

## Estructura del proyecto

```
lib/
  core/mcu/            Lexer, parser, AST, interprete, estado del MCU simulado
  core/assistant/       Asistente de explicacion de codigo (por reglas)
  modules/m1..m5/        Un modulo por carpeta: model / viewmodel / view
  modules/editor/        Editor de codigo y consola, compartidos por m2-m5
  modules/home/           Drawer + portada en grilla + progreso
  modules/asistente/      Pantalla independiente del asistente
  shared/                 Estado compartido (progreso) y widgets reutilizables (LED, motor)
  theme/                  Tema visual "placa de desarrollo"
calib/                    Prototipo Python del interprete + scripts de verificacion (ASCII, no forman parte de la app)
test/                     Pruebas del interprete, del asistente y smoke test de la app
docs/                     Memoria descriptiva, manual de usuario, arquitectura, guia del lenguaje
```

## Cómo compilar

```bash
flutter create --platforms=android,ios --org com.microsim.app --project-name microsim .
flutter pub get
dart run flutter_launcher_icons
flutter test
flutter build apk --release
```

> Nota de entrega: este proyecto se construyó en un entorno sin el SDK de Flutter instalable (la descarga del motor de Dart está bloqueada por política de red del contenedor). El intérprete se validó de forma independiente en Python; el resto del código se revisó manualmente con scripts de balance de llaves/paréntesis, resolución de imports e identificadores ASCII (`calib/check_ascii_identifiers.py`) — pero **no se ejecutó `flutter test` ni `flutter build` en este entorno**. El primer `flutter pub get && flutter analyze && flutter test`, local o el primer run del CI incluido, es la verificación real pendiente.
