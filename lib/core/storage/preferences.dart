// ============================================================================
// lib/core/storage/preferences.dart — ALMACENAMIENTO LOCAL (shared_preferences)
// ============================================================================
//
// QUÉ HACE
//   Guarda datos pequeños en el teléfono de forma persistente (sobreviven al
//   cerrar la app): ajustes, la lista de tareas en JSON, flags…
//   - iOS:     NSUserDefaults
//   - Android: DataStore / SharedPreferences
//
// CÓMO FUNCIONA
//   1. En main() se crea UNA instancia de SharedPreferencesWithCache (carga los
//      valores del disco a memoria; operación asíncrona).
//   2. Se "inyecta" en Riverpod con `sharedPreferencesProvider.overrideWithValue`.
//   3. Cualquier provider la lee con `ref.read(sharedPreferencesProvider)` y
//      puede leer valores de forma SÍNCRONA (desde la caché).
//
//   Este patrón (provider que lanza error + override en main) es la forma
//   estándar de inyectar en Riverpod objetos que necesitan inicializarse con
//   `await` antes de arrancar la app. En los tests se sobrescribe con una
//   versión en memoria (ver test/helpers/test_helpers.dart).
//
// CUÁNDO NO USARLO
//   - Datos sensibles (tokens, contraseñas) → flutter_secure_storage.
//   - Muchos datos o consultas complejas → base de datos (drift, sqflite, isar).
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 5)
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claves usadas en el almacenamiento. Tenerlas centralizadas evita errores
/// de tipeo y permite declarar la "allowList" (lista de claves permitidas).
abstract final class PrefsKeys {
  static const themeMode = 'settings.themeMode';
  static const locale = 'settings.locale';
  static const todos = 'todos.items';

  /// Todas las claves que la app puede leer/escribir.
  static const all = <String>{themeMode, locale, todos};
}

/// Crea la instancia de almacenamiento. Se llama una vez en main().
Future<SharedPreferencesWithCache> createPreferences() {
  return SharedPreferencesWithCache.create(
    // allowList: solo estas claves se cargan en caché y se pueden usar.
    // Es una buena práctica de seguridad y rendimiento.
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: PrefsKeys.all,
    ),
  );
}

/// Provider que da acceso al almacenamiento desde cualquier parte de la app.
///
/// Lanza un error a propósito: DEBE sobrescribirse en main() (o en los tests)
/// con `sharedPreferencesProvider.overrideWithValue(prefs)`.
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider debe sobrescribirse en main() con overrideWithValue',
  );
});
