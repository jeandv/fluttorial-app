// ============================================================================
// test/features/onboarding/onboarding_test.dart — FLUJO DE PRIMER USO
// ============================================================================
// Prueba el patrón completo: redirect del router + persistencia.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/features/onboarding/onboarding_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  testWidgets('la primera vez se muestra el onboarding', (tester) async {
    await pumpApp(
      tester,
      initialData: {PrefsKeys.onboardingDone: false, PrefsKeys.locale: 'es'},
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text(onboardingPages.first.title), findsOneWidget);
  });

  testWidgets('"Saltar" termina el onboarding y abre el catálogo', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initialData: {PrefsKeys.onboardingDone: false, PrefsKeys.locale: 'es'},
    );

    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('BÁSICO'), findsOneWidget); // catálogo
  });

  testWidgets('"Siguiente" avanza hasta "Empezar" en la última página', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initialData: {PrefsKeys.onboardingDone: false, PrefsKeys.locale: 'es'},
    );

    for (var i = 0; i < onboardingPages.length - 1; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    expect(find.text(onboardingPages.last.title), findsOneWidget);

    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();
    expect(find.text('BÁSICO'), findsOneWidget);
  });

  testWidgets('si ya se vio, la app arranca directamente en el catálogo', (
    tester,
  ) async {
    await pumpApp(tester, initialData: {PrefsKeys.locale: 'es'});
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('BÁSICO'), findsOneWidget);
  });
}
