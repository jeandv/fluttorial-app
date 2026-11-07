// ============================================================================
// test/features/ai/claude_client_test.dart — CLIENTE DE CLAUDE SIN INTERNET
// ============================================================================
// MockClient simula el servidor de Anthropic: comprobamos QUÉ enviamos
// (cabeceras y cuerpo) y CÓMO interpretamos las respuestas, sin gastar saldo.
// ============================================================================

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_primera_app/features/ai/ai_service.dart';
import 'package:mi_primera_app/features/ai/claude_client.dart';

Map<String, Object?> textMessage(String text, {String stop = 'end_turn'}) => {
  'role': 'assistant',
  'content': [
    {'type': 'thinking', 'thinking': '', 'signature': 'sig'},
    {'type': 'text', 'text': text},
  ],
  'stop_reason': stop,
};

void main() {
  test('envía las cabeceras y el cuerpo correctos', () async {
    late http.Request sent;
    final client = ClaudeClient(
      apiKey: 'sk-test',
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response(jsonEncode(textMessage('Hola')), 200);
      }),
    );

    await client.createMessage(
      system: 'Eres útil',
      effort: 'low',
      messages: [
        {'role': 'user', 'content': 'Hola'},
      ],
    );

    expect(sent.url.toString(), 'https://api.anthropic.com/v1/messages');
    expect(sent.headers['x-api-key'], 'sk-test');
    expect(sent.headers['anthropic-version'], '2026-10-21');
    expect(sent.headers['anthropic-beta'], 'server-side-fallback-2026-07-01');

    final body = jsonDecode(sent.body) as Map<String, Object?>;
    expect(body['model'], 'claude-opus-5-5');
    expect(body['fallbacks'], 'default');
    expect(body['output_config'], {'effort': 'low'});
    expect(body['system'], 'Eres útil');
    expect(body.containsKey('tools'), isFalse); // null → no se envía
  });

  test('con proxy no se envía la API key', () async {
    late http.Request sent;
    final client = ClaudeClient(
      apiKey: '',
      baseUrl: 'https://mi-backend.com/ia',
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response(jsonEncode(textMessage('ok')), 200);
      }),
    );
    await client.createMessage(
      messages: [
        {'role': 'user', 'content': 'hola'},
      ],
    );
    expect(sent.url.toString(), 'https://mi-backend.com/ia/v1/messages');
    expect(sent.headers.containsKey('x-api-key'), isFalse);
  });

  test('textOf ignora los bloques de thinking', () {
    expect(ClaudeClient.textOf(textMessage('Respuesta')), 'Respuesta');
  });

  test('stop_reason "refusal" lanza ClaudeRefusal', () async {
    final client = ClaudeClient(
      apiKey: 'k',
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({'content': <Object>[], 'stop_reason': 'refusal'}),
          200,
        ),
      ),
    );
    expect(
      client.createMessage(
        messages: [
          {'role': 'user', 'content': 'x'},
        ],
      ),
      throwsA(isA<ClaudeRefusal>()),
    );
  });

  test('un 401 se traduce a un mensaje claro', () async {
    final client = ClaudeClient(
      apiKey: 'mala',
      httpClient: MockClient(
        (_) async => http.Response(
          '{"type":"error","error":{"type":"authentication_error","message":"invalid x-api-key"}}',
          401,
        ),
      ),
    );
    expect(
      client.createMessage(
        messages: [
          {'role': 'user', 'content': 'x'},
        ],
      ),
      throwsA(
        isA<ClaudeException>().having(
          (e) => e.message,
          'message',
          'API key inválida o ausente.',
        ),
      ),
    );
  });

  test('streamText une los text_delta del stream SSE', () async {
    // Respuesta en formato Server-Sent Events, como la real.
    const sse =
        'event: message_start\n'
        'data: {"type":"message_start","message":{"id":"msg_1"}}\n\n'
        'event: content_block_delta\n'
        'data: {"type":"content_block_delta","index":0,"delta":{"type":"thinking_delta","thinking":""}}\n\n'
        'event: content_block_delta\n'
        'data: {"type":"content_block_delta","index":1,"delta":{"type":"text_delta","text":"Hola "}}\n\n'
        'event: content_block_delta\n'
        'data: {"type":"content_block_delta","index":1,"delta":{"type":"text_delta","text":"mundo"}}\n\n'
        'event: message_delta\n'
        'data: {"type":"message_delta","delta":{"stop_reason":"end_turn"}}\n\n'
        'event: message_stop\n'
        'data: {"type":"message_stop"}\n\n';

    late Map<String, Object?> body;
    final client = ClaudeClient(
      apiKey: 'k',
      httpClient: MockClient.streaming((request, bodyStream) async {
        body = jsonDecode(
          await bodyStream.bytesToString(),
        ) as Map<String, Object?>;
        return http.StreamedResponse(Stream.value(utf8.encode(sse)), 200);
      }),
    );

    final chunks = await client
        .streamText(
          messages: [
            {'role': 'user', 'content': 'hola'},
          ],
        )
        .toList();

    expect(chunks, ['Hola ', 'mundo']);
    expect(body['stream'], isTrue);
  });

  test('extractSvg saca el SVG aunque venga envuelto en Markdown', () {
    const text =
        'Aquí está:\n```svg\n<svg viewBox="0 0 1 1"><rect/></svg>\n```';
    expect(extractSvg(text), '<svg viewBox="0 0 1 1"><rect/></svg>');
    expect(() => extractSvg('sin svg'), throwsA(isA<ClaudeException>()));
  });

  test('DemoAiService funciona sin red', () async {
    const demo = DemoAiService(wordDelay: Duration.zero);
    final text = (await demo.tips('tests').toList()).join();
    expect(text, contains('tests'));
    expect(await demo.svgIllustration('x'), startsWith('<svg'));
  });
}
