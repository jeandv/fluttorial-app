// ============================================================================
// exercises/e01_contador_limite_test.dart — RETO: LÍMITE EN EL CONTADOR
// ============================================================================
//
// ENUNCIADO
//   Desactiva el botón "+" del contador cuando llegue a 20 (igual que "−"
//   está desactivado en 0).
//
// ARCHIVO QUE DEBES EDITAR
//   lib/features/basics/counter_screen.dart
//
// PISTA
//   Mira cómo `onPressed` del botón "−" usa `null` para desactivarse
//   (`_count == 0 ? null : _decrement`). Haz lo mismo con "+".
//
// CÓMO EJECUTARLO (empieza en ROJO; tu meta es dejarlo en VERDE)
//   flutter test exercises/e01_contador_limite_test.dart
//
// SECCIÓN DE LA GUÍA
//   docs/06-construir-la-app.md (sección del contador y setState)
//
// ¿Atascado? Intenta antes de abrir exercises/solutions/e01_contador_limite.md
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/basics/counter_screen.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  // Devuelve el IconButton que contiene el icono dado.
  IconButton buttonWith(WidgetTester tester, IconData icon) =>
      tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)),
      );

  Future<void> tapPlus(WidgetTester tester, int times) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('con 19 el botón "+" sigue activado', (tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const CounterScreen()));
    await tapPlus(tester, 19);

    expect(find.text('19'), findsOneWidget);
    expect(buttonWith(tester, Icons.add).onPressed, isNotNull);
  });

  testWidgets('con 20 el botón "+" se desactiva y el contador se queda en 20', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterialApp(const CounterScreen()));
    await tapPlus(tester, 20);

    expect(find.text('20'), findsOneWidget);
    expect(buttonWith(tester, Icons.add).onPressed, isNull);

    // Tocar un botón desactivado no hace nada: el valor sigue en 20.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('20'), findsOneWidget);
    expect(find.text('21'), findsNothing);
  });

  testWidgets('desde 20 el botón "−" sigue funcionando', (tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const CounterScreen()));
    await tapPlus(tester, 20);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(find.text('19'), findsOneWidget);
    expect(buttonWith(tester, Icons.add).onPressed, isNotNull);
  });
}
