// ============================================================================
// lib/app.dart — WIDGET RAÍZ DE LA APLICACIÓN
// ============================================================================
//
// QUÉ HACE
//   Configura MaterialApp con todo lo global:
//   - Navegación (routerConfig → go_router, ver core/router/app_router.dart)
//   - Tema claro, oscuro y cuál usar (core/theme/app_theme.dart + ajustes)
//   - Idiomas soportados y traducciones (lib/l10n/)
//
// CÓMO FUNCIONA
//   Es un ConsumerWidget: puede leer providers con `ref.watch`.
//   Cuando el usuario cambia el tema o el idioma en Ajustes, settingsProvider
//   cambia → este build() se vuelve a ejecutar → MaterialApp aplica el cambio
//   a TODA la app, sin reiniciarla.
//
// MaterialApp vs MaterialApp.router
//   - MaterialApp(home: ...)            → navegación clásica con Navigator.
//   - MaterialApp.router(routerConfig:) → navegación con un router (go_router).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/config/env.dart';
import 'package:mi_primera_app/core/router/app_router.dart';
import 'package:mi_primera_app/core/settings/settings_controller.dart';
import 'package:mi_primera_app/core/theme/app_theme.dart';
import 'package:mi_primera_app/l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      // Título para el sistema (multitarea de Android). Se traduce, por eso
      // se usa onGenerateTitle en lugar de `title`.
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,

      // Franja "DEBUG": controlada por --dart-define=SHOW_DEBUG_BANNER=true
      debugShowCheckedModeBanner: Env.showDebugBanner,

      // ------------------------------------------------------------- TEMA
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode, // system / light / dark
      // ----------------------------------------------------------- IDIOMA
      // null = usar el idioma del teléfono (si está en supportedLocales).
      locale: settings.locale,
      // Delegates: cargan las traducciones de tu app (AppLocalizations) y de
      // los widgets de Flutter (Material, Cupertino, textos de diálogos…).
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Idiomas disponibles: se generan a partir de los .arb (es, en).
      supportedLocales: AppLocalizations.supportedLocales,

      // ------------------------------------------------------- NAVEGACIÓN
      routerConfig: router,
    );
  }
}
