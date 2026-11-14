# Solución · e01 · Límite en el contador

> Inténtalo antes de leer esto. Test: [`e01_contador_limite_test.dart`](../e01_contador_limite_test.dart).

## La idea

En Flutter un botón se desactiva pasándole `onPressed: null`. El botón "−" ya lo hace cuando `_count == 0`; el botón "+" solo necesita la misma condición con el límite superior.

## Qué cambiar

En `lib/features/basics/counter_screen.dart`, dentro de `build()`, el botón "+" (`IconButton.filled`):

```dart
IconButton.filled(
  tooltip: 'Incrementar',
  onPressed: _count >= 20 ? null : _increment, // null = desactivado
  icon: const Icon(Icons.add),
),
```

## Por qué funciona

- `_count` cambia dentro de `setState`, así que `build()` se vuelve a ejecutar y reevalúa la condición.
- Con 19, `_count >= 20` es falso: el botón sigue activo. Con 20 es verdadero: `onPressed` es `null` y Flutter lo pinta desactivado e ignora los toques.
- "−" no se toca: desde 20 sigue restando.

## Refactor opcional

Saca el 20 a una constante junto a `_step`: `static const _max = 20;` y usa `_count >= _max`.
