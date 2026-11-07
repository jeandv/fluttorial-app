// ============================================================================
// test/features/advanced/animations_test.dart — PRUEBA DE REGRESIÓN
// ============================================================================
// Una "prueba de regresión" reproduce un error que ya ocurrió para que no
// vuelva a aparecer sin que nos demos cuenta.
//
// El error: AnimatedContainer animaba el ancho de 120 a double.infinity y
// Flutter lanzaba "Cannot interpolate between finite constraints and
// unbounded constraints" al pulsar "Tócame".
//
// Si una prueba de widget provoca una excepción de Flutter, el test FALLA
// automáticamente; además lo comprobamos de forma explícita con
// tester.takeException().
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/advanced/animations_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('AnimatedContainer se expande y se contrae sin errores', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithMaterialApp(const AnimationsScreen()));

    final box = find.text('Tócame');
    // Hay varios AnimatedContainer en pantalla (algunos widgets de Material
    // los usan por dentro): buscamos el que CONTIENE el texto "Tócame".
    final container = find.ancestor(
      of: box,
      matching: find.byType(AnimatedContainer),
    );
    final initialWidth = tester.getSize(container).width;
    expect(initialWidth, 120);

    // Expandir: recorre TODA la animación (pumpAndSettle avanza fotogramas
    // hasta que termina).
    await tester.tap(box);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(container).width, greaterThan(initialWidth));

    // Contraer de nuevo.
    await tester.tap(box);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(container).width, 120);
  });
}
