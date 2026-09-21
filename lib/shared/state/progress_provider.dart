import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Progreso del estudiante por módulo (m1..m5), persistido localmente.
class ProgresoState {
  const ProgresoState({required this.completados});
  final Map<String, int> completados;

  int total() => completados.values.fold(0, (a, b) => a + b);

  ProgresoState copyConIncremento(String modulo) {
    final Map<String, int> nuevo = Map<String, int>.from(completados);
    nuevo[modulo] = (nuevo[modulo] ?? 0) + 1;
    return ProgresoState(completados: nuevo);
  }
}

class ProgresoNotifier extends Notifier<ProgresoState> {
  static const String _prefsPrefix = 'microsim_progreso_';
  static const List<String> modulos = ['m1', 'm2', 'm3', 'm4', 'm5'];

  @override
  ProgresoState build() {
    _cargar();
    return const ProgresoState(completados: {});
  }

  Future<void> _cargar() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, int> cargado = {};
    for (final String modulo in modulos) {
      cargado[modulo] = prefs.getInt('$_prefsPrefix$modulo') ?? 0;
    }
    state = ProgresoState(completados: cargado);
  }

  Future<void> registrarEjercicioCompletado(String modulo) async {
    state = state.copyConIncremento(modulo);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefsPrefix$modulo', state.completados[modulo] ?? 0);
  }
}

final NotifierProvider<ProgresoNotifier, ProgresoState> progresoProvider =
    NotifierProvider<ProgresoNotifier, ProgresoState>(ProgresoNotifier.new);
