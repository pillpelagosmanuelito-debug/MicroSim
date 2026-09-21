class PreguntaArquitectura {
  const PreguntaArquitectura({
    required this.enunciado,
    required this.opciones,
    required this.indiceCorrecto,
    required this.explicacion,
  });

  final String enunciado;
  final List<String> opciones;
  final int indiceCorrecto;
  final String explicacion;
}

const List<PreguntaArquitectura> preguntasArquitectura = [
  PreguntaArquitectura(
    enunciado:
        'Al desconectar la alimentación de la placa, ¿qué memoria conserva el programa?',
    opciones: ['SRAM', 'Flash', 'Registros de la CPU'],
    indiceCorrecto: 1,
    explicacion:
        'La Flash es memoria no volátil: conserva el programa aunque se apague la placa. La SRAM se borra.',
  ),
  PreguntaArquitectura(
    enunciado:
        '¿Cuántos valores distintos puede devolver analogRead() en un Arduino Uno?',
    opciones: ['2 (HIGH/LOW)', '256', '1024'],
    indiceCorrecto: 2,
    explicacion:
        'El ADC tiene 10 bits de resolución: 2^10 = 1024 valores posibles (0 a 1023).',
  ),
  PreguntaArquitectura(
    enunciado:
        '¿Por qué digitalWrite() solo puede poner un pin en HIGH o LOW, y no en un valor intermedio?',
    opciones: [
      'Porque el pin está dañado',
      'Porque es una salida digital: solo tiene dos estados eléctricos posibles',
      'Porque falta configurar el ADC',
    ],
    indiceCorrecto: 1,
    explicacion:
        'Una salida digital tiene, por definición, solo dos niveles (0V/5V). Para valores intermedios se necesita PWM (analogWrite).',
  ),
  PreguntaArquitectura(
    enunciado:
        '¿Qué le pasa a una variable declarada con int dentro de loop() al reiniciar la placa?',
    opciones: [
      'Se pierde: vivía en SRAM',
      'Se conserva: vivía en Flash',
      'Se guarda automáticamente en EEPROM',
    ],
    indiceCorrecto: 0,
    explicacion:
        'Las variables en tiempo de ejecución viven en SRAM, que se borra al reiniciar. Para persistir datos entre reinicios se necesita EEPROM explícitamente.',
  ),
];
