// ============================================================================
// lib/features/todos/todos_screen.dart — PESTAÑA "TAREAS" (app completa)
// ============================================================================
//
// QUÉ ENSEÑA (todo junto, como en una app real)
//   - ConsumerStatefulWidget: estado local (el TextEditingController) +
//     acceso a Riverpod (`ref`).
//   - ref.watch → leer y redibujar; ref.read → ejecutar acciones (en onTap…).
//   - Persistencia: cierra la app y vuelve a abrirla, las tareas siguen ahí.
//   - Deslizar para borrar + "Deshacer" en un SnackBar.
//   - Filtros con SegmentedButton y providers derivados.
//   - Traducciones con plurales (l10n.todosPending).
//
// REGLA ref.watch vs ref.read
//   - ref.watch(...) DENTRO de build(): "dame el valor y avísame si cambia".
//   - ref.read(...)  en callbacks (onPressed, onChanged…): "dame el valor
//     ahora, una vez". Nunca uses ref.read en build para datos que se muestran.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/features/todos/todo.dart';
import 'package:mi_primera_app/features/todos/todos_controller.dart';
import 'package:mi_primera_app/l10n/app_localizations.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    ref.read(todosProvider.notifier).add(_controller.text);
    _controller.clear();
  }

  void _remove(Todo todo) {
    final l10n = AppLocalizations.of(context);
    final removed = ref.read(todosProvider.notifier).remove(todo.id);
    if (removed == null) return;
    final (item, index) = removed; // desestructurar un record
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.todosDeleted),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () =>
                ref.read(todosProvider.notifier).restore(item, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todos = ref.watch(filteredTodosProvider);
    final filter = ref.watch(todoFilterProvider);
    final pending = ref.watch(pendingCountProvider);
    final hasCompleted = ref.watch(
      todosProvider.select((list) => list.any((t) => t.done)),
    ); // .select: solo redibuja si cambia ESTE valor concreto (optimización)

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabTodos),
        actions: [
          IconButton(
            tooltip: 'Borrar completadas',
            onPressed: hasCompleted
                ? () => ref.read(todosProvider.notifier).clearCompleted()
                : null,
            icon: const Icon(Icons.cleaning_services_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // ------------------------------------------------- Nueva tarea
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.todosHint,
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                // ValueListenableBuilder: redibuja SOLO el botón cuando cambia
                // el texto (el controller es un ValueListenable).
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, _) => FilledButton(
                    onPressed: value.text.trim().isEmpty ? null : _add,
                    child: Text(l10n.todosAdd),
                  ),
                ),
              ],
            ),
          ),
          // ------------------------------------------------------ Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<TodoFilter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: TodoFilter.all, label: Text('Todas')),
                  ButtonSegment(
                    value: TodoFilter.pending,
                    label: Text('Pendientes'),
                  ),
                  ButtonSegment(value: TodoFilter.done, label: Text('Hechas')),
                ],
                selected: {filter},
                onSelectionChanged: (s) =>
                    ref.read(todoFilterProvider.notifier).set(s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              l10n.todosPending(pending),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          // -------------------------------------------------------- Lista
          Expanded(
            child: todos.isEmpty
                ? Center(child: Text(l10n.todosEmpty))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Dismissible(
                        key: ValueKey(todo.id),
                        background: Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete_outline),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _remove(todo),
                        child: CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: todo.done,
                          onChanged: (_) =>
                              ref.read(todosProvider.notifier).toggle(todo.id),
                          title: Text(
                            todo.title,
                            style: todo.done
                                ? const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  )
                                : null,
                          ),
                          subtitle: Text(
                            MaterialLocalizations.of(context)
                                .formatShortDate(todo.createdAt),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
