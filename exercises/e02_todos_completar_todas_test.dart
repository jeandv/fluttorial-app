// ============================================================================
// exercises/e02_todos_completar_todas_test.dart — RETO: COMPLETAR TODAS
// ============================================================================
//
// ENUNCIADO
//   Añade `completeAll()` a `TodosController`: marca todas las tareas como
//   hechas SIN mutar el estado anterior y persiste el resultado, como hacen
//   `toggle` y `clearCompleted`.
//
// ARCHIVO QUE DEBES EDITAR
//   lib/features/todos/todos_controller.dart
//
// PISTA
//   Crea una lista NUEVA con un `for` dentro de corchetes y `copyWith`
//   (mira `toggle`), asígnala a `state` y llama a `_save()`.
//
// CÓMO EJECUTARLO (empieza en ROJO; tu meta es dejarlo en VERDE)
//   flutter test exercises/e02_todos_completar_todas_test.dart
//   Al inicio verás un error de compilación como "The method 'completeAll'
//   isn't defined": es un rojo válido, porque el método aún no existe.
//
// SECCIÓN DE LA GUÍA
//   docs/11-configuraciones-avanzadas.md (sección de Riverpod)
//
// ¿Atascado? Intenta antes de abrir exercises/solutions/e02_todos_completar_todas.md
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/features/todos/todo.dart';
import 'package:mi_primera_app/features/todos/todos_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/test_helpers.dart';

void main() {
  late SharedPreferencesWithCache prefs;
  late ProviderContainer container;

  ProviderContainer createContainer() {
    final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    prefs = await createTestPreferences();
    container = createContainer();
  });

  TodosController controller() => container.read(todosProvider.notifier);
  List<Todo> todos() => container.read(todosProvider);

  test('marca todas las tareas como hechas', () {
    controller()
      ..add('A')
      ..add('B')
      ..add('C');
    controller().toggle(todos().first.id); // una ya estaba hecha

    controller().completeAll();

    expect(todos(), hasLength(3));
    expect(todos().every((t) => t.done), isTrue);
    expect(container.read(pendingCountProvider), 0);
  });

  test('con la lista vacía no hace nada (sigue vacía)', () {
    controller().completeAll();

    expect(todos(), isEmpty);
    expect(container.read(pendingCountProvider), 0);
  });

  test('no muta la lista anterior: el estado es una lista nueva', () {
    controller()
      ..add('A')
      ..add('B');
    final before = todos();

    controller().completeAll();

    expect(identical(todos(), before), isFalse);
    // La lista vieja conserva sus valores originales (nadie la mutó).
    expect(before.any((t) => t.done), isFalse);
  });

  test('el resultado se persiste (un contenedor nuevo lo recupera)', () {
    controller()
      ..add('A')
      ..add('B');

    controller().completeAll();

    final restarted = createContainer();
    expect(restarted.read(todosProvider).every((t) => t.done), isTrue);
    expect(restarted.read(pendingCountProvider), 0);
  });
}
