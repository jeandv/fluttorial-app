// ============================================================================
// test/features/ai/todo_agent_test.dart — EL BUCLE DEL AGENTE
// ============================================================================
// El "servidor" falso responde primero pidiendo una herramienta (tool_use) y
// después con la respuesta final. Comprobamos que el agente:
//   - ejecuta la herramienta sobre la lista de tareas,
//   - devuelve el tool_result con el tool_use_id correcto,
//   - reenvía el contenido del asistente SIN modificar (thinking incluido).
// ============================================================================

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_primera_app/features/ai/claude_client.dart';
import 'package:mi_primera_app/features/ai/todo_agent.dart';
import 'package:mi_primera_app/features/todos/todo.dart';

/// Lista de tareas en memoria para el agente.
class FakeTodos {
  final items = <Todo>[];

  TodoToolbox get toolbox => TodoToolbox(
    list: () => List.of(items),
    add: (title) => items.add(
      Todo(id: '${items.length + 1}', title: title, createdAt: DateTime(2026)),
    ),
    toggle: (id) {
      final i = items.indexWhere((t) => t.id == id);
      items[i] = items[i].copyWith(done: !items[i].done);
    },
    now: () => DateTime(2026, 11, 7),
  );
}

void main() {
  const thinkingBlock = {
    'type': 'thinking',
    'thinking': '',
    'signature': 'firma-123',
  };

  test('ejecuta add_todo y termina con la respuesta final', () async {
    final todos = FakeTodos();
    final requests = <Map<String, Object?>>[];

    final responses = [
      // 1ª respuesta: pide usar la herramienta.
      {
        'content': [
          thinkingBlock,
          {
            'type': 'tool_use',
            'id': 'toolu_1',
            'name': 'add_todo',
            'input': {'title': 'Comprar leche'},
          },
        ],
        'stop_reason': 'tool_use',
      },
      // 2ª respuesta: texto final.
      {
        'content': [
          {'type': 'text', 'text': 'Añadí "Comprar leche".'},
        ],
        'stop_reason': 'end_turn',
      },
    ];

    final client = ClaudeClient(
      apiKey: 'k',
      httpClient: MockClient((request) async {
        requests.add(jsonDecode(request.body) as Map<String, Object?>);
        // Response.bytes + UTF-8: igual que la API real (con texto como
        // "Añadí", http.Response(String) usaría Latin-1 por defecto).
        return http.Response.bytes(
          utf8.encode(jsonEncode(responses[requests.length - 1])),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    final agent = ClaudeTodoAgent(client, todos.toolbox);

    final events = await agent.send('Añade comprar leche').toList();

    // La herramienta modificó la lista.
    expect(todos.items.single.title, 'Comprar leche');

    // Eventos para la UI: llamada, resultado y texto final.
    expect(events[0], isA<AgentToolCall>());
    expect(events[1], isA<AgentToolResult>());
    expect((events[2] as AgentText).text, 'Añadí "Comprar leche".');

    // Se enviaron las herramientas.
    expect((requests.first['tools']! as List).length, 4);

    // La 2ª petición incluye el contenido del asistente intacto y el
    // tool_result en un único mensaje de usuario.
    final messages = (requests[1]['messages']! as List)
        .cast<Map<String, Object?>>();
    expect(messages, hasLength(3));
    final assistantContent = messages[1]['content']! as List;
    expect(assistantContent.first, thinkingBlock);
    final toolResults = messages[2]['content']! as List;
    expect(toolResults.single, {
      'type': 'tool_result',
      'tool_use_id': 'toolu_1',
      'content': 'Tarea creada: "Comprar leche"',
    });
  });

  test('un error de la API deshace el turno del historial', () async {
    final client = ClaudeClient(
      apiKey: 'k',
      httpClient: MockClient((_) async => http.Response('{}', 500)),
    );
    final agent = ClaudeTodoAgent(client, FakeTodos().toolbox);

    await expectLater(
      agent.send('hola').toList(),
      throwsA(isA<ClaudeException>()),
    );
    expect(agent.messages, isEmpty);
  });

  group('TodoToolbox', () {
    test('complete_todo con id inexistente devuelve error', () {
      final (output, isError) = FakeTodos().toolbox.execute('complete_todo', {
        'id': 'nope',
      });
      expect(isError, isTrue);
      expect(output, contains('No existe'));
    });

    test('get_today devuelve la fecha ISO', () {
      expect(FakeTodos().toolbox.execute('get_today', {}).$1, '2026-11-07');
    });
  });

  test('DemoTodoAgent añade varias tareas sin IA', () async {
    final todos = FakeTodos();
    final agent = DemoTodoAgent(todos.toolbox);
    await agent.send('Añade comprar pan y llamar a Ana').toList();
    expect(todos.items.map((t) => t.title), ['comprar pan', 'llamar a ana']);
  });
}
