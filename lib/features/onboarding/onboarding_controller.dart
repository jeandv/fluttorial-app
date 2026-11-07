// ============================================================================
// lib/features/onboarding/onboarding_controller.dart — ¿YA VIO EL ONBOARDING?
// ============================================================================
//
// QUÉ HACE
//   Guarda en el teléfono si el usuario ya completó (o saltó) el onboarding.
//   El router (app_router.dart → redirect) lo consulta al abrir la app:
//     - false → manda al usuario a /onboarding
//     - true  → la app arranca normalmente en /ejemplos
//
// POR QUÉ UN PROVIDER Y NO SOLO shared_preferences
//   Al llamar a complete(), el estado cambia → el router (que escucha este
//   provider con refreshListenable) vuelve a evaluar `redirect` y saca al
//   usuario del onboarding automáticamente. Sin código de navegación extra.
//
// 📚 Guía: docs/13-onboarding.md
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends Notifier<bool> {
  SharedPreferencesWithCache get _prefs => ref.read(sharedPreferencesProvider);

  /// Estado inicial: lo guardado (por defecto false = primera vez).
  @override
  bool build() => _prefs.getBool(PrefsKeys.onboardingDone) ?? false;

  /// Marca el onboarding como visto (botón "Empezar" o "Saltar").
  Future<void> complete() async {
    state = true;
    await _prefs.setBool(PrefsKeys.onboardingDone, true);
  }

  /// Vuelve a mostrarlo (botón en Ajustes, útil para probar).
  Future<void> reset() async {
    state = false;
    await _prefs.remove(PrefsKeys.onboardingDone);
  }
}

final onboardingDoneProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);
