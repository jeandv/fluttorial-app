// ============================================================================
// lib/core/config/env.dart — VARIABLES DE ENTORNO (--dart-define)
// ============================================================================
//
// QUÉ HACE
//   Centraliza la configuración que cambia según el entorno (dev / prod):
//   URL de la API, nombre del "flavor", banderas de depuración…
//
// CÓMO FUNCIONA
//   `String.fromEnvironment('CLAVE')` lee un valor que se pasa AL COMPILAR:
//     flutter run --dart-define=API_URL=https://dev.miapi.com --dart-define=FLAVOR=dev
//   o desde un archivo JSON (este proyecto incluye config/dev.json y prod.json):
//     flutter run --dart-define-from-file=config/dev.json
//
//   ⚠️ Son CONSTANTES de compilación: si cambias el valor tienes que volver a
//   ejecutar `flutter run` (hot reload/restart NO las recargan).
//   ⚠️ NO pongas secretos aquí (claves privadas): cualquiera puede extraerlos
//   del binario de la app. Los secretos deben vivir en tu backend.
//
// CÓMO SE USA
//   import 'package:mi_primera_app/core/config/env.dart';
//   final url = Env.apiBaseUrl;
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 6)
// ============================================================================

/// Configuración de la app según el entorno.
///
/// `abstract final class` = no se puede instanciar ni heredar: es solo un
/// contenedor de constantes estáticas.
abstract final class Env {
  /// URL base de la API REST. Por defecto usa JSONPlaceholder, una API
  /// pública y gratuita para practicar (https://jsonplaceholder.typicode.com).
  static const apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://jsonplaceholder.typicode.com',
  );

  /// Nombre del entorno: 'dev', 'staging' o 'prod'.
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// `true` cuando se compila con --dart-define=FLAVOR=prod.
  static const isProduction = flavor == 'prod';

  /// Muestra la franja "DEBUG" (solo se ve en modo debug).
  /// Actívala con --dart-define=SHOW_DEBUG_BANNER=true
  static const showDebugBanner = bool.fromEnvironment('SHOW_DEBUG_BANNER');
}
