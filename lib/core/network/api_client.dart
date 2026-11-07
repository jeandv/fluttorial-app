// ============================================================================
// lib/core/network/api_client.dart — CLIENTE HTTP REUTILIZABLE
// ============================================================================
//
// QUÉ HACE
//   Envuelve el paquete `http` para que TODAS las peticiones de la app:
//   - usen la misma URL base (Env.apiBaseUrl),
//   - tengan un tiempo máximo de espera (timeout),
//   - conviertan la respuesta JSON en objetos Dart,
//   - transformen cualquier fallo en un único tipo de error (ApiException)
//     con un mensaje entendible para mostrar en pantalla.
//
// CÓMO FUNCIONA
//   1. Se construye la URL:  Uri.parse('$baseUrl$path').replace(queryParameters: ...)
//   2. `await _client.get(uri)` hace la petición (asíncrona).
//   3. Se revisa el código de estado HTTP (200-299 = éxito).
//   4. `jsonDecode(body)` convierte el texto JSON en Map / List de Dart.
//
// POR QUÉ RECIBE `http.Client` EN EL CONSTRUCTOR
//   Inyección de dependencias: en los tests se pasa un `MockClient` que
//   devuelve respuestas falsas, sin usar internet
//   (ver test/features/posts/posts_repository_test.dart).
//
// ⚠️ Android en RELEASE necesita el permiso INTERNET en
//    android/app/src/main/AndroidManifest.xml (ya está añadido).
//
// 📚 Guía: docs/06-construir-la-app.md (sección 8) · docs/11 (sección 7)
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mi_primera_app/core/config/env.dart';

/// Error único para todos los fallos de red. La UI solo necesita conocer este.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      statusCode == null ? message : '$message (código $statusCode)';
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? Env.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 10);

  /// Hace un GET y devuelve el JSON decodificado (Map o List).
  Future<Object?> getJson(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'El servidor respondió con un error',
          statusCode: response.statusCode,
        );
      }
      return jsonDecode(response.body);
    } on TimeoutException {
      throw const ApiException(
        'La petición tardó demasiado. Revisa tu conexión.',
      );
    } on http.ClientException {
      throw const ApiException('No hay conexión con el servidor.');
    } on FormatException {
      throw const ApiException('La respuesta del servidor no es JSON válido.');
    }
  }

  /// Cierra las conexiones abiertas. Riverpod lo llama al destruir el provider.
  void close() => _client.close();
}

/// Provider del cliente HTTP: una sola instancia compartida por toda la app.
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close); // libera recursos cuando ya no se usa
  return client;
});
