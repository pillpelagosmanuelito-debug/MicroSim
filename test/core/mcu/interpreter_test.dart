import 'package:flutter_test/flutter_test.dart';
import 'package:microsim/core/mcu/ejecutor.dart';
import 'package:microsim/core/mcu/mcu_exceptions.dart';
import 'package:microsim/core/mcu/mcu_state.dart';
import 'package:microsim/core/mcu/parser.dart';
import 'package:microsim/core/mcu/sample_programs.dart';

void main() {
  group('Interpreter (subconjunto Arduino basico)', () {
    test('parpadeoLed: pinMode OUTPUT y alterna HIGH/LOW con delay', () {
      final MCUState mcu = MCUState();
      final ResultadoEjecucion r = ejecutarPrograma(SamplePrograms.parpadeoLed, mcu, iteraciones: 4);
      expect(r.exitoso, isTrue);
      expect(r.state!.modoPin[13], 'OUTPUT');
      // Tras 4 iteraciones (HIGH,LOW cada una) el ultimo estado escrito es LOW.
      expect(r.state!.digital[13], 0);
      expect(r.state!.milis, 4000); // 4 iteraciones * (500+500) ms
    });

    test('botonEncienceLed: refleja el estado del boton en el LED', () {
      final MCUState mcuSuelto = MCUState()..digital[7] = 0;
      final ResultadoEjecucion r1 = ejecutarPrograma(SamplePrograms.botonEncienceLed, mcuSuelto, iteraciones: 1);
      expect(r1.state!.digital[13], 0);

      final MCUState mcuPresionado = MCUState()..digital[7] = 1;
      final ResultadoEjecucion r2 = ejecutarPrograma(SamplePrograms.botonEncienceLed, mcuPresionado, iteraciones: 1);
      expect(r2.state!.digital[13], 1);
    });

    test('sensorConUmbral: enciende el LED solo si el sensor esta bajo el umbral', () {
      final MCUState bajo = MCUState()..entradaAnalogica[0] = 150;
      final ResultadoEjecucion r1 = ejecutarPrograma(SamplePrograms.sensorConUmbral, bajo, iteraciones: 1);
      expect(r1.state!.digital[13], 1);
      expect(r1.state!.serial, contains('150'));

      final MCUState alto = MCUState()..entradaAnalogica[0] = 800;
      final ResultadoEjecucion r2 = ejecutarPrograma(SamplePrograms.sensorConUmbral, alto, iteraciones: 1);
      expect(r2.state!.digital[13], 0);
    });

    test('brilloPwm: analogWrite escribe en el pin PWM', () {
      final MCUState mcu = MCUState();
      final ResultadoEjecucion r = ejecutarPrograma(SamplePrograms.brilloPwm, mcu, iteraciones: 2);
      expect(r.exitoso, isTrue);
      // El ultimo analogWrite ejecutado en cada vuelta de loop() es 190.
      expect(r.state!.pwm[9], 190);
    });

    test('for: suma 0+1+2+3+4=10 y enciende el LED', () {
      const String codigo = '''
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
''';
      final MCUState mcu = MCUState();
      final ResultadoEjecucion r = ejecutarPrograma(codigo, mcu, iteraciones: 1);
      expect(r.exitoso, isTrue);
      expect(r.state!.digital[13], 1);
    });

    test('bucle infinito: se detiene con LimiteDePasosExcedido, no cuelga la app', () {
      const String codigo = '''
void setup() {
}

void loop() {
  int x = 0;
  while (true) {
    x = x + 1;
  }
}
''';
      final MCUState mcu = MCUState();
      final ResultadoEjecucion r = ejecutarPrograma(codigo, mcu, iteraciones: 1, maxPasos: 5000);
      expect(r.exitoso, isFalse);
      expect(r.mensajeError, contains('limite'));
    });

    test('pin digital invalido produce un error de ejecucion legible', () {
      const String codigo = '''
void setup() {
  pinMode(20, OUTPUT);
}
void loop() {}
''';
      final MCUState mcu = MCUState();
      final ResultadoEjecucion r = ejecutarPrograma(codigo, mcu);
      expect(r.exitoso, isFalse);
      expect(r.mensajeError, contains('Pin digital invalido'));
    });

    test('codigo con error de sintaxis se reporta sin lanzar excepcion sin capturar', () {
      const String codigoRoto = '''
void setup() {
  pinMode(13, OUTPUT
}
void loop() {}
''';
      final MCUState mcu = MCUState();
      final ResultadoEjecucion r = ejecutarPrograma(codigoRoto, mcu);
      expect(r.exitoso, isFalse);
      expect(r.mensajeError, isNotNull);
    });

    test('analizar() produce un Programa con setup y loop', () {
      final programa = analizar(SamplePrograms.parpadeoLed);
      expect(programa.buscar('setup'), isNotNull);
      expect(programa.buscar('loop'), isNotNull);
    });

    test('ErrorLexico se lanza ante un caracter no reconocido', () {
      expect(() => analizar('void setup() { int x = 5 @ 3; } void loop() {}'),
          throwsA(isA<ErrorLexico>()));
    });
  });
}
