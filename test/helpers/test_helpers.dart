// ============================================================================
// test/helpers/test_helpers.dart — UTILIDADES COMPARTIDAS PARA LOS TESTS
// ============================================================================
//
// QUÉ HACE
//   1. createTestPreferences(): crea un almacenamiento EN MEMORIA (no toca el
//      disco del teléfono) para que cada test empiece limpio y sea rápido.
//   2. pumpApp(): dibuja la app completa (MyApp) con Riverpod configurado.
//   3. wrapWithMaterialApp(): envuelve UN widget en MaterialApp con
//      traducciones, para probar pantallas sueltas.
//
// POR QUÉ
//   Los providers que dependen del disco o de internet se SOBRESCRIBEN
//   (overrides) en los tests. Es la gran ventaja de la inyección de
//   dependencias con Riverpod: el código de la app no cambia, solo lo que
//   se le inyecta.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/app.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Almacenamiento en memoria, opcionalmente con datos iniciales.
Future<SharedPreferencesWithCache> createTestPreferences([
  Map<String, Object> initialData = const {},
]) {
  // Sustituye la implementación nativa por una en memoria.
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(initialData);
  return createPreferences();
}

/// Dibuja la app completa con las preferencias de prueba.
Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> initialData = const {},
  List<Override> overrides = const [],
}) async {
  // Por defecto marcamos el onboarding como visto, para que los tests
  // arranquen en el catálogo. Pásalo como false para probar el onboarding.
  final prefs = await createTestPreferences({
    PrefsKeys.onboardingDone: true,
    ...initialData,
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...overrides,
      ],
      child: const MyApp(),
    ),
  );
  // Espera a que terminen animaciones y la primera navegación.
  await tester.pumpAndSettle();
}

/// Envuelve un widget suelto en lo mínimo para que funcione (tema,
/// traducciones, Scaffold para SnackBars…).
Widget wrapWithMaterialApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: child,
);
