// ============================================================================
// lib/core/settings/settings_controller.dart — AJUSTES GLOBALES (tema e idioma)
// ============================================================================
//
// QUÉ HACE
//   Guarda el tema (claro/oscuro/sistema) y el idioma elegidos por el usuario,
//   los persiste en el teléfono y hace que TODA la app se redibuje al cambiarlos.
//
// CÓMO FUNCIONA (Riverpod: Notifier)
//   - `SettingsController extends Notifier<AppSettings>`: una clase que guarda
//     un estado (AppSettings) y expone métodos para cambiarlo.
//   - `build()` crea el estado inicial (aquí, leyéndolo del almacenamiento).
//   - Al asignar `state = ...`, todos los widgets que hacen
//     `ref.watch(settingsProvider)` se reconstruyen automáticamente.
//   - lib/app.dart lo observa para aplicar `themeMode` y `locale` a MaterialApp.
//
// CÓMO SE USA
//   Leer (y redibujar al cambiar):  final s = ref.watch(settingsProvider);
//   Cambiar:  ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
//
// 📚 Guía: docs/10-funcionalidades-de-la-app.md · docs/11 (sección 2)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado INMUTABLE con los ajustes. Para cambiarlo se crea una copia nueva
/// (patrón `copyWith`): así Riverpod detecta el cambio y redibuja.
@immutable
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;

  /// `null` = usar el idioma del sistema.
  final Locale? locale;

  AppSettings copyWith({ThemeMode? themeMode}) =>
      AppSettings(themeMode: themeMode ?? this.themeMode, locale: locale);

  AppSettings withLocale(Locale? locale) =>
      AppSettings(themeMode: themeMode, locale: locale);
}

class SettingsController extends Notifier<AppSettings> {
  // Getter de conveniencia para acceder al almacenamiento.
  SharedPreferencesWithCache get _prefs => ref.read(sharedPreferencesProvider);

  /// Estado inicial: se lee de forma síncrona desde la caché.
  @override
  AppSettings build() {
    final themeName = _prefs.getString(PrefsKeys.themeMode);
    final languageCode = _prefs.getString(PrefsKeys.locale);

    return AppSettings(
      // ThemeMode.values = [system, light, dark]. Buscamos el guardado por
      // su nombre; si no hay ninguno, usamos el del sistema.
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      ),
      locale: languageCode == null ? null : Locale(languageCode),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode); // 1. actualiza la UI al instante
    await _prefs.setString(PrefsKeys.themeMode, mode.name); // 2. persiste
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.withLocale(locale);
    if (locale == null) {
      await _prefs.remove(PrefsKeys.locale);
    } else {
      await _prefs.setString(PrefsKeys.locale, locale.languageCode);
    }
  }
}

/// Provider global de ajustes.
/// `SettingsController.new` es un "tear-off" del constructor (equivale a
/// `() => SettingsController()`).
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
