// ============================================================================
// test/features/todos/todos_controller_test.dart — PRUEBAS UNITARIAS (Riverpod)
// ============================================================================
//
// QUÉ ENSEÑA
//   Probar la LÓGICA sin dibujar ninguna pantalla:
//   - ProviderContainer: un "ProviderScope" para tests (sin widgets).
//   - overrides: inyectar un almacenamiento en memoria.
//   - container.read(provider) / container.read(provider.notifier).
//   - Comprobar que los datos se PERSISTEN creando un segundo contenedor.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/features/todos/todo.dart';
import 'package:mi_primera_app/features/todos/todos_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferencesWithCache prefs;
  late ProviderContainer container;

  ProviderContainer createContainer() {
    final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    // addTearDown: se ejecuta al terminar cada test (libera el contenedor).
    addTearDown(c.dispose);
    return c;
  }

  // setUp: se ejecuta ANTES de cada test → cada uno empieza desde cero.
  setUp(() async {
    prefs = await createTestPreferences();
    container = createContainer();
  });

  TodosController controller() => container.read(todosProvider.notifier);
  List<Todo> todos() => container.read(todosProvider);

  test('empieza vacía', () {
    expect(todos(), isEmpty);
    expect(container.read(pendingCountProvider), 0);
  });

  test('add añade al principio e ignora textos vacíos', () {
    controller()
      ..add('Primera')
      ..add('   ') // ignorada
      ..add('Segunda');

    expect(todos().map((t) => t.title), ['Segunda', 'Primera']);
  });

  test('toggle marca y desmarca una tarea', () {
    controller().add('Estudiar Dart');
    final id = todos().single.id;

    controller().toggle(id);
    expect(todos().single.done, isTrue);
    expect(container.read(pendingCountProvider), 0);

    controller().toggle(id);
    expect(todos().single.done, isFalse);
  });

  test('remove + restore deshace el borrado en la misma posición', () {
    controller()
      ..add('C')
      ..add('B')
      ..add('A'); // lista: A, B, C
    final idB = todos()[1].id;

    final removed = controller().remove(idB);
    expect(todos().map((t) => t.title), ['A', 'C']);

    final (todo, index) = removed!;
    controller().restore(todo, index);
    expect(todos().map((t) => t.title), ['A', 'B', 'C']);
  });

  test('filteredTodosProvider filtra por estado', () {
    controller()
      ..add('Pendiente')
      ..add('Hecha');
    controller().toggle(todos().first.id); // "Hecha" (la primera)

    final filter = container.read(todoFilterProvider.notifier);

    filter.set(TodoFilter.done);
    expect(container.read(filteredTodosProvider).single.title, 'Hecha');

    filter.set(TodoFilter.pending);
    expect(container.read(filteredTodosProvider).single.title, 'Pendiente');

    filter.set(TodoFilter.all);
    expect(container.read(filteredTodosProvider), hasLength(2));
  });

  test('las tareas se guardan y se recuperan (persistencia)', () {
    controller().add('Sobrevivo al reinicio');

    // Un contenedor NUEVO simula cerrar y abrir la app: lee del almacenamiento.
    final restarted = createContainer();
    expect(restarted.read(todosProvider).single.title, 'Sobrevivo al reinicio');
  });

  test('Todo.toJson / fromJson son simétricos', () {
    final todo = Todo(
      id: '1',
      title: 'JSON',
      done: true,
      createdAt: DateTime(2026, 11, 7, 10, 30),
    );
    expect(Todo.fromJson(todo.toJson()), todo);
  });
}
