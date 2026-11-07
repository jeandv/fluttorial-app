// ============================================================================
// MainActivity.kt — PUNTO DE ENTRADA NATIVO DE ANDROID + MethodChannel
// ============================================================================
// Es la única "pantalla" (Activity) nativa de la app. FlutterActivity arranca
// el motor de Flutter y dibuja dentro toda la interfaz de lib/.
//
// Además, aquí se registra un MethodChannel: el puente que permite a Dart
// llamar a código Kotlin. Lo usa la demo "Código nativo":
//   Dart:   lib/features/advanced/native_channel.dart
//   iOS:    ios/Runner/AppDelegate.swift (la misma API, en Swift)
//
// El `package` debe coincidir con `namespace` en android/app/build.gradle.kts.
// ⚠️ Tras editar este archivo: detén la app y ejecuta de nuevo `flutter run`.
// 📚 Más: android/README.md · docs/11-configuraciones-avanzadas.md (sección 8)
// ============================================================================
package com.jeanrondon.mi_primera_app

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Mismo nombre que en Dart (DeviceInfoService._channel).
    private val channelName = "com.jeanrondon.mi_primera_app/device"

    // Se ejecuta cuando el motor de Flutter está listo. Es el lugar para
    // registrar canales propios.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine) // registra los plugins

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                // `call.method` es el nombre pasado a invokeMethod en Dart.
                when (call.method) {
                    "getDeviceInfo" -> result.success(
                        // Un Map de Kotlin llega a Dart como Map<String, String>.
                        mapOf(
                            "Sistema" to "Android ${Build.VERSION.RELEASE}",
                            "API (SDK)" to Build.VERSION.SDK_INT.toString(),
                            "Fabricante" to Build.MANUFACTURER,
                            "Modelo" to Build.MODEL,
                            "Respondido por" to "Kotlin (MainActivity.kt)",
                        )
                    )

                    "greet" -> {
                        // Argumentos enviados desde Dart: {'name': 'Jean'}
                        val name = call.argument<String>("name")
                        if (name.isNullOrBlank()) {
                            // result.error → en Dart llega una PlatformException
                            result.error("INVALID_ARGUMENT", "Falta 'name'", null)
                        } else {
                            result.success("¡Hola, $name! Saludos desde Kotlin 🤖")
                        }
                    }

                    // Método desconocido → en Dart: MissingPluginException
                    else -> result.notImplemented()
                }
            }
    }
}
