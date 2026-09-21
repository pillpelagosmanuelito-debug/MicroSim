/// Sketches de ejemplo (subconjunto "Arduino basico" de MicroSim) que
/// sirven como codigo inicial en cada modulo. El estudiante puede
/// editarlos libremente.
class SamplePrograms {
  static const String parpadeoLed = '''
void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, HIGH);
  delay(500);
  digitalWrite(13, LOW);
  delay(500);
}
''';

  static const String botonEncienceLed = '''
void setup() {
  pinMode(7, INPUT);
  pinMode(13, OUTPUT);
}

void loop() {
  int estadoBoton = digitalRead(7);
  if (estadoBoton == HIGH) {
    digitalWrite(13, HIGH);
  } else {
    digitalWrite(13, LOW);
  }
}
''';

  static const String brilloPwm = '''
void setup() {
  pinMode(9, OUTPUT);
}

void loop() {
  analogWrite(9, 64);
  delay(300);
  analogWrite(9, 190);
  delay(300);
}
''';

  static const String sensorConUmbral = '''
void setup() {
  pinMode(13, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  int luz = analogRead(0);
  Serial.println(luz);
  if (luz < 300) {
    digitalWrite(13, HIGH);
  } else {
    digitalWrite(13, LOW);
  }
  delay(200);
}
''';

  static const String comunicacionSerial = '''
void setup() {
  Serial.begin(9600);
}

void loop() {
  int temperatura = analogRead(1);
  Serial.println(temperatura);
  delay(500);
}
''';
}
