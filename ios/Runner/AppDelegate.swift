// ============================================================================
// AppDelegate.swift — PUNTO DE ENTRADA NATIVO DE iOS
// ============================================================================
// Clase que iOS ejecuta al abrir la app. Hereda de FlutterAppDelegate, que
// arranca el motor de Flutter y muestra la interfaz de lib/main.dart.
//
// Normalmente NO necesitas tocarlo. Lo editarás para:
//   - Configurar SDKs nativos que lo pidan en su documentación (p. ej.
//     Google Maps: GMSServices.provideAPIKey("...")).
//   - Escribir código nativo Swift (MethodChannel entre Dart y iOS).
//
// 📚 Más: ios/README.md
// ============================================================================
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Se ejecuta una vez cuando la app termina de arrancar.
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Se ejecuta cuando el motor de Flutter está listo: registra los plugins
  // (paquetes con código nativo) que añadiste en pubspec.yaml.
  // GeneratedPluginRegistrant lo genera Flutter automáticamente: no lo edites.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
