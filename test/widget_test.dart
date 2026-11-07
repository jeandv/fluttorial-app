// ============================================================================
// test/widget_test.dart — PRUEBA DE WIDGET DE EJEMPLO
// ============================================================================
//
// Las pruebas de widget dibujan un widget en un entorno simulado (SIN abrir
// simuladores ni emuladores) y comprueban que se comporta como esperas.
// Son muy rápidas: ideales para ejecutar antes de cada commit.
//
// Cómo ejecutar:
//   flutter test                              → todas las pruebas de test/
//   flutter test test/widget_test.dart        → solo este archivo
//   flutter test --name "contador"            → solo las que coinciden por nombre
//   En VS Code: botón ▶ "Run" que aparece encima de cada testWidgets.
//
// Reglas:
//   - Los archivos de prueba deben terminar en `_test.dart`.
//   - Deben estar dentro de la carpeta test/ (puedes crear subcarpetas).
//
// 📚 Más: docs/07-pruebas-y-calidad.md y test/README.md
// ============================================================================

import 'package:flutter/material.dart';
// flutter_test: herramientas de prueba (testWidgets, find, expect…).
// Está en dev_dependencies de pubspec.yaml: no se incluye en la app final.
import 'package:flutter_test/flutter_test.dart';

// Importa el código de TU app usando el nombre del paquete (definido en
// `name:` de pubspec.yaml) + la ruta dentro de lib/.
import 'package:mi_primera_app/main.dart';

void main() {
  // testWidgets define una prueba. El primer argumento es su descripción;
  // `tester` permite dibujar widgets e interactuar con ellos.
  testWidgets('El contador empieza en 0 y sube a 1 al pulsar +', (
    WidgetTester tester,
  ) async {
    // 1. PREPARAR: dibuja la app completa y genera el primer frame.
    await tester.pumpWidget(const MyApp());

    // 2. COMPROBAR el estado inicial.
    //    find.text('0') busca widgets Text cuyo contenido sea exactamente '0'.
    //    findsOneWidget → debe haber exactamente uno.
    //    findsNothing   → no debe haber ninguno.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 3. ACTUAR: toca el icono "+" y avanza un frame para que se aplique
    //    el setState().
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // 4. COMPROBAR el resultado.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  // 💡 Ejercicio: añade aquí otra prueba que pulse "+" tres veces y compruebe
  //    que aparece '3'. Pista: repite tester.tap(...) y tester.pump().
}
