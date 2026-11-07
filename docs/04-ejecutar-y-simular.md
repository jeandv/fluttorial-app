# 04 · Ejecutar y simular la app

> Anterior: [03 · Comandos](03-comandos.md) · Volver al [índice](../README.md) · Siguiente: [05 · Dart esencial](05-dart-esencial.md)

Este es el flujo que repetirás cada vez que trabajes en una app: **encender un dispositivo → `flutter run` → editar → hot reload**.

---

## 1. Flujo completo paso a paso (terminal)

### Paso 1 — Entrar al proyecto
```bash
cd ~/Documents/dev/tutorial-mobile-dev/mi_primera_app
```

### Paso 2 — Encender los dispositivos

**Simulador iOS (iPhone):**
```bash
xcrun simctl list devices available | grep iPhone   # ver modelos
xcrun simctl boot "iPhone 18 Pro"                   # encender
open -a Simulator                                   # ver la ventana
```
> Si `open -a Simulator` dice *"Unable to find application named 'Simulator'"*: abre **Xcode → menú Xcode → Open Developer Tool → Simulator**. El simulador funciona aunque no veas la ventana (Flutter lo detecta igual).

**Emulador Android:**
```bash
flutter emulators                                   # ver emuladores
flutter emulators --launch Medium_Phone_API_37.0    # encender
```
> O desde **Android Studio → Device Manager → ▶**.

### Paso 3 — Comprobar que Flutter los ve
```bash
flutter devices
```
Ejemplo de salida (ilustrativo; el formato exacto varía según la versión):
```
iPhone 18 Pro (mobile)     • 9BC87A19-417D-4972-99A7-F680A71FD804 • ios            • iOS 27.2 (simulator)
sdk gphone64 arm64 (mobile)• emulator-5554                        • android-arm64  • Android (API 37) (emulator)
macOS (desktop)            • macos                                • darwin-arm64   • macOS 26.7
Chrome (web)               • chrome                               • web-javascript • Google Chrome
```
La **segunda columna es el ID** que usas con `-d`.

### Paso 4 — Ejecutar
```bash
flutter run                                         # si hay un solo dispositivo móvil, lo usa; si no, pregunta
flutter run -d emulator-5554                        # Android
flutter run -d 9BC87A19-417D-4972-99A7-F680A71FD804 # iPhone (por UDID)
flutter run -d "iPhone 18 Pro"                      # iPhone (por nombre)
flutter run -d all                                  # todos a la vez
```

`flutter run` hace todo esto automáticamente:
1. `pub get` (descarga dependencias si hace falta).
2. Compila el código Dart en modo **debug**.
3. Compila el proyecto nativo (**Gradle** en Android, **Xcode** en iOS).
4. Instala la app en el dispositivo y la abre.
5. Se queda escuchando para **hot reload**.

### Paso 5 — Desarrollar con hot reload
1. Abre [`lib/main.dart`](../lib/main.dart).
2. Cambia un texto o un color.
3. Guarda y pulsa **`r`** en la terminal → el cambio aparece en ~1 segundo.
4. Si algo no se actualiza, pulsa **`R`** (hot restart).
5. Para terminar: **`q`**.

---

## 2. ⏳ La primera ejecución es lenta (normal)

| Plataforma | Qué descarga/compila la primera vez | Tiempo aprox. |
|---|---|---|
| iOS | Binarios del motor iOS (~90 MB), compila con Xcode | 2–10 min (depende de internet) |
| Android | Gradle (~150 MB), dependencias de Android, compila | 3–10 min |
| Siguientes veces | Solo lo que cambió | 10–40 s |

- Si ves **"Waiting for another flutter command to release the startup lock..."** → otra ventana de `flutter` está descargando. **Espera**, no es un error.
- **No cierres la terminal** durante la primera compilación.
- Con internet lento, descarga antes los binarios:
  ```bash
  flutter precache --ios --android
  ```

---

## 3. Ejecutar desde VS Code (recomendado para el día a día)

1. Abre la carpeta del proyecto en VS Code (`code .` o *File → Open Folder*).
2. En la **barra de estado inferior derecha** aparece el dispositivo seleccionado → haz clic para elegir iPhone o Android.
   - También: `Cmd+Shift+P` → **Flutter: Select Device** / **Flutter: Launch Emulator**.
3. Pulsa **F5** (o *Run → Start Debugging*).
4. **Al guardar (`Cmd+S`) se hace hot reload automáticamente.**
5. Barra flotante de depuración: ⚡ hot reload · 🔄 hot restart · ⏹ detener · 🔍 abrir DevTools.

Este proyecto incluye [`.vscode/launch.json`](../.vscode/launch.json) con perfiles listos: *Debug*, *Profile*, *Release*, *iPhone 18 Pro (simulador)*, *Android (emulador)* y el compuesto **iPhone + Android** (lanza en los dos a la vez). Elígelos en la pestaña **Run and Debug** (`Cmd+Shift+D`).

**Breakpoints**: haz clic a la izquierda del número de línea → punto rojo → la app se pausará ahí y podrás inspeccionar variables.

---

## 4. Ejecutar desde Android Studio

1. *File → Open* → selecciona la carpeta `mi_primera_app`.
2. Arriba: selector de dispositivo → elige emulador o iPhone.
3. Botón ▶ (*Run*) o 🐞 (*Debug*).
4. ⚡ Hot reload: `Cmd+\` · Hot restart: `Cmd+Shift+\`.

---

## 5. Modos de compilación

| Modo | Comando | Hot reload | Velocidad | Úsalo para |
|---|---|---|---|---|
| **Debug** | `flutter run` | ✅ | Lenta (más en Android) | Desarrollar |
| **Profile** | `flutter run --profile` | ❌ | Casi real | Medir rendimiento con DevTools |
| **Release** | `flutter run --release` | ❌ | Máxima | Probar la versión final |

> ⚠️ En modo debug la app va más lenta y con un banner "DEBUG". **No juzgues el rendimiento en debug.** Los simuladores iOS no soportan `--profile` ni `--release`; para eso usa un iPhone real.

---

## 6. Probar en tu teléfono real

### iPhone
1. Conéctalo por cable USB-C y desbloquéalo → **Confiar en este ordenador**.
2. En el iPhone: **Ajustes → Privacidad y seguridad → Modo desarrollador → Activar** (reinicia).
3. Abre el proyecto iOS en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. *Runner → Signing & Capabilities* → **Team**: añade tu Apple ID (*Add an Account…*).
5. Si el Bundle Identifier da error, cámbialo por uno único (ej. `com.jeanrondon.miPrimeraApp2`).
6. Ejecuta:
   ```bash
   flutter devices          # aparece tu iPhone
   flutter run -d <id-del-iphone>
   ```
7. La primera vez, en el iPhone: **Ajustes → General → VPN y gestión de dispositivos → confía en tu certificado**.

> Con Apple ID gratuito la app **caduca a los 7 días** y puedes tener máximo 3 apps instaladas. Con la cuenta de pago (99 USD/año) dura 1 año.

**Inalámbrico**: con el iPhone conectado, en Xcode → *Window → Devices and Simulators* → marca **Connect via network**.

### Android
1. **Ajustes → Acerca del teléfono** → toca 7 veces **Número de compilación** (activa opciones de desarrollador).
2. **Ajustes → Sistema → Opciones de desarrollador** → activa **Depuración USB**.
3. Conecta por USB → acepta **"¿Permitir depuración USB?"**.
4. `flutter devices` → `flutter run -d <id>`.

**Inalámbrico (Android 11+)**: Opciones de desarrollador → **Depuración inalámbrica** → *Vincular con código* → en Android Studio *Device Manager → Pair Devices Using Wi-Fi*.

---

## 7. Herramientas de depuración

| Herramienta | Cómo abrirla | Para qué |
|---|---|---|
| **`print()` / `debugPrint()`** | En el código | Mensajes en la terminal |
| **`flutter logs`** | Terminal | Ver logs de una app ya abierta |
| **DevTools** | Tecla `v` en `flutter run`, o botón 🔍 en VS Code | Inspector de widgets, rendimiento, memoria, red, logs |
| **Widget Inspector** | DevTools → *Flutter Inspector* | Seleccionar un widget en pantalla y ver su código |
| **Debug paint** | Tecla `p` | Ver bordes, padding y alineación |
| **Performance overlay** | Tecla `P` | Gráfica de FPS (verde = bien, rojo = tirones) |
| **Breakpoints** | VS Code / Android Studio | Pausar y examinar variables |

---

## 8. Simuladores vs. dispositivos reales

| | Simulador iOS / Emulador Android | Dispositivo real |
|---|---|---|
| Costo | Gratis | Necesitas el teléfono |
| Velocidad para desarrollar | ✅ Muy rápido | ✅ Rápido |
| Rendimiento real | ❌ No representativo | ✅ Sí |
| Cámara, NFC, Bluetooth, notificaciones push | ❌ Limitado | ✅ |
| GPS | Simulado (*Features → Location*) | ✅ Real |
| Varios tamaños de pantalla | ✅ Fácil | ❌ Uno |

**Recomendación**: desarrolla en simuladores y prueba en un dispositivo real antes de publicar.

### Trucos del simulador iOS
- `Cmd+Shift+H` → botón Home · `Cmd+←/→` → rotar · `Cmd+K` → mostrar/ocultar teclado.
- *Features → Location* → simular ubicación GPS.
- *Device → Erase All Content and Settings* → resetear.

### Trucos del emulador Android
- Barra lateral **⋯ (Extended controls)** → ubicación GPS, batería, red, cámara, huella.
- `Cmd+←/→` → rotar.
- Si se queda colgado: *Device Manager → ⋮ → Cold Boot Now*.

---

## 9. Variables de entorno al ejecutar (`--dart-define`)

```bash
flutter run --dart-define=API_URL=https://dev.miapi.com --dart-define=DEBUG_LOGS=true
```
En Dart:
```dart
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://miapi.com');
const debugLogs = bool.fromEnvironment('DEBUG_LOGS');
```
Con archivo:
```bash
flutter run --dart-define-from-file=config/dev.json
```
```json
{ "API_URL": "https://dev.miapi.com", "DEBUG_LOGS": true }
```
