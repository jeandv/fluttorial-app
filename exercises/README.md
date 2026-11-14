# 🏋️ exercises/ — retos con test

Aquí viven los retos de la guía que se comprueban con un test. Cada uno **empieza en rojo**: tu trabajo es editar el código de `lib/` hasta que el test pase a verde.

## ¿Por qué no están en `test/`?

Porque fallan a propósito. Si estuvieran en `test/`, `flutter test` y la CI se pondrían en rojo. Por eso:

- `flutter test` solo ejecuta `test/` y se mantiene verde.
- `analysis_options.yaml` excluye `exercises/**`, así `flutter analyze` no se queja de código que aún no compila (por ejemplo, métodos que todavía no existen).

## Los retos

| Reto | Sección de la guía | Test | Solución |
|---|---|---|---|
| Límite en el contador | [06](../docs/06-construir-la-app.md) | [`e01_contador_limite_test.dart`](e01_contador_limite_test.dart) | [solución](solutions/e01_contador_limite.md) |
| Completar todas las tareas | [11](../docs/11-configuraciones-avanzadas.md) | [`e02_todos_completar_todas_test.dart`](e02_todos_completar_todas_test.dart) | [solución](solutions/e02_todos_completar_todas.md) |
| Cuenta tareas con un record | [05](../docs/05-dart-esencial.md) | [`e03_records_contar_tareas_test.dart`](e03_records_contar_tareas_test.dart) | [solución](solutions/e03_records_contar_tareas.md) |
| Tu propia demo | [10](../docs/10-funcionalidades-de-la-app.md) | [`e04_mi_demo_test.dart`](e04_mi_demo_test.dart) | [solución](solutions/e04_mi_demo.md) |
| Una herramienta nueva para el agente | [15](../docs/15-ia-y-agentes.md) | [`e05_agente_herramienta_test.dart`](e05_agente_herramienta_test.dart) | [solución](solutions/e05_agente_herramienta.md) |
| Indicador con `WormEffect` | [13](../docs/13-onboarding.md) | [`e06_onboarding_indicador_test.dart`](e06_onboarding_indicador_test.dart) | [solución](solutions/e06_onboarding_indicador.md) |

## Cómo trabajar un reto: rojo → verde → refactor

1. **Rojo.** Lee el enunciado en la cabecera del test y ejecútalo. Verlo fallar confirma que el test mide algo. En los retos e02, e03 y e05 el rojo es un error de compilación (la API aún no existe): es normal.
2. **Verde.** Edita solo los archivos que indica la cabecera, con el cambio mínimo que haga pasar el test.
3. **Refactor.** Mejora nombres y estructura sin romper el test. Después ejecuta `flutter test` para comprobar que no rompiste nada de `test/`.

## Cómo ejecutarlos

```bash
flutter test exercises/e01_contador_limite_test.dart   # un reto
flutter test exercises/                                # todos
```

Los retos que ya resolviste quedan en verde; los demás siguen en rojo, y es lo esperado.

> ⚠️ **Inténtalo antes de abrir la solución.** Leerla enseguida se siente productivo pero casi no enseña: lo que se queda es lo que te costó encontrar.
