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
//   (Única excepción didáctica: ANTHROPIC_API_KEY para probar la IA en tu
//   ordenador; ver la sección IA al final.)
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

  // --------------------------------------------------------------- IA
  // Ver docs/15-ia-y-agentes.md. Hay DOS formas de conectar la IA:
  //
  // 1. AI_PROXY_URL (✅ la correcta en producción): la app llama a TU
  //    servidor, y el servidor añade la API key y llama a Anthropic. La key
  //    nunca está en el teléfono.
  //
  // 2. ANTHROPIC_API_KEY (⚠️ SOLO para aprender en tu ordenador): la key
  //    viaja dentro de la app. Cualquiera que descargue el binario podría
  //    extraerla y gastar tu saldo. NUNCA publiques una app así.
  //    Ponla en config/secrets.json (ignorado por git) y ejecuta:
  //      flutter run --dart-define-from-file=config/secrets.json
  //
  // Sin ninguna de las dos, la app usa un modo DEMO con respuestas de ejemplo.

  /// URL de tu backend que reenvía a la API de Anthropic (recomendado).
  static const aiProxyUrl = String.fromEnvironment('AI_PROXY_URL');

  /// API key de Anthropic. Solo para desarrollo local (ver arriba).
  static const anthropicApiKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  /// true si hay alguna forma de llamar a la IA real.
  static const aiEnabled = aiProxyUrl != '' || anthropicApiKey != '';
}
