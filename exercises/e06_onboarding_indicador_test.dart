// ============================================================================
// exercises/e06_onboarding_indicador_test.dart — RETO: EFECTO DEL INDICADOR
// ============================================================================
//
// ENUNCIADO
//   Cambia el efecto del indicador de páginas del onboarding por
//   `WormEffect`.
//
// ARCHIVO QUE DEBES EDITAR
//   lib/features/onboarding/onboarding_screen.dart
//
// PISTA
//   Busca `SmoothPageIndicator(... effect: ExpandingDotsEffect(...))` y
//   sustituye el efecto. `WormEffect` acepta los mismos `dotHeight`,
//   `dotWidth`, `activeDotColor` y `dotColor`.
//
// CÓMO EJECUTARLO (empieza en ROJO; tu meta es dejarlo en VERDE)
//   flutter test exercises/e06_onboarding_indicador_test.dart
//
// SECCIÓN DE LA GUÍA
//   docs/13-onboarding.md (ejercicios del final)
//
// ¿Atascado? Intenta antes de abrir exercises/solutions/e06_onboarding_indicador.md
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/features/onboarding/onboarding_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  testWidgets('el indicador del onboarding usa WormEffect', (tester) async {
    await pumpApp(
      tester,
      initialData: {PrefsKeys.onboardingDone: false, PrefsKeys.locale: 'es'},
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);

    final indicator = tester.widget<SmoothPageIndicator>(
      find.byType(SmoothPageIndicator),
    );
    expect(indicator.effect, isA<WormEffect>());
  });
}
