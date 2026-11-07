// ============================================================================
// lib/features/todos/todos_controller.dart — LÓGICA DE TAREAS (Riverpod)
// ============================================================================
//
// QUÉ HACE
//   Gestiona la lista de tareas: añadir, completar, borrar, deshacer, limpiar
//   completadas. Cada cambio se GUARDA en el teléfono (shared_preferences
//   como JSON), así las tareas siguen ahí al cerrar y abrir la app.
//
// PROVIDERS (estado global, accesible desde cualquier pantalla)
//   - todosProvider          → List<Todo>: la lista completa (Notifier).
//   - todoFilterProvider     → TodoFilter: el filtro seleccionado (Notifier).
//   - filteredTodosProvider  → List<Todo>: DERIVADO de los dos anteriores.
//   - pendingCountProvider   → int: DERIVADO, nº de tareas pendientes.
//
//   Los providers "derivados" se recalculan solos cuando cambian los providers
//   que observan (ref.watch). No hay que sincronizar nada a mano.
//
// POR QUÉ LA LÓGICA NO ESTÁ EN LA PANTALLA
//   - Se puede probar sin interfaz (test/features/todos/todos_controller_test.dart).
//   - Varias pantallas pueden usar los mismos datos (el contador de pendientes
//     también podría mostrarse en otra pestaña).
//
// 📚 Guía: docs/10-funcionalidades-de-la-app.md · docs/11 (sección 2)
// ============================================================================

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/storage/preferences.dart';
import 'package:mi_primera_app/features/todos/todo.dart';

class TodosController extends Notifier<List<Todo>> {
  /// Estado inicial: se lee la lista guardada (o vacía si no hay nada).
  @override
  List<Todo> build() {
    final raw = ref.read(sharedPreferencesProvider).getString(PrefsKeys.todos);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<Object?>;
      return [
        for (final item in list) Todo.fromJson(item! as Map<String, Object?>),
      ];
    } on Object {
      // Datos corruptos (p. ej. cambiaste el formato): empezamos de cero.
      return const [];
    }
  }

  /// Guarda la lista actual como texto JSON.
  Future<void> _save() => ref
      .read(sharedPreferencesProvider)
      .setString(
        PrefsKeys.todos,
        jsonEncode([for (final t in state) t.toJson()]),
      );

  void add(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: trimmed,
      createdAt: DateTime.now(),
    );
    // ⚠️ NO hagas state.add(todo): mutar la lista no avisa a Riverpod.
    // Se crea una lista NUEVA con el spread operator (...).
    state = [todo, ...state];
    _save();
  }

  void toggle(String id) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(done: !t.done) else t,
    ];
    _save();
  }

  /// Elimina y devuelve la tarea + su posición (para poder deshacer).
  (Todo, int)? remove(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final removed = state[index];
    state = [...state]..removeAt(index);
    _save();
    return (removed, index);
  }

  /// Vuelve a insertar una tarea eliminada en su posición original.
  void restore(Todo todo, int index) {
    final list = [...state];
    list.insert(index.clamp(0, list.length), todo);
    state = list;
    _save();
  }

  void clearCompleted() {
    state = state.where((t) => !t.done).toList();
    _save();
  }
}

final todosProvider = NotifierProvider<TodosController, List<Todo>>(
  TodosController.new,
);

/// Filtro seleccionado (no se persiste).
class TodoFilterController extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void set(TodoFilter filter) => state = filter;
}

final todoFilterProvider = NotifierProvider<TodoFilterController, TodoFilter>(
  TodoFilterController.new,
);

/// Provider DERIVADO: lista filtrada. Se recalcula cuando cambian las tareas
/// o el filtro.
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todosProvider);
  return switch (ref.watch(todoFilterProvider)) {
    TodoFilter.all => todos,
    TodoFilter.pending => todos.where((t) => !t.done).toList(),
    TodoFilter.done => todos.where((t) => t.done).toList(),
  };
});

/// Provider DERIVADO: número de tareas pendientes.
final pendingCountProvider = Provider<int>(
  (ref) => ref.watch(todosProvider).where((t) => !t.done).length,
);
