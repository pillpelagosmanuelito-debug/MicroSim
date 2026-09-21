/// Un punto en el tiempo simulado, para graficar la evolucion de un pin
/// digital (usado por el simulador de LED/motor del Modulo 3).
class MuestraHistorial {
  const MuestraHistorial({required this.milis, required this.digital});
  final int milis;
  final Map<int, int> digital;
}

/// Estado simulado de un Arduino Uno: 14 pines digitales (0-13, de los
/// cuales 3/5/6/9/10/11 admiten PWM), 6 entradas analogicas (A0-A5),
/// un reloj virtual que avanza con cada `delay()`, y el buffer de
/// `Serial.println`.
class MCUState {
  MCUState()
    : modoPin = {for (int i = 0; i < 14; i++) i: 'INPUT'},
      digital = {for (int i = 0; i < 14; i++) i: 0},
      pwm = {for (int i = 0; i < 14; i++) i: 0},
      entradaAnalogica = {for (int i = 0; i < 6; i++) i: 0};

  final Map<int, String> modoPin;
  final Map<int, int> digital;
  final Map<int, int> pwm;

  /// Valores que el ESCENARIO inyecta (simulan un potenciometro/LDR real
  /// conectado a A0-A5); el programa del estudiante los LEE con
  /// analogRead(), nunca los escribe directamente.
  final Map<int, int> entradaAnalogica;

  int milis = 0;
  final List<String> serial = [];
  final List<MuestraHistorial> historial = [];

  static const List<int> pinesConPwm = [3, 5, 6, 9, 10, 11];

  void tomarMuestra() {
    historial.add(
      MuestraHistorial(milis: milis, digital: Map<int, int>.from(digital)),
    );
    // Limite razonable para no crecer sin fin en un loop muy largo.
    if (historial.length > 500) {
      historial.removeAt(0);
    }
  }
}
