// ============================================================================
// lib/main.dart — PUNTO DE ENTRADA DE LA APP
// ============================================================================
//
// Este es el primer archivo que ejecuta Flutter. Su ÚNICO trabajo es preparar
// lo necesario ANTES de dibujar la primera pantalla y arrancar la app.
//
// ORDEN DE ARRANQUE
//   1. WidgetsFlutterBinding.ensureInitialized()
//        Obligatorio si haces `await` (o usas plugins) antes de runApp().
//   2. await createPreferences()
//        Carga los datos guardados (tema, idioma, tareas) desde el disco.
//   3. runApp(ProviderScope(...))
//        ProviderScope es el "contenedor" de Riverpod: guarda el estado de
//        TODOS los providers. Debe envolver la app entera.
//        `overrides` inyecta objetos ya inicializados (las preferencias).
//   4. MyApp (lib/app.dart) configura tema, idiomas y rutas.
//
// ESTRUCTURA DEL PROYECTO (lib/)
//   main.dart            → este archivo (arranque)
//   app.dart             → MaterialApp: tema, idioma, router
//   core/                → piezas compartidas: router, tema, red, almacenamiento
//   features/            → una carpeta por funcionalidad (demos, tareas, ajustes…)
//   l10n/                → traducciones (.arb) y código generado
//
// Cómo ejecutarla:
//   flutter run                                         → modo debug
//   flutter run --dart-define-from-file=config/dev.json → con variables de entorno
//   Teclas: r = hot reload · R = hot restart · q = salir · h = ayuda
//
// 📚 Guías: docs/10-funcionalidades-de-la-app.md · docs/11-configuraciones-avanzadas.md
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/app.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';

/// `async` porque esperamos a cargar las preferencias antes de arrancar.
/// ⚠️ Los cambios en main() NO se aplican con hot reload (r): usa "R".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await createPreferences();

  runApp(
    ProviderScope(
      overrides: [
        // Sustituye el provider "vacío" por la instancia real ya cargada.
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const MyApp(),
    ),
  );
}
