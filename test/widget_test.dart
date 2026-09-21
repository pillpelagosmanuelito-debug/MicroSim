import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microsim/app.dart';

void main() {
  testWidgets('MicroSimApp se construye sin errores', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MicroSimApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MicroSimApp), findsOneWidget);
  });
}
