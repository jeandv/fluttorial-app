// ============================================================================
// exercises/e05_agente_herramienta_test.dart — RETO: UNA HERRAMIENTA NUEVA
// ============================================================================
//
// ENUNCIADO
//   Añade la herramienta `clear_completed` a `TodoToolbox`: borra las tareas
//   completadas y devuelve cuántas borró.
//
// ARCHIVOS QUE DEBES EDITAR
//   - lib/features/ai/todo_agent.dart   (callback, definición y `execute`)
//   - lib/features/ai/agent_screen.dart (conecta el callback con la app real)
//
// DISEÑO QUE ESPERA ESTE TEST
//   `TodoToolbox` recibe un nuevo parámetro con nombre y OPCIONAL:
//   `void Function()? clearCompleted`. La herramienta lo llama una sola vez.
//
// PISTA
//   Cuenta las completadas con `list().where((t) => t.done).length` ANTES
//   de llamar al callback, y devuelve ese número en el texto de salida.
//
// CÓMO EJECUTARLO (empieza en ROJO; tu meta es dejarlo en VERDE)
//   flutter test exercises/e05_agente_herramienta_test.dart
//   Al inicio verás un error de compilación como "No named parameter with
//   the name 'clearCompleted'": es un rojo válido, porque la API aún no
//   existe.
//
// SECCIÓN DE LA GUÍA
//   docs/15-ia-y-agentes.md (herramientas del agente)
//
// ¿Atascado? Intenta antes de abrir exercises/solutions/e05_agente_herramienta.md
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/ai/todo_agent.dart';
import 'package:mi_primera_app/features/todos/todo.dart';

/// Lista de tareas en memoria, como en test/features/ai/todo_agent_test.dart.
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
    clearCompleted: () => items.removeWhere((t) => t.done),
    now: () => DateTime(2026, 11, 7),
  );
}

void main() {
  Todo todo(String id, {bool done = false}) =>
      Todo(id: id, title: 'Tarea $id', done: done, createdAt: DateTime(2026));

  test('clear_completed borra las hechas y dice cuántas borró', () {
    final todos = FakeTodos()
      ..items.addAll([todo('1', done: true), todo('2'), todo('3', done: true)]);

    final (output, isError) = todos.toolbox.execute('clear_completed', {});

    expect(isError, isFalse);
    expect(output, contains('2'));
    expect(todos.items.map((t) => t.id), ['2']);
  });

  test('sin tareas completadas no borra nada y avisa con 0', () {
    final todos = FakeTodos()..items.add(todo('1'));

    final (output, isError) = todos.toolbox.execute('clear_completed', {});

    expect(isError, isFalse);
    expect(output, contains('0'));
    expect(todos.items, hasLength(1));
  });

  test('definitions incluye clear_completed con un esquema válido', () {
    final tool = TodoToolbox.definitions.singleWhere(
      (d) => d['name'] == 'clear_completed',
    );

    expect(tool['description'], isA<String>());
    expect((tool['description']! as String).isNotEmpty, isTrue);
    final schema = tool['input_schema']! as Map<String, Object?>;
    expect(schema['type'], 'object');
    expect(schema['additionalProperties'], isFalse);
    expect(schema['required'], isA<List<Object?>>());
    expect(schema['properties'], isA<Map<String, Object?>>());
  });
}
