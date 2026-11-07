# 01 · Entorno e instalación

> Volver al [índice](../README.md) · Siguiente: [02 · Estructura del proyecto](02-estructura-del-proyecto.md)

Este documento resume **qué necesitas en tu Mac** para crear apps Flutter para iOS y Android, y cómo comprobar que todo funciona. Está basado en la instalación real de este equipo (MacBook Pro M2 Pro, 16 GB, macOS 26).

---

## 1. Piezas del entorno y para qué sirve cada una

| Pieza | Para qué sirve | Dónde vive en tu Mac |
|---|---|---|
| **Flutter SDK** | Framework + herramienta `flutter` (crear, ejecutar, compilar) | `~/development/flutter` |
| **Dart SDK** | Lenguaje en el que se escribe Flutter. Viene **dentro** de Flutter | `~/development/flutter/bin/cache/dart-sdk` |
| **Xcode** | Compilar para iOS, simuladores de iPhone, firmar apps | `/Applications/Xcode.app` |
| **Command Line Tools** | `git`, `clang`, `make`… (Xcode las incluye) | `/Library/Developer/CommandLineTools` |
| **CocoaPods** | Gestor de dependencias nativas iOS (algunos plugins aún lo usan) | Homebrew (`pod`) |
| **Swift Package Manager** | Sustituto moderno de CocoaPods; Flutter 3.47 ya lo usa por defecto | Integrado en Xcode |
| **Android Studio** | IDE + SDK Manager + Device Manager (emuladores) | `/Applications/Android Studio.app` |
| **Android SDK** | Herramientas para compilar Android (`adb`, `emulator`, build-tools) | `~/Library/Android/sdk` |
| **JDK (Java)** | Necesario para Gradle (el sistema de build de Android). Se usa el que trae Android Studio | `/Applications/Android Studio.app/Contents/jbr` |
| **VS Code** + extensión Flutter | Editor recomendado para escribir código Dart | `/Applications/Visual Studio Code.app` |
| **Homebrew** | Instalador de paquetes para macOS | `/opt/homebrew` |

---

## 2. Orden de instalación (resumen)

1. **Homebrew** (ya lo tenías).
2. **Xcode** desde la App Store → abrirlo una vez → aceptar licencia → instalar plataforma iOS.
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   sudo xcodebuild -license accept
   xcodebuild -downloadPlatform iOS
   ```
3. **CocoaPods**
   ```bash
   brew install cocoapods
   ```
4. **Flutter SDK**
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter
   echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   flutter --version
   ```
5. **Android Studio**
   ```bash
   brew install --cask android-studio
   ```
   - Asistente inicial → *Standard*.
   - *Settings → Languages & Frameworks → Android SDK → SDK Tools* → marcar **Android SDK Command-line Tools (latest)**.
   - *Settings → Plugins* → instalar **Flutter** y **Dart**.
   - Aceptar licencias: `flutter doctor --android-licenses`
   - *Device Manager* → crear un emulador con imagen **arm64-v8a**.
6. **VS Code** + extensión **Flutter** (Dart Code).
7. **Verificar**: `flutter doctor -v` → debe decir `No issues found!`

---

## 3. Verificar que todo está bien

```bash
flutter doctor        # resumen
flutter doctor -v     # detalle (rutas, versiones)
flutter devices       # dispositivos/simuladores disponibles
flutter emulators     # emuladores Android (y simulador iOS) configurados
```

Salida esperada de `flutter doctor`:

```
[✓] Flutter (Channel stable, 3.47.x, ...)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Connected device
[✓] Network resources
• No issues found!
```

---

## 4. Consejos específicos para Apple Silicon (M1/M2/M3…)

> 📂 **En este proyecto:** la memoria de Gradle está en [android/gradle.properties](../android/gradle.properties#L1 "→ org.gradle.jvmargs") .

- **Emuladores Android**: usa siempre imágenes **ARM64 (`arm64-v8a`)**. Las `x86_64` no arrancan o van lentísimas.
- **Rosetta 2** ya está instalado; algunas herramientas antiguas lo necesitan. Si alguna vez lo pide:
  ```bash
  softwareupdate --install-rosetta --agree-to-license
  ```
- **RAM (16 GB)**: cómodo para VS Code + 1 simulador iOS + 1 emulador Android. Evita tener Xcode **y** Android Studio abiertos a la vez con varios emuladores.
- **Gradle** está configurado en [`android/gradle.properties`](../android/gradle.properties) con `-Xmx8G` (8 GB de memoria máxima). Si notas la Mac lenta compilando Android, puedes bajarlo a `-Xmx4G`.

---

## 5. Mantener el entorno actualizado

```bash
flutter upgrade          # actualiza Flutter (y Dart) en el canal actual
flutter channel          # muestra el canal (usa siempre "stable")
brew upgrade cocoapods   # actualiza CocoaPods
```

- **Xcode**: se actualiza desde la App Store. Tras actualizar, ábrelo una vez y vuelve a ejecutar `sudo xcodebuild -runFirstLaunch`.
- **Android SDK**: Android Studio → *SDK Manager* → marca las actualizaciones.

---

## 6. Cuentas necesarias (solo para publicar)

| Plataforma | Cuenta | Costo | ¿Cuándo la necesitas? |
|---|---|---|---|
| iOS | Apple ID gratis | 0 | Probar en tu iPhone (la app caduca en 7 días) |
| iOS | Apple Developer Program | 99 USD/año | Publicar en App Store / TestFlight |
| Android | Ninguna | 0 | Probar en emulador o en tu teléfono |
| Android | Google Play Console | 25 USD (pago único) | Publicar en Google Play |

Detalle completo de publicación en [08 · Compilar y publicar](08-compilar-y-publicar.md).
