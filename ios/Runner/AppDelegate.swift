// ============================================================================
// AppDelegate.swift — PUNTO DE ENTRADA NATIVO DE iOS + MethodChannel
// ============================================================================
// Clase que iOS ejecuta al abrir la app. Hereda de FlutterAppDelegate, que
// arranca el motor de Flutter y muestra la interfaz de lib/.
//
// Además, aquí se registra un MethodChannel: el puente que permite a Dart
// llamar a código Swift. Lo usa la demo "Código nativo":
//   Dart:     lib/features/advanced/native_channel.dart
//   Android:  android/app/src/main/kotlin/.../MainActivity.kt (misma API)
//
// También lo editarás para configurar SDKs nativos que lo pidan en su
// documentación (p. ej. Google Maps: GMSServices.provideAPIKey("...")).
//
// ⚠️ Tras editar este archivo: detén la app y ejecuta de nuevo `flutter run`.
// 📚 Más: ios/README.md · docs/11-configuraciones-avanzadas.md (sección 8)
// ============================================================================
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Mismo nombre que en Dart (DeviceInfoService._channel).
  private let channelName = "com.jeanrondon.mi_primera_app/device"

  // Se ejecuta una vez cuando la app termina de arrancar.
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Se ejecuta cuando el motor de Flutter está listo.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // 1. Registra los plugins (paquetes con código nativo) de pubspec.yaml.
    //    GeneratedPluginRegistrant lo genera Flutter: no lo edites.
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // 2. Registra nuestro canal propio usando el "messenger" del motor.
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      // `call.method` es el nombre pasado a invokeMethod en Dart.
      switch call.method {
      case "getDeviceInfo":
        let device = UIDevice.current
        // Un diccionario de Swift llega a Dart como Map<String, String>.
        result([
          "Sistema": "\(device.systemName) \(device.systemVersion)",
          "Modelo": device.model,
          "Nombre": device.name,
          "Respondido por": "Swift (AppDelegate.swift)",
        ])

      case "greet":
        // Argumentos enviados desde Dart: {'name': 'Jean'}
        guard
          let args = call.arguments as? [String: Any],
          let name = args["name"] as? String,
          !name.isEmpty
        else {
          // FlutterError → en Dart llega una PlatformException
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Falta 'name'", details: nil))
          return
        }
        result("¡Hola, \(name)! Saludos desde Swift 🍎")

      default:
        // Método desconocido → en Dart: MissingPluginException
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
