import 'package:flutter_test/flutter_test.dart';
import 'package:microsim/core/assistant/code_explainer.dart';
import 'package:microsim/core/mcu/parser.dart';
import 'package:microsim/core/mcu/sample_programs.dart';

void main() {
  group('CodeExplainer', () {
    test('explica setup() y loop() del parpadeo de LED', () {
      final programa = analizar(SamplePrograms.parpadeoLed);
      final List<String> explicacion = CodeExplainer.explicar(programa);
      expect(explicacion.any((l) => l.contains('setup()')), isTrue);
      expect(explicacion.any((l) => l.contains('loop()')), isTrue);
      expect(explicacion.any((l) => l.contains('pin')), isTrue);
    });

    test('no reporta advertencias cuando el pin esta bien configurado', () {
      final programa = analizar(SamplePrograms.parpadeoLed);
      final List<String> avisos = CodeExplainer.advertencias(programa);
      expect(avisos, isEmpty);
    });

    test('advierte si un pin se usa sin pinMode previo', () {
      const String codigo = '''
void setup() {
}

void loop() {
  digitalWrite(13, HIGH);
}
''';
      final programa = analizar(codigo);
      final List<String> avisos = CodeExplainer.advertencias(programa);
      expect(avisos, isNotEmpty);
      expect(avisos.first, contains('pin 13'));
    });
  });
}
