# 09 · Solución de problemas

> Anterior: [08 · Compilar y publicar](08-compilar-y-publicar.md) · Volver al [índice](../README.md) · Siguiente: [10 · Funcionalidades de la app](10-funcionalidades-de-la-app.md)

> 📖 **Documento de consulta:** no se lee de corrido; ábrelo cuando lo necesites.
> 🎯 **Te sirve para:** buscar la causa y la solución de un error de instalación, iOS, Android, ejecución o dependencias, o para liberar espacio en disco.
> 🧭 **Ruta de aprendizaje:** [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md)

**Primero, siempre:**
```bash
flutter doctor -v
flutter clean && flutter pub get
```
Y lee el error **desde abajo hacia arriba**: la causa real suele estar en las últimas líneas o en la primera línea que dice `Error:`.

---

## 1. Problemas que ya aparecieron en esta Mac

| Error | Causa | Solución |
|---|---|---|
| `xcode-select: error: invalid developer directory '/Applications/Xcode.app/Contents/Developer'` | Xcode no estaba instalado (solo las Command Line Tools) | Instalar Xcode desde la App Store, abrirlo una vez y repetir `sudo xcode-select --switch ...` |
| `Android sdkmanager not found` al ejecutar `flutter doctor --android-licenses` | Faltaban las **Android SDK Command-line Tools** | Android Studio → SDK Manager → SDK Tools → marcar *Android SDK Command-line Tools (latest)* |
| `Waiting for another flutter command to release the startup lock...` | Otro proceso `flutter` (otra terminal, VS Code) está usando la caché | Esperar. Si no avanza: cerrar otras terminales/VS Code. Último recurso: `rm ~/development/flutter/bin/cache/lockfile` |
| Descarga del motor iOS a 0,1 MB/s | Conexión a internet lenta | Esperar sin cerrar la terminal, o `flutter precache --ios --android` en un momento con mejor conexión |
| `Unable to find application named 'Simulator'` | No se encontró `Simulator.app` | Xcode → menú *Xcode → Open Developer Tool → Simulator*. Flutter puede usar el simulador igualmente si está encendido (`xcrun simctl boot ...`) |
| `flutter: command not found` | Flutter no está en el PATH | `echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc` |

---

## 2. Instalación / `flutter doctor`

| Síntoma | Solución |
|---|---|
| `Android license status unknown` | `flutter doctor --android-licenses` y responder `y` |
| `Unable to locate Android SDK` | Abrir Android Studio y completar el asistente, o `flutter config --android-sdk ~/Library/Android/sdk` |
| `CocoaPods not installed` | `brew install cocoapods` |
| `Xcode installation is incomplete` | `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer && sudo xcodebuild -runFirstLaunch` |
| `Unable to find bundled Java version` / error de JDK | `flutter config --jdk-dir="/Applications/Android Studio.app/Contents/jbr/Contents/Home"` |
| No aparece ningún simulador iOS | `xcodebuild -downloadPlatform iOS` |

---

## 3. iOS

| Síntoma | Solución |
|---|---|
| Error genérico de compilación de Xcode | `flutter clean`, `rm -rf ~/Library/Developer/Xcode/DerivedData`, volver a ejecutar |
| `No valid code signing certificates were found` | Abrir `ios/Runner.xcworkspace` → *Signing & Capabilities* → elegir **Team** |
| `Failed to register bundle identifier` | El Bundle ID ya existe en otra cuenta → cámbialo por uno único |
| Errores de CocoaPods (`pod install` falla) | `cd ios && pod deintegrate && pod install --repo-update && cd ..` |
| `Untrusted Developer` en el iPhone | iPhone → Ajustes → General → VPN y gestión de dispositivos → Confiar |
| El iPhone no aparece en `flutter devices` | Desbloquearlo, "Confiar en este ordenador", activar **Modo desarrollador** |
| La app crashea al usar cámara/fotos/ubicación | Falta el texto `NS...UsageDescription` en `Info.plist` |
| El simulador va lento o se cuelga | *Device → Erase All Content and Settings* o `xcrun simctl shutdown all` |

---

## 4. Android

| Síntoma | Solución |
|---|---|
| Error de Gradle genérico | `flutter clean`, `cd android && ./gradlew clean && cd ..`, volver a ejecutar |
| Gradle se queda colgado / consume mucha RAM | `cd android && ./gradlew --stop`; bajar `-Xmx8G` a `-Xmx4G` en `android/gradle.properties` |
| `minSdkVersion ... cannot be smaller than ...` (por un plugin) | En `android/app/build.gradle.kts`: `minSdk = 23` (o el que pida el plugin) |
| `Execution failed for task ':app:checkDebugAarMetadata'` | Subir `compileSdk` o actualizar Flutter/plugins |
| El emulador no arranca o va muy lento | Usar imagen **arm64-v8a**; Device Manager → *Cold Boot Now*; o `emulator -avd <nombre> -no-snapshot-load` |
| `adb: device offline` / no se detecta | `adb kill-server && adb start-server` |
| La app en release no carga datos de internet | Falta el permiso INTERNET en el manifest **main** → [06 §9](06-construir-la-app.md#9-permisos-nativos) |
| No conecta a `localhost` desde el emulador | Usar `http://10.0.2.2:<puerto>` o `adb reverse tcp:<puerto> tcp:<puerto>` |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Firma distinta a la instalada → `adb uninstall com.jeanrondon.mi_primera_app` |

---

## 5. Dart / Flutter en tiempo de ejecución

> 📂 **En este proyecto:** soluciones aplicadas en el código (las demos se explican en [10 · Funcionalidades de la app](10-funcionalidades-de-la-app.md) → lo verás allí):
> - [comprobar `mounted` tras un await](../lib/features/basics/widgets_screen.dart#L77 "→ if (!mounted) return;")
> - [no usar context tras un await](../lib/features/intermediate/async_screen.dart#L69 "→ no usamos `context` después")
> - [Expanded contra el overflow](../lib/features/basics/layout_screen.dart#L91 "→ Expanded(child: box('1'")
> - [GridView dentro de ListView](../lib/features/advanced/responsive_screen.dart#L101 "→ shrinkWrap: true")
> - [capturar MissingPluginException](../lib/features/advanced/native_channel.dart#L80 "→ on MissingPluginException")

| Error en pantalla/terminal | Significado | Solución |
|---|---|---|
| Franja amarilla y negra **`RenderFlex overflowed by X pixels`** | El contenido no cabe en `Row`/`Column` | Envolver en `Expanded`/`Flexible`, usar `SingleChildScrollView`, o reducir tamaños |
| Pantalla roja **`Cannot interpolate between finite constraints and unbounded constraints`** | Una animación va hacia un tamaño infinito (`width: double.infinity` en `AnimatedContainer`) | Animar hacia un número real: medirlo con `LayoutBuilder` (`constraints.maxWidth`) → [ejemplo corregido](../lib/features/advanced/animations_screen.dart#L111 "→ width: _expanded ? constraints.maxWidth") (→ lo verás en [10](10-funcionalidades-de-la-app.md)) |
| `Vertical viewport was given unbounded height` | `ListView` dentro de `Column` sin altura | Envolver el `ListView` en `Expanded`, o `shrinkWrap: true` |
| `Null check operator used on a null value` | Se usó `!` sobre algo `null` | Revisar la variable; usar `?.` / `??` |
| `setState() called after dispose()` | `setState` tras salir de la pantalla (p. ej. al terminar un `Future`) | `if (!mounted) return;` antes de `setState` |
| `Looking up a deactivated widget's ancestor is unsafe` / `Don't use BuildContext across async gaps` | Usar `context` después de un `await` | Comprobar `if (!context.mounted) return;` tras el `await` |
| `A RenderFlex/Box was not laid out` | Problema de restricciones de tamaño | Ver [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints) |
| `Unable to load asset` | Asset no registrado en `pubspec.yaml` o ruta incorrecta | Revisar `flutter: assets:`, `flutter pub get` y hot restart |
| `MissingPluginException` | Plugin nativo añadido con la app ya corriendo | Detener (`q`) y ejecutar de nuevo `flutter run` |
| Hot reload no muestra el cambio | Es un cambio que hot reload no aplica | `R` (hot restart) o reiniciar `flutter run`; lista de casos en [04 §1](04-ejecutar-y-simular.md#1-flujo-completo-paso-a-paso-terminal) |

---

## 6. Dependencias

| Síntoma | Solución |
|---|---|
| `version solving failed` | Dos paquetes piden versiones incompatibles. `flutter pub outdated`; ajustar versiones; `flutter pub upgrade --major-versions` |
| `Because mi_primera_app depends on X which requires SDK version >=...` | Flutter desactualizado → `flutter upgrade` |
| Caché de paquetes corrupta | `flutter pub cache repair` |

---

## 7. Liberar espacio en disco

| Qué | Comando | Espacio típico |
|---|---|---|
| Cachés de Xcode | `rm -rf ~/Library/Developer/Xcode/DerivedData` | 5–30 GB |
| Simuladores iOS antiguos | `xcrun simctl delete unavailable` | 5–20 GB |
| Runtimes de iOS que no uses | Xcode → Settings → Components | 7 GB c/u |
| Build de un proyecto | `flutter clean` | 0,5–2 GB |
| Caché de Gradle | `rm -rf ~/.gradle/caches` | 2–10 GB |
| Emuladores Android que no uses | Android Studio → Device Manager → 🗑 | 5–10 GB c/u |

---

## 8. Dónde pedir ayuda

- El mensaje de error **copiado literal** en Google / [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter).
- [GitHub Issues de Flutter](https://github.com/flutter/flutter/issues).
- [Discord de Flutter](https://discord.gg/flutter) · [r/FlutterDev](https://reddit.com/r/FlutterDev).
- Al preguntar, incluye siempre la salida de `flutter doctor -v`.

---

## ➡️ Siguiente paso

Vuelve a la [ruta de aprendizaje](00-ruta-de-aprendizaje.md).
