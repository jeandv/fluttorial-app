// ============================================================================
// exercises/e04_mi_demo_test.dart — RETO: TU PROPIA DEMO EN EL CATÁLOGO
// ============================================================================
//
// ENUNCIADO
//   Añade al catálogo (nivel básico) una demo titulada `Mi demo` que se abra
//   al tocarla y use `DemoScaffold`.
//
// ARCHIVOS QUE DEBES EDITAR / CREAR
//   - lib/features/basics/mi_demo_screen.dart   (nuevo: la pantalla)
//   - lib/core/router/routes.dart               (constante de la ruta)
//   - lib/core/router/app_router.dart           (GoRoute)
//   - lib/features/catalog/demo_catalog.dart    (entrada en `demos`)
//
// PISTA
//   Copia el patrón de una demo existente (por ejemplo el contador): una
//   ruta en AppRoutes, un GoRoute que construya la pantalla y un `Demo(...)`
//   con `level: DemoLevel.basic`.
//
// CÓMO EJECUTARLO (empieza en ROJO; tu meta es dejarlo en VERDE)
//   flutter test exercises/e04_mi_demo_test.dart
//
// SECCIÓN DE LA GUÍA
//   docs/10-funcionalidades-de-la-app.md (cómo añadir una demo)
//
// ¿Atascado? Intenta antes de abrir exercises/solutions/e04_mi_demo.md
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  testWidgets(
    'el catálogo muestra "Mi demo" y al tocarla abre un DemoScaffold',
    (tester) async {
      await pumpApp(tester, initialData: {PrefsKeys.locale: 'es'});

      // La entrada puede estar fuera de pantalla: desplázate hasta verla.
      final entry = find.text('Mi demo');
      await tester.scrollUntilVisible(
        entry,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(entry, findsOneWidget);
      // Asegura que la fila quede entera sobre la barra inferior.
      await tester.ensureVisible(entry);
      await tester.pumpAndSettle();

      await tester.tap(entry);
      await tester.pumpAndSettle();

      // Estamos en otra pantalla (con botón de volver) construida con DemoScaffold.
      expect(find.byType(DemoScaffold), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    },
  );
}
