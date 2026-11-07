// ============================================================================
// lib/features/ai/claude_client.dart — CLIENTE DE LA API DE CLAUDE (HTTP)
// ============================================================================
//
// QUÉ HACE
//   Habla con la Messages API de Anthropic (POST /v1/messages) usando el
//   paquete `http`. Dart no tiene SDK oficial de Anthropic, así que se usa la
//   API REST directamente (existen paquetes de la comunidad en pub.dev).
//
// DOS FORMAS DE LLAMAR
//   - createMessage(): espera la respuesta completa (para el agente y SVG).
//   - streamText(): recibe el texto POCO A POCO mientras se genera (Server-
//     Sent Events). Es lo que hace que el texto "se escriba solo" en pantalla.
//
// PETICIÓN (lo que viaja al servidor)
//   Cabeceras:
//     x-api-key            → tu API key (o nada si usas un proxy propio)
//     anthropic-version    → versión de la API (2026-10-21)
//     anthropic-beta       → server-side-fallback-2026-07-01 (ver `fallbacks`)
//   Cuerpo JSON:
//     model                → claude-opus-5-5
//     max_tokens           → límite de longitud de la respuesta
//     messages             → la conversación [{role: user|assistant, content}]
//     system               → instrucciones de comportamiento (opcional)
//     output_config.effort → cuánto "piensa" el modelo: low | medium | high…
//     fallbacks: "default" → si el modelo rechaza la petición por seguridad,
//                            Anthropic la reintenta con otro modelo adecuado.
//     tools                → herramientas que el modelo puede pedir usar.
//
// RESPUESTA
//   {content: [{type: "text", text: "..."}, {type: "thinking", ...}, ...],
//    stop_reason: "end_turn" | "tool_use" | "max_tokens" | "refusal", ...}
//   ⚠️ Comprueba SIEMPRE stop_reason antes de leer el contenido: "refusal"
//   significa que el modelo declinó responder.
//
// 📚 Guía: docs/15-ia-y-agentes.md
// ============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error de la API con un mensaje listo para mostrar.
class ClaudeException implements Exception {
  const ClaudeException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// El modelo declinó la petición (stop_reason: "refusal").
class ClaudeRefusal extends ClaudeException {
  const ClaudeRefusal()
    : super(
        'El modelo no puede ayudar con esta petición. Prueba a reformularla.',
      );
}

class ClaudeClient {
  ClaudeClient({
    required this.apiKey,
    String? baseUrl,
    http.Client? httpClient,
    this.model = defaultModel,
  }) : baseUrl = (baseUrl == null || baseUrl.isEmpty) ? officialUrl : baseUrl,
       _http = httpClient ?? http.Client();

  static const officialUrl = 'https://api.anthropic.com';
  static const defaultModel = 'claude-opus-5-5';
  static const apiVersion = '2026-10-21';
  static const fallbackBeta = 'server-side-fallback-2026-07-01';

  /// Vacía cuando se usa un proxy propio (el servidor añade la key).
  final String apiKey;
  final String baseUrl;
  final String model;
  final http.Client _http;

  Uri get _endpoint => Uri.parse('$baseUrl/v1/messages');

  Map<String, String> get _headers => {
    'content-type': 'application/json',
    'anthropic-version': apiVersion,
    'anthropic-beta': fallbackBeta,
    if (apiKey.isNotEmpty) 'x-api-key': apiKey,
  };

  /// Construye el cuerpo JSON de la petición.
  ///
  /// Sintaxis `'clave': ?valor` (Dart 3.8+): incluye la clave SOLO si el
  /// valor no es null. Así no se envía `"system": null` a la API.
  Map<String, Object?> buildBody({
    required List<Map<String, Object?>> messages,
    String? system,
    List<Map<String, Object?>>? tools,
    String effort = 'medium',
    int maxTokens = 16000,
    bool stream = false,
  }) => {
    'model': model,
    'max_tokens': maxTokens,
    'fallbacks': 'default',
    'output_config': {'effort': effort},
    'system': ?system,
    'messages': messages,
    'tools': ?tools,
    if (stream) 'stream': true,
  };

  /// Petición normal: espera la respuesta completa y la devuelve como Map.
  Future<Map<String, Object?>> createMessage({
    required List<Map<String, Object?>> messages,
    String? system,
    List<Map<String, Object?>>? tools,
    String effort = 'medium',
    int maxTokens = 16000,
  }) async {
    final http.Response response;
    try {
      response = await _http
          .post(
            _endpoint,
            headers: _headers,
            body: jsonEncode(
              buildBody(
                messages: messages,
                system: system,
                tools: tools,
                effort: effort,
                maxTokens: maxTokens,
              ),
            ),
          )
          .timeout(const Duration(minutes: 3));
    } on TimeoutException {
      throw const ClaudeException('La IA tardó demasiado en responder.');
    } on http.ClientException {
      throw const ClaudeException('No hay conexión con el servicio de IA.');
    }

    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode != 200) throw _httpError(response.statusCode, body);

    final json = jsonDecode(body) as Map<String, Object?>;
    if (json['stop_reason'] == 'refusal') throw const ClaudeRefusal();
    return json;
  }

  /// Streaming: emite cada fragmento de texto según se genera.
  ///
  /// La respuesta llega como Server-Sent Events, líneas del tipo:
  ///   event: content_block_delta
  ///   data: {"type":"content_block_delta","delta":{"type":"text_delta","text":"Hola"}}
  /// Solo nos interesan los `text_delta`. Los bloques de "thinking" (el
  /// razonamiento interno del modelo) se ignoran.
  Stream<String> streamText({
    required List<Map<String, Object?>> messages,
    String? system,
    String effort = 'low',
    int maxTokens = 64000,
  }) async* {
    final request = http.Request('POST', _endpoint)
      ..headers.addAll(_headers)
      ..body = jsonEncode(
        buildBody(
          messages: messages,
          system: system,
          effort: effort,
          maxTokens: maxTokens,
          stream: true,
        ),
      );

    final http.StreamedResponse response;
    try {
      response = await _http.send(request);
    } on http.ClientException {
      throw const ClaudeException('No hay conexión con el servicio de IA.');
    }
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw _httpError(response.statusCode, body);
    }

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue; // ignora "event:" y vacías
      final event = jsonDecode(line.substring(6)) as Map<String, Object?>;
      switch (event['type']) {
        case 'content_block_delta':
          final delta = event['delta']! as Map<String, Object?>;
          if (delta['type'] == 'text_delta') yield delta['text']! as String;
        case 'message_delta':
          final delta = event['delta']! as Map<String, Object?>;
          if (delta['stop_reason'] == 'refusal') throw const ClaudeRefusal();
        case 'error':
          final error = event['error'] as Map<String, Object?>?;
          throw ClaudeException(
            'Error de la IA: ${error?['message'] ?? 'desconocido'}',
          );
      }
    }
  }

  /// Junta todos los bloques de texto de una respuesta (ignora thinking y
  /// tool_use).
  static String textOf(Map<String, Object?> message) => [
    for (final block in message['content']! as List<Object?>)
      if ((block! as Map<String, Object?>)['type'] == 'text')
        (block as Map<String, Object?>)['text']! as String,
  ].join('\n').trim();

  /// Traduce los códigos HTTP más habituales a mensajes claros.
  ClaudeException _httpError(int status, String body) {
    String? apiMessage;
    try {
      final json = jsonDecode(body) as Map<String, Object?>;
      apiMessage =
          (json['error'] as Map<String, Object?>?)?['message'] as String?;
    } on FormatException {
      // cuerpo no JSON
    }
    final message = switch (status) {
      401 => 'API key inválida o ausente.',
      403 => 'Esta API key no tiene permiso para esta operación.',
      429 => 'Demasiadas peticiones. Espera un momento y reintenta.',
      529 => 'El servicio está saturado. Reintenta en unos segundos.',
      >= 500 => 'Error temporal del servidor de IA. Reintenta.',
      _ => 'Petición no válida: ${apiMessage ?? 'código $status'}',
    };
    return ClaudeException(message, statusCode: status);
  }

  void close() => _http.close();
}
