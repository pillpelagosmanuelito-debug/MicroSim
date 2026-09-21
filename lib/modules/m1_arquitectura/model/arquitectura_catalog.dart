/// Ficha de un componente de la arquitectura de un microcontrolador
/// (Módulo 1). Contenido de referencia: Arduino Uno (ATmega328P), la
/// placa de referencia del MVP.
class FichaArquitectura {
  const FichaArquitectura({
    required this.id,
    required this.titulo,
    required this.explicacion,
    required this.datosClave,
  });

  final String id;
  final String titulo;
  final String explicacion;
  final List<String> datosClave;
}

const List<FichaArquitectura> catalogoArquitectura = [
  FichaArquitectura(
    id: 'cpu',
    titulo: 'CPU (unidad central de procesamiento)',
    explicacion: 'Ejecuta las instrucciones del programa una por una: lee '
        'la instrucción, la decodifica y la ejecuta, a una velocidad '
        'determinada por el reloj del microcontrolador. En Arduino Uno es '
        'un núcleo AVR de 8 bits.',
    datosClave: [
      'Arquitectura AVR de 8 bits (ATmega328P)',
      'Reloj de 16 MHz en la placa Arduino Uno',
      'Ejecuta una instrucción por ciclo de reloj (arquitectura RISC)',
    ],
  ),
  FichaArquitectura(
    id: 'memoria',
    titulo: 'Memoria: Flash, SRAM y EEPROM',
    explicacion: 'Un microcontrolador tiene tres tipos de memoria con '
        'propósitos distintos. La Flash guarda el programa (persiste sin '
        'energía). La SRAM guarda las variables mientras el programa '
        'corre (se borra al apagar). La EEPROM guarda datos que deben '
        'sobrevivir a un reinicio, pero se escribe mucho más lento.',
    datosClave: [
      'Flash: 32 KB (programa) — se sube desde la computadora',
      'SRAM: 2 KB (variables en tiempo de ejecución) — se borra al reiniciar',
      'EEPROM: 1 KB (datos persistentes) — sobrevive a apagados',
    ],
  ),
  FichaArquitectura(
    id: 'pines_digitales',
    titulo: 'Pines digitales (0-13)',
    explicacion: 'Cada pin digital puede configurarse como entrada '
        '(INPUT) o salida (OUTPUT) con pinMode(). Como salida, solo puede '
        'estar en dos estados: HIGH (5V) o LOW (0V) — no hay valores '
        'intermedios sin PWM.',
    datosClave: [
      '14 pines digitales (0-13)',
      '6 de ellos (3,5,6,9,10,11) admiten PWM (señal analógica simulada)',
      'INPUT_PULLUP activa una resistencia interna para evitar lecturas flotantes',
    ],
  ),
  FichaArquitectura(
    id: 'pines_analogicos',
    titulo: 'Pines analógicos (A0-A5)',
    explicacion: 'Un conversor analógico-digital (ADC) interno traduce '
        'un voltaje continuo (0-5V) a un número entero de 10 bits '
        '(0-1023) que el programa puede leer con analogRead().',
    datosClave: [
      '6 entradas analógicas (A0-A5)',
      'Resolución: 10 bits => valores de 0 a 1023',
      '0 = 0V, 1023 = 5V (aproximadamente, en la placa de referencia)',
    ],
  ),
  FichaArquitectura(
    id: 'alimentacion',
    titulo: 'Alimentación',
    explicacion: 'La placa puede alimentarse por el puerto USB (5V) o por '
        'un conector de alimentación externo (7-12V recomendado), que un '
        'regulador interno reduce a los 5V que usa el microcontrolador.',
    datosClave: [
      'USB: 5V',
      'Conector externo: 7-12V recomendado (el regulador baja a 5V)',
      'Alimentar directo a 5V+ el pin equivocado puede dañar la placa',
    ],
  ),
];
