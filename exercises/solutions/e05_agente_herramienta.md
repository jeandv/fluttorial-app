# Solución · e05 · Una herramienta nueva para el agente

> Inténtalo antes de leer esto. Test: [`e05_agente_herramienta_test.dart`](../e05_agente_herramienta_test.dart).

## La idea

Una herramienta del agente son tres cosas: su **definición** (JSON Schema que ve el modelo), el **código** que la ejecuta en `execute` y la **conexión** con la app real. `TodoToolbox` no sabe borrar tareas, así que recibe un callback nuevo y opcional.

## Qué cambiar

En `lib/features/ai/todo_agent.dart`:

**1. Callback en el constructor y como campo:**

```dart
const TodoToolbox({
  required this.list,
  required this.add,
  required this.toggle,
  this.clearCompleted,
  this.now,
});

final List<Todo> Function() list;
final void Function(String title) add;
final void Function(String id) toggle;
final void Function()? clearCompleted;
final DateTime Function()? now;
```

**2. Definición**, al final de `definitions` (tras `get_today`):

```dart
{
  'name': 'clear_completed',
  'description':
      'Borra todas las tareas ya completadas y devuelve cuántas borró.',
  'strict': true,
  'input_schema': {
    'type': 'object',
    'properties': <String, Object?>{},
    'required': <String>[],
    'additionalProperties': false,
  },
},
```

**3. Caso en `execute`**, antes del `default`:

```dart
case 'clear_completed':
  final clear = clearCompleted;
  if (clear == null) return ('Herramienta no disponible', true);
  final count = list().where((t) => t.done).length;
  clear();
  return ('Se borraron $count tareas completadas', false);
```

En `lib/features/ai/agent_screen.dart`, conecta el callback en `todoAgentProvider`:

```dart
final tools = TodoToolbox(
  list: () => ref.read(todosProvider),
  add: (title) => ref.read(todosProvider.notifier).add(title),
  toggle: (id) => ref.read(todosProvider.notifier).toggle(id),
  clearCompleted: () => ref.read(todosProvider.notifier).clearCompleted(),
);
```

## Por qué funciona

- El conteo se hace ANTES de borrar: después `list()` ya no contiene las completadas.
- El parámetro es opcional, así que el código existente sigue compilando.
- Al añadir una herramienta, `definitions` pasa de 4 a 5 elementos: el test existente `test/features/ai/todo_agent_test.dart` comprueba `.length` igual a 4; actualízalo a 5 como parte del refactor.
