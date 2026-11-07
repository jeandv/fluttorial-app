# 🧪 `test/` — Pruebas automáticas

> Volver al [índice](../README.md) · Guía completa: [07 · Pruebas y calidad](../docs/07-pruebas-y-calidad.md)

Aquí van las **pruebas unitarias y de widget**. Se ejecutan en tu Mac **sin simulador**, en segundos.

## Qué hay ahora

| Archivo | Qué prueba |
|---|---|
| [`widget_test.dart`](widget_test.dart) | El contador empieza en 0 y sube a 1 al pulsar `+`. Comentado paso a paso |

## Reglas

- Todo archivo de prueba termina en **`_test.dart`**.
- Imita la estructura de `lib/`: `lib/models/producto.dart` → `test/models/producto_test.dart`.
- Patrón de cada prueba: **Preparar → Actuar → Comprobar**.

## Comandos

```bash
flutter test                              # todas
flutter test test/widget_test.dart        # un archivo
flutter test --name "contador"            # por nombre
flutter test --coverage                   # con cobertura → coverage/lcov.info
flutter test integration_test -d <id>     # integración (carpeta integration_test/, necesita simulador)
```

## Tipos de prueba

| Tipo | Carpeta | Simulador |
|---|---|---|
| Unitaria (`test(...)`) | `test/` | No |
| Widget (`testWidgets(...)`) | `test/` | No |
| Integración | `integration_test/` | Sí |
