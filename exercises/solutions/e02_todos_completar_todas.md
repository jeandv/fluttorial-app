# Solución · e02 · Completar todas las tareas

> Inténtalo antes de leer esto. Test: [`e02_todos_completar_todas_test.dart`](../e02_todos_completar_todas_test.dart).

## La idea

Riverpod solo avisa de un cambio cuando `state` recibe un objeto NUEVO. Por eso no se modifican las tareas existentes: se construye una lista nueva con copias (`copyWith`), igual que hace `toggle`, y después se guarda.

## Qué cambiar

En `lib/features/todos/todos_controller.dart`, dentro de `TodosController` (por ejemplo debajo de `clearCompleted`):

```dart
/// Marca todas las tareas como hechas (crea una lista nueva).
void completeAll() {
  state = [for (final t in state) t.copyWith(done: true)];
  _save();
}
```

## Por qué funciona

- `[for (...) ...]` crea una lista distinta: `identical(nueva, anterior)` es `false` y la lista anterior no cambia.
- Con la lista vacía el `for` no itera y el resultado es otra lista vacía.
- `pendingCountProvider` observa `todosProvider`, así que se recalcula solo y pasa a 0.
- `_save()` escribe el JSON en las preferencias; un contenedor nuevo lo lee en `build()`.
