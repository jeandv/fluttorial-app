# 03 · Comandos (de los más usados a los menos usados)

> Anterior: [02 · Estructura](02-estructura-del-proyecto.md) · Volver al [índice](../README.md) · Siguiente: [04 · Ejecutar y simular](04-ejecutar-y-simular.md)

Todos los comandos `flutter ...` se ejecutan **dentro de la carpeta del proyecto** (donde está `pubspec.yaml`), salvo `flutter create`, `flutter doctor`, `flutter upgrade` y similares.

```bash
cd ~/Documents/dev/tutorial-mobile-dev/mi_primera_app
```

Ayuda siempre disponible:
```bash
flutter help              # lista de comandos
flutter help run          # opciones de un comando
flutter help -v           # incluye opciones poco comunes
```

---

## 🥇 Nivel 1 — Los que usarás todos los días

| Comando | Qué hace |
|---|---|
| `flutter run` | Compila en modo **debug**, instala y abre la app en el dispositivo. Activa hot reload |
| `flutter run -d <id>` | Igual, eligiendo dispositivo (`-d emulator-5554`, `-d <UDID-iPhone>`, `-d all`) |
| `flutter devices` | Lista dispositivos/simuladores conectados y sus IDs |
| `flutter emulators` | Lista emuladores disponibles |
| `flutter emulators --launch <id>` | Arranca un emulador (ej. `Medium_Phone_API_37.0`) |
| `flutter pub get` | Descarga las dependencias de `pubspec.yaml` |
| `flutter pub add <paquete>` | Añade un paquete a `pubspec.yaml` y lo descarga |
| `flutter analyze` | Busca errores, advertencias y problemas de estilo |
| `flutter test` | Ejecuta todas las pruebas de `test/` |
| `dart format .` | Formatea todo el código con el estilo oficial |

### Teclas dentro de `flutter run`

| Tecla | Acción |
|---|---|
| `r` | **Hot reload** — aplica cambios en ~1 s conservando el estado |
| `R` | **Hot restart** — reinicia la app desde `main()` (pierde el estado) |
| `h` | Muestra todas las teclas disponibles en tu versión |
| `q` | Detiene la app y sale |
| `d` | Desconecta la terminal pero deja la app corriendo |
| `c` | Limpia la pantalla de la terminal |
| `s` | Guarda una captura de pantalla del dispositivo |
| `v` | Abre **Flutter DevTools** en el navegador |
| `p` | Muestra/oculta líneas guía de layout (*debug paint*) |
| `P` | Muestra/oculta el overlay de rendimiento (FPS) |
| `o` | Alterna la plataforma simulada (look Android ↔ iOS) |
| `b` | Alterna tema claro/oscuro |
| `w` | Imprime el árbol de widgets en la terminal |
| `t` | Imprime el árbol de renderizado |

> **Hot reload no basta** cuando cambias: `main()`, `initState()`, variables globales/estáticas, `pubspec.yaml`, assets nuevos o código nativo. En esos casos usa `R` o detén y vuelve a ejecutar.

---

## 🥈 Nivel 2 — Muy comunes (varias veces por semana)

### Proyecto
| Comando | Qué hace |
|---|---|
| `flutter create mi_app` | Crea un proyecto nuevo |
| `flutter create --org com.tunombre mi_app` | Define el prefijo del ID de la app (`com.tunombre.mi_app`) |
| `flutter create --platforms=android,ios mi_app` | Solo genera carpetas para móvil |
| `flutter create .` | Regenera archivos de plataforma que falten en un proyecto existente |
| `flutter clean` | Borra `build/` y `.dart_tool/` (soluciona el 50 % de errores raros) |
| `flutter clean && flutter pub get` | "Reinicio" típico del proyecto |

### Dependencias (`pub`)
| Comando | Qué hace |
|---|---|
| `flutter pub add http` | Añade una dependencia |
| `flutter pub add --dev mocktail` | Añade una dependencia de desarrollo |
| `flutter pub remove http` | Quita una dependencia |
| `flutter pub upgrade` | Actualiza paquetes dentro de los rangos permitidos |
| `flutter pub upgrade --major-versions` | Actualiza incluso a versiones mayores (puede romper código) |
| `flutter pub outdated` | Muestra qué paquetes tienen versiones nuevas |
| `flutter pub deps` | Árbol de dependencias |

### Modos de ejecución
| Comando | Qué hace |
|---|---|
| `flutter run --debug` | Por defecto: hot reload, asserts, más lento |
| `flutter run --profile` | Para medir rendimiento real (sin hot reload). Solo dispositivos físicos/emuladores |
| `flutter run --release` | Como la versión final: rápido, sin depuración |

### Calidad de código
| Comando | Qué hace |
|---|---|
| `dart fix --dry-run` | Muestra correcciones automáticas posibles |
| `dart fix --apply` | Aplica esas correcciones |
| `dart format lib test` | Formatea solo esas carpetas |
| `flutter test --coverage` | Ejecuta tests y genera `coverage/lcov.info` |
| `flutter test test/widget_test.dart` | Ejecuta un solo archivo de pruebas |
| `flutter test --name "Counter"` | Ejecuta solo tests cuyo nombre coincide |

### Entorno
| Comando | Qué hace |
|---|---|
| `flutter doctor -v` | Diagnóstico completo |
| `flutter upgrade` | Actualiza Flutter |
| `flutter --version` | Versión de Flutter, Dart y DevTools |

---

## 🥉 Nivel 3 — Importantes para compilar y publicar

| Comando | Qué produce |
|---|---|
| `flutter build apk` | APK release: `build/app/outputs/flutter-apk/app-release.apk` |
| `flutter build apk --split-per-abi` | Un APK por arquitectura (más ligeros) |
| `flutter build apk --debug` | APK debug para compartir pruebas |
| `flutter build appbundle` | **AAB para Google Play**: `build/app/outputs/bundle/release/app-release.aab` |
| `flutter build ios` | `.app` de iOS (requiere firma) |
| `flutter build ios --simulator` | `.app` para simulador (sin firma) |
| `flutter build ipa` | **IPA para App Store/TestFlight**: `build/ios/ipa/` |
| `flutter build ipa --export-method ad-hoc` | IPA para instalar en dispositivos registrados |
| `flutter install` | Instala el último build en el dispositivo conectado |

Opciones útiles para `build` (y `run`):

| Opción | Uso |
|---|---|
| `--build-name=1.2.0 --build-number=5` | Sobrescribe la versión de `pubspec.yaml` |
| `--dart-define=API_URL=https://...` | Pasa variables de entorno a Dart (`String.fromEnvironment('API_URL')`) |
| `--dart-define-from-file=config/prod.json` | Igual, desde un archivo JSON |
| `--flavor dev` | Usa un "sabor" (dev/staging/prod) configurado en Android/iOS |
| `-t lib/main_dev.dart` | Usa otro archivo de entrada |
| `--obfuscate --split-debug-info=build/symbols` | Ofusca el código Dart (release) |
| `--analyze-size` | Informe del tamaño de la app |

---

## 🧰 Nivel 4 — Menos usados, pero conviene conocerlos

### Flutter
| Comando | Para qué |
|---|---|
| `flutter logs` | Muestra los logs de la app que corre en el dispositivo |
| `flutter attach` | Se conecta a una app ya abierta (para recuperar hot reload) |
| `flutter screenshot -o captura.png` | Captura de pantalla del dispositivo |
| `flutter gen-l10n` | Genera código de traducciones desde archivos `.arb` |
| `flutter precache --ios --android` | Descarga de antemano los binarios del motor (útil con internet lento) |
| `flutter config --list` | Muestra la configuración de Flutter |
| `flutter config --jdk-dir=<ruta>` | Cambia el JDK que usa Flutter |
| `flutter config --android-sdk <ruta>` | Cambia la ruta del SDK de Android |
| `flutter config --no-analytics` | Desactiva las estadísticas de uso |
| `flutter channel stable` | Cambia de canal (`stable`, `beta`, `main`) |
| `flutter downgrade` | Vuelve a la versión anterior de Flutter |
| `flutter symbolize -i <trace> -d <symbols>` | Traduce un error ofuscado a líneas de código |
| `flutter drive` | Ejecuta pruebas de integración con `flutter_driver` (legado) |
| `flutter test integration_test` | Ejecuta pruebas de integración en un dispositivo |
| `flutter widget-preview start` | Vista previa de widgets aislados (experimental) |
| `flutter pub cache repair` | Repara la caché global de paquetes |
| `flutter pub cache clean` | Vacía la caché global de paquetes |
| `flutter bash-completion` | Autocompletado de comandos en la terminal |
| `flutter create --template=package mi_paquete` | Crea un paquete Dart reutilizable |
| `flutter create --template=plugin mi_plugin` | Crea un plugin con código nativo |

### Dart
| Comando | Para qué |
|---|---|
| `dart run` | Ejecuta `bin/` o un ejecutable de un paquete |
| `dart run build_runner build --delete-conflicting-outputs` | Generación de código (json_serializable, freezed, riverpod_generator…) |
| `dart run build_runner watch` | Igual, regenerando al guardar |
| `dart devtools` | Abre DevTools manualmente |
| `dart doc` | Genera documentación HTML del código |
| `dart compile exe bin/x.dart` | Compila un script Dart a ejecutable |

---

## 🍎 Comandos de iOS / Xcode (`xcrun simctl`)

| Comando | Para qué |
|---|---|
| `xcrun simctl list devices available` | Lista simuladores disponibles |
| `xcrun simctl boot "iPhone 18 Pro"` | Enciende un simulador |
| `xcrun simctl shutdown all` | Apaga todos los simuladores |
| `xcrun simctl erase all` | Restablece de fábrica todos los simuladores (apagados) |
| `xcrun simctl delete unavailable` | Borra simuladores de iOS antiguos (libera espacio) |
| `xcrun simctl io booted screenshot captura.png` | Captura de pantalla |
| `xcrun simctl io booted recordVideo video.mp4` | Graba vídeo (Ctrl+C para parar) |
| `xcrun simctl openurl booted https://flutter.dev` | Abre una URL / deep link |
| `xcrun simctl addmedia booted foto.jpg` | Añade fotos a la galería |
| `xcrun simctl privacy booted grant photos com.jeanrondon.miPrimeraApp` | Concede un permiso sin diálogo |
| `xcrun simctl uninstall booted <bundle-id>` | Desinstala la app |
| `open -a Simulator` | Abre la ventana del simulador |
| `open ios/Runner.xcworkspace` | Abre el proyecto iOS en Xcode |
| `xcodebuild -downloadPlatform iOS` | Descarga el runtime de simuladores iOS |
| `xcode-select -p` | Muestra qué Xcode está activo |
| `rm -rf ~/Library/Developer/Xcode/DerivedData` | Borra cachés de compilación de Xcode |

### CocoaPods (solo si existe `ios/Podfile`)
| Comando | Para qué |
|---|---|
| `cd ios && pod install` | Instala dependencias nativas |
| `cd ios && pod install --repo-update` | Igual, actualizando el índice de pods |
| `cd ios && pod deintegrate && pod install` | Reinstala los pods desde cero |

---

## 🤖 Comandos de Android (`adb`, `emulator`, `gradlew`)

> `adb` y `emulator` están en `~/Library/Android/sdk/platform-tools` y `~/Library/Android/sdk/emulator`. Para usarlos directamente, añade a `~/.zshrc`:
> ```bash
> export ANDROID_HOME="$HOME/Library/Android/sdk"
> export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
> ```

| Comando | Para qué |
|---|---|
| `adb devices` | Lista dispositivos/emuladores Android |
| `adb install build/app/outputs/flutter-apk/app-release.apk` | Instala un APK |
| `adb uninstall com.jeanrondon.mi_primera_app` | Desinstala la app |
| `adb logcat` | Logs del sistema Android completos |
| `adb logcat \| grep flutter` | Solo logs de Flutter |
| `adb shell` | Terminal dentro del dispositivo |
| `adb reverse tcp:8080 tcp:8080` | El dispositivo accede a `localhost:8080` de tu Mac |
| `adb exec-out screencap -p > captura.png` | Captura de pantalla |
| `adb kill-server && adb start-server` | Reinicia adb (si no detecta dispositivos) |
| `emulator -list-avds` | Lista emuladores |
| `emulator -avd Medium_Phone_API_37.0` | Arranca un emulador |
| `emulator -avd <nombre> -wipe-data` | Arranca restableciendo de fábrica |
| `emulator -avd <nombre> -no-snapshot-load` | Arranque en frío (si el emulador se cuelga) |
| `cd android && ./gradlew clean` | Limpia la compilación de Android |
| `cd android && ./gradlew signingReport` | Muestra SHA-1/SHA-256 (necesario para Firebase, Google Sign-In) |
| `cd android && ./gradlew --stop` | Detiene los procesos de Gradle en segundo plano |

> 💡 Dentro de la app, el emulador Android ve tu Mac en la IP **`10.0.2.2`** (no `localhost`). El simulador iOS sí usa `localhost`.

---

## 📋 Chuleta: los 15 comandos imprescindibles

```bash
flutter doctor                        # ¿Está todo bien instalado?
flutter create --org com.tunombre app # Nuevo proyecto
flutter devices                       # ¿Qué dispositivos hay?
flutter emulators --launch <id>       # Arrancar emulador Android
xcrun simctl boot "iPhone 18 Pro"     # Arrancar simulador iOS
flutter run                           # Ejecutar (r = reload, R = restart, q = salir)
flutter run -d all                    # Ejecutar en todos los dispositivos a la vez
flutter pub add <paquete>             # Añadir dependencia
flutter pub get                       # Descargar dependencias
flutter analyze                       # Revisar errores
dart format .                         # Formatear código
flutter test                          # Ejecutar pruebas
flutter clean && flutter pub get      # Arreglar problemas raros
flutter build appbundle               # Build para Google Play
flutter build ipa                     # Build para App Store
```
