# 13 · Onboarding: la primera experiencia del usuario

> Anterior: [12 · Librerías más usadas](12-librerias-mas-usadas.md) · Volver al [índice](../README.md) · Siguiente: [14 · Pagos](14-pagos.md)

El **onboarding** son las pantallas que ve alguien la primera vez que abre tu app. Su objetivo es que entienda en pocos segundos **qué gana usándola** y que llegue cuanto antes a la parte útil. Una mala primera impresión es la causa más común de desinstalación en el primer día.

> 📱 **En la app:** se muestra solo la primera vez. Para verlo de nuevo: *Ejemplos → Apps reales → Onboarding* o *Ajustes → Ver el onboarding de nuevo*.

---

## 1. Tipos de onboarding

| Tipo | Qué es | Ejemplo | Cuándo |
|---|---|---|---|
| **Presentación (carrusel)** | 3-5 páginas deslizables con el valor de la app | Este proyecto | Apps nuevas o con un concepto que explicar |
| **Personalización** | Preguntas para adaptar la app (intereses, tema, idioma) | Duolingo, Spotify | Cuando la experiencia cambia según el usuario |
| **Permisos en contexto** | Explicar *por qué* antes de pedir un permiso | "Activa notificaciones para recibir recordatorios" | Siempre que pidas un permiso |
| **Tutorial interactivo / coach marks** | Resaltar botones reales sobre la interfaz | Flechas y círculos sobre la UI | Funciones poco evidentes |
| **Registro progresivo** | Dejar usar la app y pedir la cuenta más tarde | "Crea una cuenta para guardar tu progreso" | Reduce el abandono en el registro |

---

## 2. Cómo está hecho en este proyecto

```
Primera apertura
  └─ redirect del router: ¿onboarding visto? NO → /onboarding
        └─ el usuario pulsa "Saltar" o "Empezar"
              └─ OnboardingController.complete()  → guarda true en el teléfono
                    └─ el router se refresca (refreshListenable) → /ejemplos
```

| Pieza | Código |
|---|---|
| Clave guardada (y añadida a la `allowList`) | [PrefsKeys.onboardingDone](../lib/core/storage/preferences.dart#L41 "→ static const onboardingDone") |
| Estado "ya lo vio" (Riverpod + persistencia) | [OnboardingController](../lib/features/onboarding/onboarding_controller.dart#L23 "→ class OnboardingController") |
| Marcar como visto | [complete()](../lib/features/onboarding/onboarding_controller.dart#L31 "→ Future<void> complete") |
| Volver a mostrarlo | [reset()](../lib/features/onboarding/onboarding_controller.dart#L37 "→ Future<void> reset") · [botón en Ajustes](../lib/features/settings/settings_screen.dart#L101 "→ Ver el onboarding de nuevo") |
| Redirección de primer uso | [redirect](../lib/core/router/app_router.dart#L104 "→ if (!onboardingDone && location != AppRoutes.onboarding)") |
| El router escucha VARIOS estados (`Listenable.merge`) | [refreshListenable](../lib/core/router/app_router.dart#L95 "→ refreshListenable: Listenable.merge") |
| Ruta a pantalla completa y modo demo (`?demo=1`) | [ruta /onboarding](../lib/core/router/app_router.dart#L287 "→ path: AppRoutes.onboarding") |
| Datos de las páginas (separados de la UI) | [onboardingPages](../lib/features/onboarding/onboarding_screen.dart#L52 "→ const onboardingPages") |
| `PageView` + `PageController` | [PageView.builder](../lib/features/onboarding/onboarding_screen.dart#L154 "→ PageView.builder(") |
| Indicador de puntos (`smooth_page_indicator`) | [SmoothPageIndicator](../lib/features/onboarding/onboarding_screen.dart#L175 "→ SmoothPageIndicator(") |
| Botón "Saltar" que desaparece en la última página | [AnimatedOpacity](../lib/features/onboarding/onboarding_screen.dart#L145 "→ opacity: _isLast ? 0 : 1") |
| Efecto parallax con `AnimatedBuilder` | [_PageContent](../lib/features/onboarding/onboarding_screen.dart#L238 "→ final position =") |
| Fondo que cambia de color según la página | [AnimatedContainer](../lib/features/onboarding/onboarding_screen.dart#L129 "→ return AnimatedContainer(") |
| Personalización (tema) en la última página | [_ThemePicker](../lib/features/onboarding/onboarding_screen.dart#L287 "→ class _ThemePicker") |
| Tests del flujo completo | [onboarding_test.dart](../test/features/onboarding/onboarding_test.dart) |

### Por qué un *redirect* y no "comprobar en `main()`"
Si decides la primera pantalla en `main()`, solo funciona al arrancar. Con un `redirect` del router + un provider, la regla se aplica **siempre**: aunque llegue un *deep link* a `/ejemplos/mapas`, si el usuario no ha visto el onboarding, se le lleva primero allí. Además, al terminar no hace falta navegar a mano: el router se refresca solo.

### Truco de los tests
Como el onboarding sale la primera vez, todos los tests de la app arrancarían en él. Por eso el [helper de tests](../test/helpers/test_helpers.dart#L49 "→ PrefsKeys.onboardingDone: true") lo marca como visto por defecto, y los tests del onboarding lo ponen a `false`.

---

## 3. Buenas prácticas

- **3 a 5 pantallas como máximo.** Cada pantalla extra hace que abandone más gente.
- **Siempre un botón "Saltar".** Los usuarios que vuelven a instalar la app no quieren verlo otra vez.
- **Beneficios, no funciones:** "Aprende con ejemplos vivos" en vez de "Tiene 22 pantallas".
- **Un mensaje por pantalla**, con un titular corto y una frase.
- **Permisos en contexto:** pide la ubicación cuando el usuario abre el mapa, no en el onboarding. Si lo haces en el onboarding, añade antes una pantalla que explique *por qué* (si el usuario dice que no al diálogo del sistema, en iOS no puedes volver a pedirlo).
- **Indica el progreso** (los puntos) y deja ir hacia atrás deslizando.
- **Mide:** registra con analítica en qué página abandonan (`firebase_analytics`).
- **Que se pueda volver a ver** desde Ajustes o Ayuda.
- **Accesible:** textos con buen contraste y que se adapten al tamaño de letra del sistema.

---

## 4. Librerías útiles

| Paquete | Descargas/30 días* | Para qué | En este proyecto |
|---|---:|---|---|
| [`smooth_page_indicator`](https://pub.dev/packages/smooth_page_indicator) | 617 K | Indicadores de página animados (puntos, gusano, escala…) | ✅ |
| [`introduction_screen`](https://pub.dev/packages/introduction_screen) | 65 K | Onboarding completo listo para usar (menos control) | — |
| [`showcaseview`](https://pub.dev/packages/showcaseview) | 269 K | *Coach marks*: resaltar widgets reales con un mensaje | — |
| [`tutorial_coach_mark`](https://pub.dev/packages/tutorial_coach_mark) | 215 K | Tutorial interactivo sobre la interfaz | — |
| [`lottie`](https://pub.dev/packages/lottie) | 2,3 M | Animaciones de diseñadores para las ilustraciones | — |

\* pub.dev, consultado el 7/11/2026.

**Consejo:** hacerlo a mano (como aquí) con `PageView` + un indicador da control total del diseño; `introduction_screen` es más rápido si te vale su estilo.

---

## 5. Ejercicios

1. Añade una página que pida el nombre del usuario y salúdalo con `l10n.greeting(nombre)` en el catálogo.
2. Añade una página "Activa las notificaciones" con un botón que pida el permiso (`permission_handler`).
3. Cambia el efecto del indicador por `WormEffect` o `JumpingDotsEffect`.
4. Sustituye los iconos por animaciones Lottie.
