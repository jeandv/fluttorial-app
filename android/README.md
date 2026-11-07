# 🤖 `android/` — Proyecto nativo Android

> Volver al [índice](../README.md) · Ver también: [02 · Estructura](../docs/02-estructura-del-proyecto.md#android--proyecto-android-gradle--kotlin) · [08 · Publicar en Google Play](../docs/08-compilar-y-publicar.md#3--android--google-play)

Es un **proyecto Android real** (Gradle + Kotlin) que Flutter generó para "envolver" tu código Dart. Puedes abrirlo en Android Studio (*File → Open → carpeta `android/`*) para tareas nativas, aunque normalmente trabajarás desde la raíz del proyecto.

## Archivos que sí tocarás

| Archivo | Para qué | Cuándo |
|---|---|---|
| [`app/build.gradle.kts`](app/build.gradle.kts) | `applicationId`, `minSdk`, firma de release | Antes de publicar / si un plugin pide un `minSdk` mayor |
| [`app/src/main/AndroidManifest.xml`](app/src/main/AndroidManifest.xml) | Nombre visible (`android:label`), permisos, deep links | Al añadir plugins con permisos |
| `app/src/main/res/mipmap-*/ic_launcher.png` | Icono de la app | Usa `flutter_launcher_icons` |
| `app/src/main/res/drawable*/launch_background.xml` | Pantalla de carga | Usa `flutter_native_splash` |
| `app/src/main/res/values*/styles.xml` | Temas de arranque (claro / oscuro) | Rara vez |
| [`gradle.properties`](gradle.properties) | Memoria de Gradle (`-Xmx8G`) | Si la Mac va lenta al compilar |
| `key.properties` *(lo creas tú)* | Contraseñas de la clave de firma | Al publicar (¡no subir a git!) |

## Archivos que casi nunca tocarás

| Archivo | Qué es |
|---|---|
| [`app/src/main/kotlin/.../MainActivity.kt`](app/src/main/kotlin/com/jeanrondon/mi_primera_app/MainActivity.kt) | Activity nativa que aloja Flutter. **En este proyecto registra un `MethodChannel`** en [configureFlutterEngine](../android/app/src/main/kotlin/com/jeanrondon/mi_primera_app/MainActivity.kt#L30 "→ override fun configureFlutterEngine") (demo *Código nativo*) |
| `app/src/debug/AndroidManifest.xml` | Añade el permiso INTERNET solo en debug (para hot reload) |
| `app/src/profile/AndroidManifest.xml` | Lo mismo para el modo profile |
| `build.gradle.kts` | Configuración común a todos los módulos |
| `settings.gradle.kts` | Versiones del plugin de Android (AGP) y Kotlin; carga el plugin de Flutter |
| `gradle/wrapper/gradle-wrapper.properties` | Versión de Gradle |
| `local.properties` | Rutas a tu Android SDK y Flutter SDK (generado; no se sube a git) |
| `app/src/main/java/.../GeneratedPluginRegistrant.java` | Generado por Flutter; no editar |
| `.gradle/`, `app/build/` | Cachés (se pueden borrar) |

## IDs de esta app

- **applicationId / namespace**: `com.jeanrondon.mi_primera_app`
- **Nombre visible**: `Mi Primera App`

## Comandos útiles (desde la raíz del proyecto)

```bash
flutter run -d emulator-5554                 # ejecutar en el emulador
flutter build apk                            # APK release
flutter build appbundle                      # AAB para Google Play
cd android && ./gradlew clean && cd ..       # limpiar build nativo
cd android && ./gradlew signingReport        # huellas SHA-1/SHA-256 (Firebase, Google Sign-In)
cd android && ./gradlew --stop               # parar procesos de Gradle
```

## Recuerda

- 🔐 Nunca subas a git `key.properties`, `*.jks` ni `*.keystore` (ya están en `.gitignore`).
- 🌐 Si la app usa internet, hace falta `<uses-permission android:name="android.permission.INTERNET"/>` en el manifest **main** (en debug funciona sin él, en release no). En este proyecto [ya está añadido](../android/app/src/main/AndroidManifest.xml#L31 "→ android.permission.INTERNET") .
- ✍️ Antes de publicar, cambia la [firma de debug](../android/app/build.gradle.kts#L66 "→ signingConfig = signingConfigs.getByName(") por la tuya ([docs/08 §3](../docs/08-compilar-y-publicar.md#3--android--google-play)).
- 📱 El emulador ve tu Mac en `10.0.2.2`, no en `localhost`.
