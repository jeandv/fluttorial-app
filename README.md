# 📱 Mi Primera App — Guía completa de Flutter para iOS y Android

Este proyecto es a la vez **una app Flutter real** y **una guía de referencia** para aprender a crear, ejecutar, simular, probar y publicar apps móviles con Flutter desde una Mac.

La app es un **catálogo interactivo de 13 demos** (básicas, intermedias y avanzadas) más una mini-app de **tareas** y una pantalla de **ajustes**. Todo el código está **comentado en español**: qué hace cada parte, cómo funciona y cómo se hace. La documentación enlaza directamente a las **líneas de código** de cada concepto.

---

## 🚀 Inicio rápido

```bash
cd ~/Documents/dev/tutorial-mobile-dev/mi_primera_app
xcrun simctl boot "iPhone 18 Pro"                    # 1. encender iPhone simulado
flutter emulators --launch Medium_Phone_API_37.0     # 2. encender Android emulado
flutter devices                                      # 3. comprobar que Flutter los ve
flutter run -d all                                   # 4. ejecutar en ambos
# 5. edita el código, guarda y pulsa "r" (hot reload). "q" para salir.
```

Con variables de entorno: `flutter run --dart-define-from-file=config/dev.json`. Desde VS Code: `Cmd+Shift+D` → **iPhone + Android** → F5.

¿Primera vez? La primera compilación descarga y compila mucho (de 3 a 10 minutos). Más detalles en [04 · Ejecutar y simular](docs/04-ejecutar-y-simular.md).

---

## 🎓 Qué incluye la app

| Nivel | Demo | Qué enseña | Código |
|---|---|---|---|
| 🟢 Básico | Contador | `StatefulWidget`, `setState`, ciclo de vida | [counter_screen.dart](lib/features/basics/counter_screen.dart) |
| 🟢 Básico | Layout | `Row`, `Column`, `Expanded`, `Stack`, `Wrap`, `Container` | [layout_screen.dart](lib/features/basics/layout_screen.dart) |
| 🟢 Básico | Widgets comunes | Botones, controles, diálogos, SnackBars, chips | [widgets_screen.dart](lib/features/basics/widgets_screen.dart) |
| 🟢 Básico | Listas | `ListView.builder`, `GridView`, deslizar para borrar, recargar | [lists_screen.dart](lib/features/basics/lists_screen.dart) |
| 🟠 Intermedio | Formularios | Validación, controladores, foco, selector de fecha | [forms_screen.dart](lib/features/intermediate/forms_screen.dart) |
| 🟠 Intermedio | Navegación | go_router: parámetros, resultados, rutas protegidas | [navigation_screens.dart](lib/features/intermediate/navigation_screens.dart) |
| 🟠 Intermedio | Asincronía | `Future`, `async/await`, `FutureBuilder`, `StreamBuilder`, `Timer` | [async_screen.dart](lib/features/intermediate/async_screen.dart) |
| 🟠 Intermedio | API REST | `http` + JSON + Riverpod (`FutureProvider`, `family`) | [lib/features/posts/](lib/features/posts/) |
| 🟠 Intermedio | Idiomas | Traducciones `.arb`, plurales, fechas y monedas | [localization_screen.dart](lib/features/intermediate/localization_screen.dart) |
| 🔴 Avanzado | Animaciones | Implícitas, `AnimationController`, `Hero` | [animations_screen.dart](lib/features/advanced/animations_screen.dart) |
| 🔴 Avanzado | Diseño adaptable | `MediaQuery`, `LayoutBuilder`, widgets `.adaptive` | [responsive_screen.dart](lib/features/advanced/responsive_screen.dart) |
| 🔴 Avanzado | Código nativo | `MethodChannel` Dart ↔ Kotlin ↔ Swift | [native_channel.dart](lib/features/advanced/native_channel.dart) |
| 🔴 Avanzado | Isolates | Trabajo pesado sin congelar la interfaz | [isolates_screen.dart](lib/features/advanced/isolates_screen.dart) |
| ✅ Pestaña | Tareas | Riverpod `Notifier`, persistencia, deshacer, filtros | [lib/features/todos/](lib/features/todos/) |
| ⚙️ Pestaña | Ajustes | Tema claro/oscuro e idioma persistidos, entorno | [settings_screen.dart](lib/features/settings/settings_screen.dart) |

**Infraestructura:** go_router con pestañas y redirects · Riverpod 3 · tema Material 3 con `ThemeExtension` · i18n es/en · `shared_preferences` · cliente HTTP con errores tipados · `--dart-define` · 21 tests · CI en GitHub Actions.

---

## 📚 Índice de la guía

| # | Documento | Qué aprenderás |
|---|---|---|
| 01 | [Entorno e instalación](docs/01-entorno-e-instalacion.md) | Qué hay instalado en la Mac, para qué sirve cada herramienta, cómo verificar y actualizar |
| 02 | [Estructura del proyecto](docs/02-estructura-del-proyecto.md) | Qué es cada carpeta y archivo, qué se edita, qué es generado, qué se sube a git |
| 03 | [Comandos](docs/03-comandos.md) | Todos los comandos: diarios, comunes, de compilación, poco usados, `xcrun simctl`, `adb`, `gradlew` |
| 04 | [Ejecutar y simular](docs/04-ejecutar-y-simular.md) | Simuladores iOS, emuladores Android, teléfonos reales, VS Code, hot reload, DevTools |
| 05 | [Dart esencial](docs/05-dart-esencial.md) | El lenguaje: variables, null safety, clases, async/await, records, pattern matching |
| 06 | [Construir la app](docs/06-construir-la-app.md) | Widgets, layout, navegación, estado, paquetes, assets, APIs, permisos, temas |
| 07 | [Pruebas y calidad](docs/07-pruebas-y-calidad.md) | Pruebas unitarias, de widget y de integración; linter, formato, cobertura |
| 08 | [Compilar y publicar](docs/08-compilar-y-publicar.md) | Icono, versión, firma, APK/AAB, IPA, Google Play, App Store, TestFlight |
| 09 | [Solución de problemas](docs/09-solucion-de-problemas.md) | Errores comunes de instalación, iOS, Android, Dart y cómo resolverlos |
| 10 | [**Funcionalidades de la app**](docs/10-funcionalidades-de-la-app.md) | Cada demo, concepto por concepto, con enlace a la línea de código |
| 11 | [**Configuraciones avanzadas**](docs/11-configuraciones-avanzadas.md) | Arquitectura, go_router, Riverpod, tema, i18n, persistencia, entornos, red, código nativo, codegen, tests, CI |

> 🔗 **Enlaces al código:** en los documentos, los recuadros **📂 En este proyecto** y las tablas enlazan a la línea exacta (`archivo.dart#L42`). Funcionan en GitHub y en VS Code (vista previa del Markdown: `Cmd+Shift+V`). Si el código cambia: `dart run tool/update_doc_links.dart`.

### Guías por carpeta

| Carpeta | README |
|---|---|
| `lib/` (tu código) | [lib/README.md](lib/README.md) |
| `test/` (pruebas) | [test/README.md](test/README.md) |
| `android/` (nativo Android) | [android/README.md](android/README.md) |
| `ios/` (nativo iOS) | [ios/README.md](ios/README.md) |

### Archivos de configuración comentados

| Archivo | Qué explica |
|---|---|
| [lib/main.dart](lib/main.dart) | Orden de arranque, `ProviderScope`, inyección de dependencias |
| [lib/app.dart](lib/app.dart) | `MaterialApp.router`: tema, idioma y rutas |
| [lib/core/router/app_router.dart](lib/core/router/app_router.dart) | Todas las rutas, pestañas, redirect, 404 |
| [pubspec.yaml](pubspec.yaml) | Versión, dependencias (y para qué sirve cada una), assets, fuentes |
| [l10n.yaml](l10n.yaml) | Configuración de traducciones |
| [analysis_options.yaml](analysis_options.yaml) | Reglas del linter |
| [android/app/build.gradle.kts](android/app/build.gradle.kts) | ID de la app, `minSdk` y firma de Android |
| [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) | Nombre visible y permisos de Android |
| [MainActivity.kt](android/app/src/main/kotlin/com/jeanrondon/mi_primera_app/MainActivity.kt) | Entrada nativa Android + `MethodChannel` en Kotlin |
| [ios/Runner/AppDelegate.swift](ios/Runner/AppDelegate.swift) | Entrada nativa iOS + `MethodChannel` en Swift |
| [.vscode/launch.json](.vscode/launch.json) | Perfiles para ejecutar desde VS Code (F5) |
| [.github/workflows/flutter-ci.yml](.github/workflows/flutter-ci.yml) | Tests automáticos en cada push a GitHub |
| [tool/update_doc_links.dart](tool/update_doc_links.dart) | Script que mantiene los enlaces a líneas de la documentación |

---

## 🗺️ El proceso completo, de la idea a la tienda

```
 1. Preparar el entorno        flutter doctor                         → docs/01
 2. Crear el proyecto          flutter create --org com.tunombre app  → docs/02
 3. Encender los simuladores   xcrun simctl boot / flutter emulators  → docs/04
 4. Ejecutar                   flutter run                            → docs/04
 5. Programar las pantallas    lib/ + hot reload (r)                  → docs/05, 06, 10
 6. Añadir paquetes            flutter pub add <paquete>              → docs/06, 11
 7. Probar                     flutter analyze && flutter test        → docs/07
 8. Probar en un teléfono real flutter run -d <id> --release          → docs/04
 9. Preparar la publicación    icono, nombre, versión, firma          → docs/08
10. Compilar                   flutter build appbundle / ipa          → docs/08
11. Publicar                   Google Play Console / App Store Connect → docs/08
```

---

## 🧾 Datos de este proyecto

| | Valor |
|---|---|
| Repositorio | `jeandv/fluttorial-app` |
| Flutter / Dart | 3.47.9 / 3.13.7 (canal stable) |
| Paquetes principales | go_router 18 · flutter_riverpod 3 · http 1 · shared_preferences 2 · intl 0.20 |
| Nombre del paquete | `mi_primera_app` |
| Nombre visible | Mi Primera App |
| ID en Android | `com.jeanrondon.mi_primera_app` |
| Bundle ID en iOS | `com.jeanrondon.miPrimeraApp` |
| iOS mínimo | 15.0 |
| Versión | `1.0.0+1` |
| Idiomas | Español (plantilla), inglés |
| Simulador iOS | iPhone 18 Pro (iOS 27.2) |
| Emulador Android | `Medium_Phone_API_37.0` |

---

## 🔗 Recursos oficiales

- Documentación de Flutter: [docs.flutter.dev](https://docs.flutter.dev)
- Catálogo de widgets: [docs.flutter.dev/ui/widgets](https://docs.flutter.dev/ui/widgets)
- Paquetes: [pub.dev](https://pub.dev)
- El lenguaje Dart: [dart.dev/language](https://dart.dev/language)
- Riverpod: [riverpod.dev](https://riverpod.dev) · go_router: [pub.dev/packages/go_router](https://pub.dev/packages/go_router)
- Practicar Dart y Flutter en el navegador: [dartpad.dev](https://dartpad.dev)
<<<<<<< HEAD
- Codelab oficial "Tu primera app Flutter": [docs.flutter.dev/get-started/codelab](https://docs.flutter.dev/get-started/codelab)
=======
- Canal de YouTube de Flutter (serie *Widget of the Week*): [youtube.com/@flutterdev](https://www.youtube.com/@flutterdev)
>>>>>>> 83b9d26 (feat: turn app into documented Flutter showcase with demos, tests and guides)
