import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microsim/app.dart';

void main() {
  testWidgets('MicroSimApp arranca y muestra la portada con los 5 modulos', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MicroSimApp()));
    await tester.pumpAndSettle();

    expect(find.text('MicroSim'), findsWidgets);
    expect(find.textContaining('Arquitectura'), findsWidgets);
    expect(find.textContaining('Entradas'), findsWidgets);
    expect(find.textContaining('Salidas'), findsWidgets);
    expect(find.text('Sensores'), findsOneWidget);
    expect(find.text('Comunicación'), findsOneWidget);
  });

  testWidgets('el Drawer abre Progreso y Asistente', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MicroSimApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progreso'));
    await tester.pumpAndSettle();
    expect(find.text('Tu progreso'), findsOneWidget);
  });
}
