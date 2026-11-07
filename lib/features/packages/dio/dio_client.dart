// ============================================================================
// lib/features/packages/dio/dio_client.dart — CLIENTE HTTP CON DIO
// ============================================================================
//
// QUÉ ES DIO
//   El cliente HTTP más usado en apps Flutter profesionales (ver docs/12).
//   Frente al paquete `http` (usado en lib/core/network/api_client.dart),
//   Dio añade:
//   - BaseOptions: URL base, timeouts y cabeceras comunes en un solo lugar.
//   - INTERCEPTORES: código que se ejecuta en TODAS las peticiones (añadir el
//     token de sesión, registrar logs, reintentar, refrescar tokens…).
//   - JSON automático: response.data ya viene decodificado (Map/List).
//   - CancelToken: cancelar peticiones (p. ej. al salir de la pantalla).
//   - DioException con un `type` que indica QUÉ falló (timeout, 404, sin red…).
//   - Progreso de subida/descarga de archivos (onSendProgress/onReceiveProgress).
//
// CÓMO FUNCIONA UN INTERCEPTOR
//   petición → [Auth] → [Log] → servidor → [Log] → [Auth] → tu código
//   Cada interceptor recibe la petición/respuesta/error y llama a
//   handler.next(...) para pasarla al siguiente (o resolve/reject para cortar).
// ============================================================================

import 'package:dio/dio.dart';
import 'package:mi_primera_app/core/config/env.dart';

/// Añade la cabecera `Authorization: Bearer <token>` a cada petición.
/// En una app real el token vendría de flutter_secure_storage tras el login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.readToken);

  final String? Function() readToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = readToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options); // continúa hacia el siguiente interceptor
  }
}

/// Registra cada petición, respuesta y error (aquí, en una lista que la
/// pantalla muestra; en producción, en la consola o en Sentry/Crashlytics).
class LogCollectorInterceptor extends Interceptor {
  LogCollectorInterceptor(this.onLog);

  final void Function(String line) onLog;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    onLog('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    onLog('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    onLog('✖ ${err.type.name} ${err.requestOptions.path}');
    handler.next(err);
  }
}

/// Crea un Dio configurado. Se usa una sola instancia por API.
Dio createDio({
  String? baseUrl,
  String? Function()? readToken,
  void Function(String line)? onLog,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([
    AuthInterceptor(readToken ?? () => 'demo-token-123'),
    if (onLog != null) LogCollectorInterceptor(onLog),
  ]);
  return dio;
}

/// Traduce un DioException a un mensaje para el usuario.
///
/// El `switch` de Dart 3 es EXHAUSTIVO: si una versión nueva de Dio añade un
/// tipo de error (como `transformTimeout` en 5.x), el analizador avisa de que
/// falta un caso. Mejor que un `default` que lo esconde.
String describeDioError(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.transformTimeout => 'La petición tardó demasiado.',
  DioExceptionType.badResponse =>
    'El servidor respondió con error ${e.response?.statusCode}.',
  DioExceptionType.cancel => 'Petición cancelada.',
  DioExceptionType.connectionError => 'No hay conexión a internet.',
  DioExceptionType.badCertificate => 'Certificado del servidor no válido.',
  DioExceptionType.unknown => 'Error inesperado: ${e.message}',
};
