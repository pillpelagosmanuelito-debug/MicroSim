import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual de MicroSim: paleta "placa de desarrollo" (azul placa
/// oscuro + cian de pista de cobre + rojo/verde de LED indicador),
/// deliberadamente distinta a la paleta "panel de instrumento" de
/// OscilloLab y al verde esquematico de CircuitAR.
///
/// La navegacion tambien es distinta: MicroSim usa un Drawer lateral
/// con los 5 modulos (como CircuitLab Academy) PERO con una portada de
/// "placa" ilustrada, y un editor de codigo de pantalla completa propio
/// (sin equivalente en las apps anteriores), en vez de la barra inferior
/// de 3 destinos que usa OscilloLab.
class AppTheme {
  static const Color placaOscura = Color(0xFF0D1117);
  static const Color placaPanel = Color(0xFF161B22);
  static const Color cianCobre = Color(0xFF58D3F7);
  static const Color ledVerde = Color(0xFF3FE08F);
  static const Color ledRojo = Color(0xFFFF5C5C);
  static const Color ambarPwm = Color(0xFFFFC24B);

  static ThemeData get tema {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: cianCobre,
      brightness: Brightness.dark,
      primary: cianCobre,
      secondary: ambarPwm,
      error: ledRojo,
      surface: placaPanel,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: placaOscura,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: placaOscura,
        foregroundColor: cianCobre,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: placaPanel,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: placaPanel),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cianCobre,
          foregroundColor: placaOscura,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  /// Fuente monoespaciada para el editor de codigo y el monitor serial.
  static TextStyle get textoCodigo => GoogleFonts.jetBrainsMono(fontSize: 14, height: 1.5);
}
