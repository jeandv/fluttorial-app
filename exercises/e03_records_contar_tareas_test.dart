// ============================================================================
// exercises/e03_records_contar_tareas_test.dart — RETO: RECORDS DE DART
// ============================================================================
//
// ENUNCIADO
//   Crea `countTodos(List<Todo> todos)` en
//   lib/features/todos/todo_stats.dart. Devuelve un RECORD con campos con
//   nombre `pending` y `done`.
//
// ARCHIVO QUE DEBES CREAR
//   lib/features/todos/todo_stats.dart
//
// PISTA
//   El tipo de retorno es `({int pending, int done})`. Cuenta con
//   `where(...).length` y devuelve `(pending: ..., done: ...)`.
//
// CÓMO EJECUTARLO (empieza en ROJO; tu meta es dejarlo en VERDE)
//   flutter test exercises/e03_records_contar_tareas_test.dart
//   Al inicio verás un error de compilación como "Target of URI doesn't
//   exist" o "Method not found": es un rojo válido, porque el archivo y la
//   función aún no existen.
//
// SECCIÓN DE LA GUÍA
//   docs/05-dart-esencial.md (sección de records)
//
// ¿Atascado? Intenta antes de abrir exercises/solutions/e03_records_contar_tareas.md
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/todos/todo.dart';
import 'package:mi_primera_app/features/todos/todo_stats.dart';

void main() {
  Todo todo(String id, {bool done = false}) =>
      Todo(id: id, title: 'Tarea $id', done: done, createdAt: DateTime(2026));

  test('una lista vacía devuelve 0 pendientes y 0 hechas', () {
    final stats = countTodos(const []);

    expect(stats.pending, 0);
    expect(stats.done, 0);
  });

  test('cuenta correctamente una lista mezclada', () {
    final stats = countTodos([
      todo('1'),
      todo('2', done: true),
      todo('3'),
      todo('4', done: true),
      todo('5', done: true),
    ]);

    expect(stats.pending, 2);
    expect(stats.done, 3);
  });

  test('es un record con campos con nombre pending y done', () {
    expect(countTodos([todo('1'), todo('2', done: true)]), (
      pending: 1,
      done: 1,
    ));
  });
}
