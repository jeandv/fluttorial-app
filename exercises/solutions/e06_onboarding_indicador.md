# Solución · e06 · Indicador con WormEffect

> Inténtalo antes de leer esto. Test: [`e06_onboarding_indicador_test.dart`](../e06_onboarding_indicador_test.dart).

## La idea

`SmoothPageIndicator` delega su aspecto en el parámetro `effect`. Cambiar de efecto es cambiar ese objeto; el resto del indicador no se toca.

## Qué cambiar

En `lib/features/onboarding/onboarding_screen.dart`, dentro de `SmoothPageIndicator(...)`:

```dart
effect: WormEffect(
  dotHeight: 10,
  dotWidth: 10,
  activeDotColor: page.color,
  dotColor: page.color.withValues(alpha: 0.3),
),
```

## Por qué funciona

- `WormEffect` vive en el mismo paquete (`smooth_page_indicator`), ya importado en el archivo.
- Acepta los mismos parámetros de tamaño y color que `ExpandingDotsEffect`, así que solo cambia el nombre de la clase.
- El test lee `indicator.effect` del widget y comprueba que es un `WormEffect`.
