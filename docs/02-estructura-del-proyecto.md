# 02 · Estructura del proyecto

> Anterior: [01 · Entorno](01-entorno-e-instalacion.md) · Volver al [índice](../README.md) · Siguiente: [03 · Comandos](03-comandos.md)

Cuando ejecutas `flutter create mi_primera_app`, Flutter genera un proyecto con **una carpeta por plataforma** y una carpeta `lib/` con tu código Dart. **El 95 % de tu tiempo lo pasarás en `lib/`, `test/`, `assets/` y `pubspec.yaml`.**

---

## 1. Mapa rápido

```
mi_primera_app/
├── lib/                    ⭐ TU CÓDIGO DART (la app en sí)
│   └── main.dart           ⭐ Punto de entrada: aquí arranca la app
├── test/                   ⭐ Pruebas automáticas (unitarias y de widgets)
│   └── widget_test.dart
├── pubspec.yaml            ⭐ Configuración: nombre, versión, dependencias, assets, fuentes
├── pubspec.lock            🔒 Versiones exactas instaladas (generado, se sube a git)
├── analysis_options.yaml   🔍 Reglas del analizador / linter
├── docs/                   📚 Esta guía
├── android/                🤖 Proyecto nativo Android (Gradle/Kotlin)
├── ios/                    🍎 Proyecto nativo iOS (Xcode/Swift)
├── web/                    🌐 Plataforma web (opcional)
├── macos/                  💻 App de escritorio macOS (opcional)
├── windows/                🪟 App de escritorio Windows (opcional)
├── linux/                  🐧 App de escritorio Linux (opcional)
├── build/                  🏗️ Salida de compilación (generado, NO se sube a git)
├── .dart_tool/             ⚙️ Caché de Dart/pub (generado, NO se sube a git)
├── .idea/ *.iml            🧩 Archivos de Android Studio/IntelliJ (ignorado por git)
├── .vscode/                🧩 Configuración de VS Code (launch.json con perfiles de ejecución)
├── .metadata               🏷️ Versión de Flutter que creó el proyecto (no editar)
├── .gitignore              🙈 Archivos que git debe ignorar
└── README.md               📖 Índice de esta guía
```

Leyenda: ⭐ editas a menudo · 🔒/⚙️/🏗️ generado automáticamente · 🤖🍎 editas a veces (permisos, nombre, iconos, firma).

---

## 2. Carpetas y archivos principales (los que tocas a diario)

### `lib/` — tu aplicación
Todo el código Dart de la app. Flutter compila **solo** lo que está aquí (y en paquetes). Guía detallada: [lib/README.md](../lib/README.md).

- `lib/main.dart` → contiene `void main()` que llama a `runApp(...)`. Es lo primero que se ejecuta.
- A medida que la app crece, se organiza en subcarpetas (pantallas, widgets, modelos, servicios…). Ver estructura recomendada en [06 · Construir la app](06-construir-la-app.md#2-cómo-organizar-lib).

### `test/` — pruebas
Archivos que terminan en `_test.dart`. Se ejecutan con `flutter test`. Guía: [test/README.md](../test/README.md).

### `pubspec.yaml` — el "package.json" de Flutter
Define:
- `name`, `description`, `version` (ej. `1.0.0+1` → versión `1.0.0`, build `1`).
- `environment.sdk` → versión de Dart compatible.
- `dependencies` → paquetes que usa la app (de [pub.dev](https://pub.dev)).
- `dev_dependencies` → paquetes solo para desarrollo (tests, lints, generadores de código).
- `flutter:` → `assets` (imágenes, JSON…), `fonts` (tipografías), `uses-material-design`.

⚠️ YAML es sensible a la **indentación** (2 espacios). Un espacio mal puesto rompe el archivo.

Después de editarlo: `flutter pub get` (VS Code lo hace solo al guardar).

### `pubspec.lock`
Versiones **exactas** que se instalaron. No se edita a mano. Para apps **sí se sube a git** (asegura que todos compilan con las mismas versiones).

### `analysis_options.yaml`
Reglas de estilo y errores que revisa `flutter analyze` y el editor. Incluye `flutter_lints` (reglas recomendadas).

---

## 3. Carpetas de plataforma (las tocas de vez en cuando)

Flutter genera un **proyecto nativo real** para cada plataforma. Ese proyecto "envuelve" tu código Dart. Las tocas para: nombre visible de la app, icono, permisos, firma, ID de la app, configuración nativa de plugins.

### `android/` — proyecto Android (Gradle + Kotlin)
Guía detallada: [android/README.md](../android/README.md).

| Ruta | Para qué |
|---|---|
| `android/app/build.gradle.kts` | **ID de la app** (`applicationId`), `minSdk`, `targetSdk`, firma de release |
| `android/app/src/main/AndroidManifest.xml` | **Nombre visible** (`android:label`), **permisos** (`<uses-permission>`), deep links |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Actividad nativa que aloja Flutter (casi nunca se toca) |
| `android/app/src/main/res/` | **Iconos** (`mipmap-*`), pantalla de carga (`drawable/launch_background.xml`), estilos |
| `android/app/src/debug/AndroidManifest.xml` | Permisos solo en modo debug (INTERNET para hot reload) |
| `android/build.gradle.kts` / `settings.gradle.kts` | Configuración global de Gradle y versiones de plugins |
| `android/gradle.properties` | Memoria de Gradle, flags de AndroidX |
| `android/local.properties` | Rutas locales al SDK de Android y Flutter (**no se sube a git**) |
| `android/gradlew` | Ejecutable de Gradle (`./gradlew clean`, etc.) |
| `android/.gradle/`, `android/app/build/` | Cachés de compilación (generados) |

### `ios/` — proyecto iOS (Xcode + Swift)
Guía detallada: [ios/README.md](../ios/README.md).

| Ruta | Para qué |
|---|---|
| `ios/Runner.xcworkspace` | **Lo que abres en Xcode** (no el `.xcodeproj`) |
| `ios/Runner.xcodeproj/project.pbxproj` | Configuración del proyecto Xcode: **Bundle ID**, equipo de firma, versión mínima de iOS |
| `ios/Runner/Info.plist` | **Nombre visible** (`CFBundleDisplayName`), **permisos** (`NS...UsageDescription`), orientaciones |
| `ios/Runner/AppDelegate.swift` | Punto de entrada nativo iOS; registra plugins |
| `ios/Runner/SceneDelegate.swift` | Gestión de escenas (ventanas) de iOS |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset` | **Iconos** de la app |
| `ios/Runner/Base.lproj/LaunchScreen.storyboard` | Pantalla de carga |
| `ios/Flutter/*.xcconfig` | Configuración Debug/Release generada por Flutter |
| `ios/Flutter/ephemeral/` | Paquetes Swift generados (no editar) |
| `ios/Podfile` *(si aparece)* | Dependencias CocoaPods; Flutter lo crea solo si algún plugin lo necesita |
| `ios/RunnerTests/` | Pruebas nativas de iOS (casi no se usan) |

### `web/`, `macos/`, `windows/`, `linux/` — plataformas extra (opcionales)
Flutter también compila para web y escritorio. **Si solo te interesa móvil**, puedes:
- Ignorarlas (no molestan), o
- Crear proyectos futuros solo con móvil:
  ```bash
  flutter create --platforms=android,ios mi_app
  ```
- Añadir una plataforma más tarde:
  ```bash
  flutter create --platforms=web .
  ```

---

## 4. Carpetas generadas (no se editan, no se suben a git)

| Carpeta | Qué contiene | ¿Se puede borrar? |
|---|---|---|
| `build/` | APKs, `.app`, IPAs, bundles web compilados | Sí (`flutter clean`) |
| `.dart_tool/` | Caché de pub y del compilador | Sí (`flutter clean`) |
| `android/.gradle/` | Caché de Gradle | Sí |
| `ios/Pods/` *(si existe)* | Dependencias CocoaPods descargadas | Sí (`pod install` las recrea) |
| `.idea/`, `*.iml` | Configuración de Android Studio | Sí |

Todas están en [`.gitignore`](../.gitignore).

---

## 5. Carpetas que **tú** creas normalmente

```
mi_primera_app/
├── assets/
│   ├── images/        # PNG, JPG, SVG…
│   ├── icons/
│   ├── fonts/         # .ttf / .otf
│   └── data/          # JSON locales
├── integration_test/  # Pruebas de integración (app completa en simulador)
└── l10n/ o lib/l10n/  # Traducciones (archivos .arb)
```

Recuerda registrar `assets/` y `fonts/` en `pubspec.yaml` → ver [06 · Construir la app](06-construir-la-app.md#7-assets-imágenes-y-fuentes).

---

## 6. ¿Qué subo a git y qué no?

✅ **Sí**: `lib/`, `test/`, `assets/`, `android/` e `ios/` (menos sus cachés), `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.metadata`, `docs/`, `.vscode/launch.json`.

❌ **No** (ya lo ignora `.gitignore`): `build/`, `.dart_tool/`, `android/local.properties`, `android/key.properties`, `*.jks`/`*.keystore`, `ios/Pods/`, `.idea/`.

⚠️ **Nunca** subas claves de firma (`.jks`, `key.properties`) ni archivos con secretos (`.env` con API keys).
