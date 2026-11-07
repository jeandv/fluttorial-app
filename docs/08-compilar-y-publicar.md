# 08 · Compilar y publicar (App Store y Google Play)

> Anterior: [07 · Pruebas y calidad](07-pruebas-y-calidad.md) · Volver al [índice](../README.md) · Siguiente: [09 · Solución de problemas](09-solucion-de-problemas.md)

---

## 1. Checklist antes de publicar

- [ ] **Nombre visible** de la app definido (Android e iOS).
- [ ] **ID único** de la app (Android `applicationId`, iOS Bundle ID). **No se puede cambiar** tras publicar.
- [ ] **Icono** propio (no el de Flutter).
- [ ] **Pantalla de carga** (splash).
- [ ] **Versión** correcta en `pubspec.yaml`.
- [ ] **Permisos** declarados (y textos explicativos en iOS).
- [ ] Permiso **INTERNET** en el `AndroidManifest.xml` principal si la app usa red.
- [ ] Firma de **release** configurada en Android.
- [ ] Probada en modo `--release` en un **dispositivo real**.
- [ ] `flutter analyze` y `flutter test` sin errores.
- [ ] Política de privacidad publicada en una URL (ambas tiendas la piden).
- [ ] Capturas de pantalla para las tiendas.

---

## 2. Identidad de la app

### Nombre visible (el que aparece bajo el icono)

> 📂 **En este proyecto:** [android:label](../android/app/src/main/AndroidManifest.xml#L34 "→ android:label=") · [CFBundleDisplayName](../ios/Runner/Info.plist#L9 "→ CFBundleDisplayName") .
| Plataforma | Archivo | Campo |
|---|---|---|
| Android | [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml) | `android:label="Mi Primera App"` |
| iOS | [`ios/Runner/Info.plist`](../ios/Runner/Info.plist) | `CFBundleDisplayName` |

### ID de la app
| Plataforma | Valor actual | Dónde |
|---|---|---|
| Android | `com.jeanrondon.mi_primera_app` | `applicationId` y `namespace` en [`android/app/build.gradle.kts`](../android/app/build.gradle.kts) (+ carpeta `kotlin/com/jeanrondon/mi_primera_app/` y `package` de `MainActivity.kt`) |
| iOS | `com.jeanrondon.miPrimeraApp` | Xcode → *Runner → Signing & Capabilities → Bundle Identifier* (se guarda en `project.pbxproj`) |

> Para renombrar el ID en todos los sitios a la vez existe el paquete `change_app_package_name` (dev). Hazlo **antes** de publicar.

### Versión → [`pubspec.yaml`](../pubspec.yaml)

> 📂 **En este proyecto:** [version: 1.0.0+1](../pubspec.yaml#L32 "→ version: 1.0.0+1") → usado en [versionCode/versionName](../android/app/build.gradle.kts#L56 "→ versionCode = flutter.versionCode") .
```yaml
version: 1.2.0+7
#        │ │ │ └─ build number: entero que SIEMPRE debe subir en cada subida a la tienda
#        └─┴─┴─── versión visible para el usuario (major.minor.patch)
```
| | Android | iOS |
|---|---|---|
| `1.2.0` | `versionName` | `CFBundleShortVersionString` |
| `7` | `versionCode` | `CFBundleVersion` |

También por comando: `flutter build appbundle --build-name=1.2.0 --build-number=7`.

### Icono
```bash
flutter pub add --dev flutter_launcher_icons
```
En `pubspec.yaml` (al final, sin indentar):
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"      # PNG 1024x1024 sin transparencia (iOS)
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"
```
```bash
dart run flutter_launcher_icons
```

### Pantalla de carga (splash)
```bash
flutter pub add --dev flutter_native_splash
```
```yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/icon/splash.png
```
```bash
dart run flutter_native_splash:create
```

---

## 3. 🤖 Android → Google Play

### 3.1 Crear la clave de firma (una sola vez por app)
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
> 🔐 **Guarda el `.jks` y sus contraseñas en un lugar seguro** (gestor de contraseñas + copia de seguridad). Si lo pierdes, no podrás actualizar la app (Google Play App Signing permite recuperarlo, pero es un trámite). **Nunca lo subas a git.**

### 3.2 Crear `android/key.properties` (ignorado por git)
```properties
storePassword=<tu-contraseña>
keyPassword=<tu-contraseña>
keyAlias=upload
storeFile=/Users/jeanrondon/upload-keystore.jks
```

### 3.3 Configurar `android/app/build.gradle.kts`

> 📂 **En este proyecto:** ⚠️ pendiente: ahora se firma con la clave de debug → [ver línea a cambiar](../android/app/build.gradle.kts#L66 "→ signingConfig = signingConfigs.getByName(") .

Arriba del archivo:
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```
Dentro de `android { ... }`:
```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release") // antes: "debug"
    }
}
```

### 3.4 Permiso de internet en release

> 📂 **En este proyecto:** ✅ ya está añadido: [ver línea](../android/app/src/main/AndroidManifest.xml#L31 "→ android.permission.INTERNET") .

En [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml), antes de `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 3.5 Compilar
```bash
flutter build appbundle          # → build/app/outputs/bundle/release/app-release.aab  (para Google Play)
flutter build apk --release      # → build/app/outputs/flutter-apk/app-release.apk  (para instalar a mano)
```

### 3.6 Subir a Google Play
1. Crea la cuenta en [play.google.com/console](https://play.google.com/console) (25 USD).
2. **Crear app** → nombre, idioma, gratis/de pago.
3. Completa la ficha: descripción, icono 512×512, gráfico de funciones 1024×500, capturas, clasificación de contenido, política de privacidad, público objetivo, seguridad de los datos.
4. **Pruebas → Prueba interna** → crea una versión → sube el `.aab` → añade testers por email.
5. Las cuentas personales nuevas deben hacer una **prueba cerrada** (con un número mínimo de testers durante un periodo, consulta los requisitos actuales en la consola) antes de poder publicar en producción.
6. **Producción** → crear versión → enviar a revisión (de horas a varios días).

---

## 4. 🍎 iOS → App Store

### 4.1 Requisitos
- Cuenta **Apple Developer Program** (99 USD/año) en [developer.apple.com](https://developer.apple.com).
- Xcode con tu cuenta añadida: *Xcode → Settings → Accounts → +*.

### 4.2 Configurar firma en Xcode
```bash
open ios/Runner.xcworkspace
```
1. Selecciona **Runner** (icono azul) → target **Runner** → pestaña **Signing & Capabilities**.
2. Marca **Automatically manage signing**.
3. **Team**: tu equipo de desarrollador.
4. **Bundle Identifier**: único (ej. `com.jeanrondon.miPrimeraApp`).
5. Pestaña **General** → *Minimum Deployments* (versión mínima de iOS).

### 4.3 Registrar la app en App Store Connect
1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps → + → Nueva app**.
2. Plataforma iOS, nombre, idioma, **Bundle ID** (el mismo de Xcode), SKU (cualquier identificador interno).

### 4.4 Compilar el IPA
```bash
flutter build ipa
```
Produce:
- `build/ios/archive/Runner.xcarchive` → archivo de Xcode.
- `build/ios/ipa/*.ipa` → paquete para subir.

### 4.5 Subir
Opción A — **Transporter** (app gratuita de la Mac App Store): arrastra el `.ipa` → *Deliver*.

Opción B — **Xcode**: `open build/ios/archive/Runner.xcarchive` → *Distribute App → App Store Connect → Upload*.

### 4.6 TestFlight y publicación
1. En App Store Connect → tu app → **TestFlight**: tras procesarse (~15-30 min), añade testers internos (inmediato) o externos (requiere una revisión breve).
2. Los testers instalan la app **TestFlight** en su iPhone y aceptan la invitación.
3. Para publicar: pestaña **App Store** → rellena descripción, palabras clave, capturas (6,9" y 6,5" como mínimo), icono, privacidad, clasificación por edad → selecciona el build → **Enviar a revisión** (normalmente 24-48 h).

---

## 5. Builds para compartir pruebas sin tienda

| Plataforma | Cómo |
|---|---|
| Android | `flutter build apk` → envía el `.apk` (el receptor debe permitir "instalar apps desconocidas") |
| Android | Google Play → Prueba interna (enlace de invitación) |
| iOS | TestFlight (la forma oficial) |
| iOS | `flutter build ipa --export-method ad-hoc` → solo para dispositivos registrados por UDID |
| Ambas | Firebase App Distribution |

---

## 6. Entornos (dev / prod)

Opción sencilla con `--dart-define-from-file`:
```
config/
├── dev.json     { "API_URL": "https://dev.api.com" }
└── prod.json    { "API_URL": "https://api.com" }
```
```bash
flutter run --dart-define-from-file=config/dev.json
flutter build appbundle --dart-define-from-file=config/prod.json
```
```dart
const apiUrl = String.fromEnvironment('API_URL');
```

Opción avanzada: **flavors** (apps distintas instalables a la vez, p. ej. "MiApp Dev" y "MiApp"). Requiere configurar `productFlavors` en Gradle y *schemes* en Xcode. Guía: [docs.flutter.dev/deployment/flavors](https://docs.flutter.dev/deployment/flavors).

---

## 7. Ofuscación y símbolos (opcional, recomendado en release)

```bash
flutter build appbundle --obfuscate --split-debug-info=build/symbols
flutter build ipa       --obfuscate --split-debug-info=build/symbols
```
Guarda `build/symbols` de cada versión: lo necesitas para leer errores (`flutter symbolize`).

---

## 8. Automatizar (CI/CD) — cuando publiques a menudo

- **Codemagic** (especializado en Flutter), **GitHub Actions**, **Bitrise**.
- **fastlane** para automatizar subidas a ambas tiendas.

📚 Guías oficiales: [Android](https://docs.flutter.dev/deployment/android) · [iOS](https://docs.flutter.dev/deployment/ios)
