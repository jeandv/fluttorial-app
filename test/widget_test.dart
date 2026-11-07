// ============================================================================
// test/widget_test.dart — PRUEBAS DE WIDGETS (pantallas y app completa)
// ============================================================================
//
// Las pruebas de widget dibujan widgets en un entorno simulado (SIN abrir
// simuladores ni emuladores) y comprueban que se comportan como esperas.
// Son muy rápidas: ideales para ejecutar antes de cada commit.
//
// Cómo ejecutar:
//   flutter test                              → todas las pruebas de test/
//   flutter test test/widget_test.dart        → solo este archivo
//   flutter test --name "contador"            → solo las que coinciden por nombre
//   En VS Code: botón ▶ "Run" que aparece encima de cada testWidgets.
//
// Patrón de cada prueba: PREPARAR → ACTUAR → COMPROBAR.
//
// 📚 Más: docs/07-pruebas-y-calidad.md y test/README.md
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/features/basics/counter_screen.dart';

import 'helpers/test_helpers.dart';

void main() {
  // group agrupa pruebas relacionadas (aparecen juntas en el informe).
  group('CounterScreen (setState)', () {
    testWidgets('el contador empieza en 0 y sube a 1 al pulsar +', (
      tester,
    ) async {
      // 1. PREPARAR: dibuja la pantalla suelta dentro de un MaterialApp.
      await tester.pumpWidget(wrapWithMaterialApp(const CounterScreen()));

      // 2. COMPROBAR el estado inicial.
      //    findsOneWidget → exactamente uno · findsNothing → ninguno.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // 3. ACTUAR: toca "+" y espera a que termine la animación del número.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 4. COMPROBAR el resultado.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('el botón "-" está desactivado cuando el valor es 0', (
      tester,
    ) async {
      await tester.pumpWidget(wrapWithMaterialApp(const CounterScreen()));

      // Buscar el IconButton que contiene el icono "remove".
      final minusButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.remove),
          matching: find.byType(IconButton),
        ),
      );
      expect(minusButton.onPressed, isNull); // null = desactivado
    });
  });

  group('App completa', () {
    testWidgets('arranca en el catálogo y navega por las pestañas', (
      tester,
    ) async {
      // Idioma guardado = español (si no, usaría el del entorno de test: en).
      await pumpApp(tester, initialData: {PrefsKeys.locale: 'es'});

      // Catálogo visible con sus niveles.
      expect(find.text('Ejemplos'), findsWidgets);
      expect(find.text('BÁSICO'), findsOneWidget);
      expect(find.text('Contador (setState)'), findsOneWidget);

      // Cambiar a la pestaña "Tareas" tocando la barra inferior.
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pumpAndSettle();
      expect(find.text('No tienes tareas pendientes'), findsOneWidget);
    });

    testWidgets('abre una demo desde el catálogo (go_router push)', (
      tester,
    ) async {
      await pumpApp(tester, initialData: {PrefsKeys.locale: 'es'});

      await tester.tap(find.text('Contador (setState)'));
      await tester.pumpAndSettle();

      expect(find.text('Contador'), findsOneWidget); // título del AppBar
      expect(find.byType(BackButton), findsOneWidget); // se puede volver
    });

    testWidgets('respeta el idioma inglés guardado', (tester) async {
      await pumpApp(tester, initialData: {PrefsKeys.locale: 'en'});

      expect(find.text('Examples'), findsWidgets);
      expect(find.text('BASIC'), findsOneWidget);
    });
  });
}
