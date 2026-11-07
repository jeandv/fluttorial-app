# 📱 Mi Primera App — Guía completa de Flutter para iOS y Android

Este proyecto es a la vez **una app Flutter funcional** (un contador) y **una guía de referencia** para aprender a crear, ejecutar, simular, probar y publicar apps móviles con Flutter desde una Mac.

Cada archivo importante está **comentado en español** y cada carpeta clave tiene su propio `README.md`.

---

## 🚀 Inicio rápido (5 comandos)

```bash
cd ~/Documents/dev/tutorial-mobile-dev/mi_primera_app
xcrun simctl boot "iPhone 18 Pro"                    # 1. encender iPhone simulado
flutter emulators --launch Medium_Phone_API_37.0     # 2. encender Android emulado
flutter devices                                      # 3. comprobar que Flutter los ve
flutter run -d all                                   # 4. ejecutar en ambos
# 5. edita lib/main.dart, guarda y pulsa "r" (hot reload). "q" para salir.
```

¿Primera vez? La primera compilación descarga y compila mucho (de 3 a 10 minutos). Las siguientes tardan segundos. Más detalles en [04 · Ejecutar y simular](docs/04-ejecutar-y-simular.md).

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

### Guías por carpeta

| Carpeta | README |
|---|---|
| `lib/` (tu código) | [lib/README.md](lib/README.md) |
| `test/` (pruebas) | [test/README.md](test/README.md) |
| `android/` (nativo Android) | [android/README.md](android/README.md) |
| `ios/` (nativo iOS) | [ios/README.md](ios/README.md) |

### Archivos comentados línea por línea

| Archivo | Qué explica |
|---|---|
| [lib/main.dart](lib/main.dart) | `main()`, `MaterialApp`, `StatelessWidget` vs. `StatefulWidget`, `setState`, `Scaffold`, layout |
| [test/widget_test.dart](test/widget_test.dart) | Cómo se escribe una prueba de widget |
| [pubspec.yaml](pubspec.yaml) | Versión, dependencias, assets y fuentes |
| [analysis_options.yaml](analysis_options.yaml) | Reglas del linter |
| [android/app/build.gradle.kts](android/app/build.gradle.kts) | ID de la app, `minSdk` y firma de Android |
| [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) | Nombre visible y permisos de Android |
| [ios/Runner/AppDelegate.swift](ios/Runner/AppDelegate.swift) | Punto de entrada nativo de iOS |
| [.vscode/launch.json](.vscode/launch.json) | Perfiles para ejecutar desde VS Code (F5) |

---

## 🗺️ El proceso completo, de la idea a la tienda

```
 1. Preparar el entorno        flutter doctor                         → docs/01
 2. Crear el proyecto          flutter create --org com.tunombre app  → docs/02
 3. Encender los simuladores   xcrun simctl boot / flutter emulators  → docs/04
 4. Ejecutar                   flutter run                            → docs/04
 5. Programar las pantallas    lib/ + hot reload (r)                  → docs/05, docs/06
 6. Añadir paquetes            flutter pub add <paquete>              → docs/06
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
| Flutter / Dart | 3.47.9 / 3.13.7 (canal stable) |
| Nombre del paquete | `mi_primera_app` |
| Nombre visible | Mi Primera App |
| ID en Android | `com.jeanrondon.mi_primera_app` |
| Bundle ID en iOS | `com.jeanrondon.miPrimeraApp` |
| iOS mínimo | 15.0 |
| Versión | `1.0.0+1` |
| Plataformas generadas | android, ios, web, macos, windows, linux |
| Simulador iOS | iPhone 18 Pro (iOS 27.2) |
| Emulador Android | `Medium_Phone_API_37.0` |

---

## 🔗 Recursos oficiales

- Documentación de Flutter: [docs.flutter.dev](https://docs.flutter.dev)
- Catálogo de widgets: [docs.flutter.dev/ui/widgets](https://docs.flutter.dev/ui/widgets)
- Paquetes: [pub.dev](https://pub.dev)
- El lenguaje Dart: [dart.dev/language](https://dart.dev/language)
- Practicar Dart y Flutter en el navegador: [dartpad.dev](https://dartpad.dev)
- Codelab oficial "Tu primera app Flutter": [docs.flutter.dev/get-started/codelab](https://docs.flutter.dev/get-started/codelab)
- Canal de YouTube de Flutter (serie *Widget of the Week*): [youtube.com/@flutterdev](https://www.youtube.com/@flutterdev)
# fluttorial-app
# fluttorial-app
# fluttorial-app
