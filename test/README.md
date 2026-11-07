# 🧪 `test/` — Pruebas automáticas

> Volver al [índice](../README.md) · Guías: [07 · Pruebas y calidad](../docs/07-pruebas-y-calidad.md) · [11 §10 · Pruebas avanzadas](../docs/11-configuraciones-avanzadas.md#10-pruebas-avanzadas)

Aquí van las **pruebas unitarias y de widget**. Se ejecutan en tu Mac **sin simulador**, en segundos. Hay **60 pruebas** y todas pasan.

## Qué hay

| Archivo | Qué prueba | Técnica |
|---|---|---|
| [widget_test.dart](widget_test.dart) | Contador, app completa, navegación entre pestañas, idioma | `testWidgets`, `pumpApp`, `find`, `tap` |
| [features/todos/todos_controller_test.dart](features/todos/todos_controller_test.dart) | Añadir, completar, borrar/deshacer, filtros, persistencia | `ProviderContainer` + overrides |
| [features/posts/posts_repository_test.dart](features/posts/posts_repository_test.dart) | JSON → `Post`, errores 500 y sin conexión, provider con parámetro | `MockClient` de `http` |
| [features/advanced/isolates_test.dart](features/advanced/isolates_test.dart) | Función pura y `compute` | `test` |
| [features/advanced/animations_test.dart](features/advanced/animations_test.dart) | Prueba de regresión: "Tócame" no rompe la animación | `find.ancestor`, `pumpAndSettle`, `takeException` |
| [features/packages/map_data_test.dart](features/packages/map_data_test.dart) | Distancias de rutas y formato de coordenadas (latlong2) | Funciones puras, `closeTo` |
| [features/packages/dio_client_test.dart](features/packages/dio_client_test.dart) | Interceptores de Dio, JSON automático, errores 404 | Adaptador HTTP falso |
| [features/onboarding/onboarding_test.dart](features/onboarding/onboarding_test.dart) | Primer uso: redirect, Saltar, Siguiente/Empezar, persistencia | `pumpApp` con datos iniciales |
| [features/payments/payments_test.dart](features/payments/payments_test.dart) | Marcas, Luhn, formato, caducidad, CVV, pasarela simulada | Funciones puras, `TextInputFormatter` |
| [features/ai/claude_client_test.dart](features/ai/claude_client_test.dart) | Cabeceras y cuerpo de la API, proxy, refusal, 401, streaming SSE | `MockClient` y `MockClient.streaming` |
| [features/ai/todo_agent_test.dart](features/ai/todo_agent_test.dart) | Bucle del agente: tool_use → tool_result → respuesta | Servidor falso con respuestas encadenadas |
| [helpers/test_helpers.dart](helpers/test_helpers.dart) | Utilidades: preferencias en memoria, `pumpApp`, `wrapWithMaterialApp` | — |

## Reglas

- Todo archivo de prueba termina en **`_test.dart`**.
- Imita la estructura de `lib/`: `lib/features/todos/…` → `test/features/todos/…`.
- Patrón de cada prueba: **Preparar → Actuar → Comprobar**.
- Nada de internet ni disco real: se inyectan versiones falsas (overrides).

## Comandos

```bash
flutter test                              # todas
flutter test test/widget_test.dart        # un archivo
flutter test --name "persistencia"        # por nombre
flutter test --coverage                   # con cobertura → coverage/lcov.info
flutter test integration_test -d <id>     # integración (carpeta integration_test/, necesita simulador)
```

En GitHub se ejecutan solas en cada push: [.github/workflows/flutter-ci.yml](../.github/workflows/flutter-ci.yml).
