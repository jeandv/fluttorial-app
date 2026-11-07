# 🍎 `ios/` — Proyecto nativo iOS

> Volver al [índice](../README.md) · Ver también: [02 · Estructura](../docs/02-estructura-del-proyecto.md#ios--proyecto-ios-xcode--swift) · [08 · Publicar en App Store](../docs/08-compilar-y-publicar.md#4--ios--app-store)

Es un **proyecto Xcode real** (Swift) que Flutter generó para "envolver" tu código Dart. Solo se puede compilar en una Mac con Xcode.

## ⚠️ Abrir en Xcode: siempre el `.xcworkspace`

```bash
open ios/Runner.xcworkspace
```
No abras `Runner.xcodeproj`: el workspace incluye las dependencias (Swift Package Manager / CocoaPods).

## Archivos que sí tocarás

| Archivo | Para qué | Cuándo |
|---|---|---|
| [`Runner/Info.plist`](Runner/Info.plist) | Nombre visible (`CFBundleDisplayName`), **permisos** (`NS...UsageDescription`), orientaciones, URL schemes | Al añadir plugins con permisos |
| Xcode → *Signing & Capabilities* | **Team** (firma), **Bundle Identifier**, capacidades (Push, Sign in with Apple…) | Para probar en iPhone real y publicar |
| Xcode → *General* | Versión mínima de iOS (*Minimum Deployments*) | Si un plugin lo pide |
| `Runner/Assets.xcassets/AppIcon.appiconset/` | Iconos de la app | Usa `flutter_launcher_icons` |
| `Runner/Base.lproj/LaunchScreen.storyboard` | Pantalla de carga | Usa `flutter_native_splash` |

> Los cambios de *Signing*, *Bundle ID* y *Minimum Deployments* se guardan en `Runner.xcodeproj/project.pbxproj`. Hazlos desde Xcode, no editando ese archivo a mano.

## Archivos que casi nunca tocarás

| Archivo | Qué es |
|---|---|
| [`Runner/AppDelegate.swift`](Runner/AppDelegate.swift) | Punto de entrada nativo; registra plugins |
| [`Runner/SceneDelegate.swift`](Runner/SceneDelegate.swift) | Gestión de la ventana |
| `Runner/Base.lproj/Main.storyboard` | Contenedor de la vista de Flutter |
| `Runner/GeneratedPluginRegistrant.*` | Generado por Flutter; no editar |
| `Runner/Runner-Bridging-Header.h` | Puente Swift ↔ Objective-C |
| `Flutter/Debug.xcconfig`, `Release.xcconfig` | Configuración de build (incluye `Generated.xcconfig`) |
| `Flutter/Generated.xcconfig`, `Flutter/ephemeral/` | Generados por Flutter en cada build |
| `RunnerTests/` | Pruebas nativas de iOS |
| `Podfile`, `Pods/` *(si aparecen)* | CocoaPods: Flutter los crea solo si algún plugin aún no soporta Swift Package Manager |

## IDs de esta app

- **Bundle Identifier**: `com.jeanrondon.miPrimeraApp` (iOS no admite `_`, por eso difiere del de Android)
- **Nombre visible**: `Mi Primera App`
- **iOS mínimo**: 15.0

## Permisos más comunes (en `Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Usamos la cámara para tu foto de perfil.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Accedemos a tus fotos para elegir una imagen.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Usamos tu ubicación para mostrar lugares cercanos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Usamos el micrófono para grabar audio.</string>
<key>NSFaceIDUsageDescription</key>
<string>Usamos Face ID para iniciar sesión de forma segura.</string>
```
Si falta el texto de un permiso, **la app se cierra** al pedirlo y **Apple la rechaza** en la revisión.

## Comandos útiles (desde la raíz del proyecto)

```bash
xcrun simctl boot "iPhone 18 Pro"                 # encender simulador
flutter run -d "iPhone 18 Pro"                     # ejecutar
flutter build ios --simulator                      # .app para simulador
flutter build ipa                                  # IPA para App Store / TestFlight
open ios/Runner.xcworkspace                        # abrir en Xcode
rm -rf ~/Library/Developer/Xcode/DerivedData       # limpiar cachés de Xcode
cd ios && pod install --repo-update && cd ..       # solo si existe ios/Podfile
```
