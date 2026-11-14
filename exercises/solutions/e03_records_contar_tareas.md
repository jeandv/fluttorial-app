# Solución · e03 · Cuenta tareas con un record

> Inténtalo antes de leer esto. Test: [`e03_records_contar_tareas_test.dart`](../e03_records_contar_tareas_test.dart).

## La idea

Un *record* agrupa varios valores sin crear una clase. Con campos con nombre se leen como `stats.pending` y `stats.done`.

## Qué cambiar

Crea el archivo `lib/features/todos/todo_stats.dart`:

```dart
import 'package:mi_primera_app/features/todos/todo.dart';

/// Cuenta las tareas pendientes y las hechas.
({int pending, int done}) countTodos(List<Todo> todos) {
  final done = todos.where((t) => t.done).length;
  return (pending: todos.length - done, done: done);
}
```

## Por qué funciona

- El tipo `({int pending, int done})` declara un record con dos campos con nombre.
- `(pending: ..., done: ...)` crea el valor; dos records con los mismos campos y valores son iguales (`==`), por eso el test puede compararlo directamente.
- En la lista vacía, `done` es 0 y `pending` es `0 - 0 = 0`.
