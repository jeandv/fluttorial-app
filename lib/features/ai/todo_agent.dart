// ============================================================================
// lib/features/ai/todo_agent.dart — UN AGENTE DE IA CON HERRAMIENTAS
// ============================================================================
//
// ¿QUÉ ES UN AGENTE?
//   Un modelo de IA que no solo responde texto: puede DECIDIR usar
//   herramientas (funciones de tu app) para lograr un objetivo, ver el
//   resultado y seguir hasta terminar. Aquí el agente gestiona tu lista de
//   Tareas real (la misma de la pestaña "Tareas").
//
// EL BUCLE DEL AGENTE (lo que hace run())
//   1. Envía la conversación + la lista de herramientas a Claude.
//   2. Si responde con stop_reason == "tool_use", trae bloques tool_use:
//        {type: tool_use, id: "toolu_…", name: "add_todo", input: {title: …}}
//   3. La APP ejecuta esas funciones (el modelo nunca ejecuta código).
//   4. Devuelve TODOS los resultados en UN mensaje de usuario:
//        {type: tool_result, tool_use_id: "toolu_…", content: "…"}
//   5. Repite hasta que stop_reason sea "end_turn" (respuesta final).
//
// REGLAS IMPORTANTES
//   - Añade a la conversación el `content` del asistente TAL CUAL (incluidos
//     los bloques "thinking"): la API los necesita intactos.
//   - Cada tool_result debe llevar el tool_use_id correspondiente.
//   - Si una herramienta falla, devuelve el error con is_error: true (el
//     modelo lo verá e intentará otra cosa).
//   - Limita el número de vueltas (maxSteps) para evitar bucles infinitos.
//   - Herramientas destructivas (borrar, pagar, enviar) → pide confirmación
//     al usuario antes de ejecutarlas. Por eso aquí NO hay "borrar tarea".
//
// 📚 Guía: docs/15-ia-y-agentes.md (sección Agentes)
// ============================================================================

import 'dart:convert';

import 'package:mi_primera_app/features/ai/claude_client.dart';
import 'package:mi_primera_app/features/todos/todo.dart';

/// Lo que va pasando mientras el agente trabaja (la UI lo muestra).
sealed class AgentEvent {
  const AgentEvent();
}

/// Texto del asistente para el usuario.
class AgentText extends AgentEvent {
  const AgentText(this.text);
  final String text;
}

/// El agente decidió usar una herramienta.
class AgentToolCall extends AgentEvent {
  const AgentToolCall(this.name, this.input);
  final String name;
  final Map<String, Object?> input;
}

/// Resultado de ejecutar la herramienta.
class AgentToolResult extends AgentEvent {
  const AgentToolResult(this.name, this.output, {this.isError = false});
  final String name;
  final String output;
  final bool isError;
}

/// Puente entre el agente y la lista de tareas de la app. Se pasan funciones
/// (y no Riverpod directamente) para poder probarlo fácilmente.
class TodoToolbox {
  const TodoToolbox({
    required this.list,
    required this.add,
    required this.toggle,
    this.now,
  });

  final List<Todo> Function() list;
  final void Function(String title) add;
  final void Function(String id) toggle;
  final DateTime Function()? now;

  /// Definición de las herramientas para la API (JSON Schema).
  /// `strict: true` + `additionalProperties: false` garantizan que los
  /// argumentos del modelo cumplen exactamente el esquema.
  static const definitions = <Map<String, Object?>>[
    {
      'name': 'list_todos',
      'description':
          'Devuelve todas las tareas del usuario con su id, título y si están '
          'hechas. Úsala antes de completar una tarea para conocer su id, o '
          'cuando el usuario pregunte qué tiene pendiente.',
      'strict': true,
      'input_schema': {
        'type': 'object',
        'properties': <String, Object?>{},
        'required': <String>[],
        'additionalProperties': false,
      },
    },
    {
      'name': 'add_todo',
      'description':
          'Crea una tarea nueva. Úsala una vez por cada tarea que el usuario '
          'pida añadir.',
      'strict': true,
      'input_schema': {
        'type': 'object',
        'properties': {
          'title': {
            'type': 'string',
            'description': 'Texto breve de la tarea, p. ej. "Comprar leche"',
          },
        },
        'required': ['title'],
        'additionalProperties': false,
      },
    },
    {
      'name': 'complete_todo',
      'description':
          'Marca una tarea como hecha a partir de su id (obtenlo antes con '
          'list_todos).',
      'strict': true,
      'input_schema': {
        'type': 'object',
        'properties': {
          'id': {'type': 'string', 'description': 'id de la tarea'},
        },
        'required': ['id'],
        'additionalProperties': false,
      },
    },
    {
      'name': 'get_today',
      'description':
          'Devuelve la fecha de hoy. Úsala si el usuario menciona "hoy", '
          '"mañana" o fechas relativas.',
      'strict': true,
      'input_schema': {
        'type': 'object',
        'properties': <String, Object?>{},
        'required': <String>[],
        'additionalProperties': false,
      },
    },
  ];

  /// Ejecuta una herramienta. Devuelve (salida, ¿es error?).
  (String, bool) execute(String name, Map<String, Object?> input) {
    switch (name) {
      case 'list_todos':
        return (
          jsonEncode([
            for (final t in list())
              {'id': t.id, 'title': t.title, 'done': t.done},
          ]),
          false,
        );
      case 'add_todo':
        final title = (input['title'] as String? ?? '').trim();
        if (title.isEmpty) return ('El título no puede estar vacío', true);
        add(title);
        return ('Tarea creada: "$title"', false);
      case 'complete_todo':
        final id = input['id'] as String? ?? '';
        final matches = list().where((t) => t.id == id);
        if (matches.isEmpty) return ('No existe una tarea con id "$id"', true);
        final todo = matches.first;
        if (todo.done) {
          return ('La tarea "${todo.title}" ya estaba hecha', false);
        }
        toggle(id);
        return ('Tarea "${todo.title}" marcada como hecha', false);
      case 'get_today':
        return (
          (now ?? DateTime.now)().toIso8601String().substring(0, 10),
          false,
        );
      default:
        return ('Herramienta desconocida: $name', true);
    }
  }
}

/// Interfaz común: agente real o de demostración.
abstract interface class TodoAgent {
  bool get isDemo;
  Stream<AgentEvent> send(String userMessage);
  void reset();
}

// ===========================================================================
// AGENTE REAL (Claude + bucle de herramientas)
// ===========================================================================

class ClaudeTodoAgent implements TodoAgent {
  ClaudeTodoAgent(this._client, this._tools, {this.maxSteps = 8});

  final ClaudeClient _client;
  final TodoToolbox _tools;
  final int maxSteps;

  /// Historial completo de la conversación (se envía en cada petición: la
  /// API no recuerda nada entre llamadas).
  final List<Map<String, Object?>> _messages = [];

  /// Solo lectura, útil para tests y depuración.
  List<Map<String, Object?>> get messages => List.unmodifiable(_messages);

  static const _system =
      'Eres un asistente que gestiona la lista de tareas del usuario dentro '
      'de una app móvil. Usa las herramientas para leer y modificar la lista; '
      'no inventes tareas ni ids. Responde en español, breve y amable, y '
      'confirma qué cambios hiciste.';

  @override
  bool get isDemo => false;

  @override
  void reset() => _messages.clear();

  @override
  Stream<AgentEvent> send(String userMessage) async* {
    final checkpoint = _messages.length;
    _messages.add({'role': 'user', 'content': userMessage});

    try {
      for (var step = 0; step < maxSteps; step++) {
        // 1. Llamar al modelo con la conversación y las herramientas.
        final response = await _client.createMessage(
          system: _system,
          messages: _messages,
          tools: TodoToolbox.definitions,
          effort: 'medium',
        );
        final content = (response['content']! as List<Object?>)
            .cast<Map<String, Object?>>();

        // 2. Guardar la respuesta del asistente SIN modificarla.
        _messages.add({'role': 'assistant', 'content': content});

        // Mostrar el texto (si lo hay) al usuario.
        final text = ClaudeClient.textOf(response);
        if (text.isNotEmpty) yield AgentText(text);

        // ¿Terminó? (end_turn, max_tokens…). Solo seguimos si pidió herramientas.
        if (response['stop_reason'] != 'tool_use') return;

        // 3. Ejecutar TODAS las herramientas pedidas en este turno.
        final results = <Map<String, Object?>>[];
        for (final block in content.where((b) => b['type'] == 'tool_use')) {
          final name = block['name']! as String;
          final input = (block['input']! as Map).cast<String, Object?>();
          yield AgentToolCall(name, input);

          final (output, isError) = _tools.execute(name, input);
          yield AgentToolResult(name, output, isError: isError);

          results.add({
            'type': 'tool_result',
            'tool_use_id': block['id'],
            'content': output,
            if (isError) 'is_error': true,
          });
        }

        // 4. Devolver todos los resultados en UN solo mensaje de usuario.
        _messages.add({'role': 'user', 'content': results});
      }
      yield const AgentText(
        'He llegado al límite de pasos. ¿Puedes concretar un poco más?',
      );
    } catch (_) {
      // Si algo falla, deshacemos este turno para no dejar el historial a
      // medias (un tool_use sin su tool_result rompería la siguiente petición).
      _messages.removeRange(checkpoint, _messages.length);
      rethrow;
    }
  }
}

// ===========================================================================
// AGENTE DEMO (sin IA: reglas simples que IMITAN el bucle de herramientas)
// ===========================================================================

class DemoTodoAgent implements TodoAgent {
  const DemoTodoAgent(this._tools);

  final TodoToolbox _tools;

  @override
  bool get isDemo => true;

  @override
  void reset() {}

  @override
  Stream<AgentEvent> send(String userMessage) async* {
    final text = userMessage.toLowerCase();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    Stream<AgentEvent> call(String name, Map<String, Object?> input) async* {
      yield AgentToolCall(name, input);
      final (output, isError) = _tools.execute(name, input);
      yield AgentToolResult(name, output, isError: isError);
    }

    final addMatch = RegExp(r'(?:añade|agrega|crea|anota)\s+(.+)')
        .firstMatch(text);
    if (addMatch != null) {
      // "añade comprar pan y llamar a Ana" → dos tareas.
      final titles = addMatch
          .group(1)!
          .split(RegExp(r',|\sy\s'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty);
      for (final title in titles) {
        yield* call('add_todo', {'title': title});
      }
      yield AgentText('Listo, añadí ${titles.length} tarea(s). _(modo demo)_');
      return;
    }

    final completeMatch = RegExp(
      r'(?:completa|marca|termina)\s+(?:la de\s+)?(.+)',
    ).firstMatch(text);
    if (completeMatch != null) {
      yield* call('list_todos', {});
      final query = completeMatch.group(1)!.replaceAll('como hecha', '').trim();
      final todo = _tools.list().where(
        (t) => !t.done && t.title.toLowerCase().contains(query),
      );
      if (todo.isEmpty) {
        yield AgentText(
          'No encontré una tarea pendiente con "$query". _(modo demo)_',
        );
        return;
      }
      yield* call('complete_todo', {'id': todo.first.id});
      yield AgentText('Hecho ✅ _(modo demo)_');
      return;
    }

    yield* call('list_todos', {});
    final pending = _tools.list().where((t) => !t.done).toList();
    yield AgentText(
      pending.isEmpty
          ? 'No tienes tareas pendientes 🎉 _(modo demo)_'
          : 'Tienes ${pending.length} pendiente(s):\n'
                '${pending.map((t) => '- ${t.title}').join('\n')}\n\n_(modo demo)_',
    );
  }
}
