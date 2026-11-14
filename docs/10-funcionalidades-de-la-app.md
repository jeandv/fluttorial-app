# 10 · Funcionalidades de la app (catálogo de ejemplos)

> Anterior: [09 · Solución de problemas](09-solucion-de-problemas.md) · Volver al [índice](../README.md) · Siguiente: [11 · Configuraciones avanzadas](11-configuraciones-avanzadas.md)

> 🎯 **Aprenderás:** a recorrer el catálogo de la app, a localizar el código real de cada concepto y a añadir tu propia demo.
> 📋 **Necesitas antes:** [06 · Construir la app](06-construir-la-app.md) y [16 · Cómo piensa Flutter](16-como-piensa-flutter.md).
> ⏱️ **Tiempo:** ~25 min de lectura + ~20 min practicando

La app es un **catálogo interactivo**: cada pantalla enseña una funcionalidad real, **funcionando**, con su código comentado línea por línea. Todos los enlaces de este documento abren el archivo (y, cuando se indica, la línea exacta).

> 💡 Dentro de la app, el botón **ⓘ** de cada demo explica qué enseña y en qué archivo está su código.

---

## 1. Mapa de la app

```
┌──────────────────────── HomeShell (barra inferior) ────────────────────────┐
│  🎓 Ejemplos                  ✅ Tareas                ⚙️ Ajustes            │
│  /ejemplos                     /tareas                  /ajustes            │
│   ├─ BÁSICO                    App completa:            Tema claro/oscuro   │
│   │   contador, layout,        Riverpod + guardado      Idioma es/en        │
│   │   widgets, listas          en el teléfono           Modo y entorno      │
│   ├─ INTERMEDIO                                                             │
│   │   formularios, navegación,                                              │
│   │   asincronía, API REST, idiomas                                         │
│   ├─ AVANZADO                                                               │
│   │   animaciones, responsive, código nativo, isolates                      │
│   ├─ APPS REALES                                                            │
│   │   onboarding, pago, suscripción, estudio IA, agente IA                  │
│   └─ LIBRERÍAS                                                              │
│       mapas, Dio, imágenes en caché, enlaces y compartir                    │
└────────────────────────────────────────────────────────────────────────────┘
   /login, /privado y /onboarding → pantalla completa (fuera de las pestañas)
```

| Pieza | Archivo |
|---|---|
| Arranque | [lib/main.dart](../lib/main.dart#L41 "→ Future<void> main") |
| Widget raíz (tema, idioma, router) | [lib/app.dart](../lib/app.dart#L38 "→ MaterialApp.router") |
| Todas las rutas | [lib/core/router/app_router.dart](../lib/core/router/app_router.dart#L70 "→ final routerProvider") |
| Constantes de rutas | [lib/core/router/routes.dart](../lib/core/router/routes.dart) |
| Barra de pestañas | [lib/features/shell/home_shell.dart](../lib/features/shell/home_shell.dart) |
| Lista de demos (datos) | [lib/features/catalog/demo_catalog.dart](../lib/features/catalog/demo_catalog.dart#L44 "→ const demos") |
| Pantalla del catálogo | [lib/features/catalog/catalog_screen.dart](../lib/features/catalog/catalog_screen.dart) |
| Plantilla de cada demo (botón ⓘ) | [lib/core/widgets/demo_scaffold.dart](../lib/core/widgets/demo_scaffold.dart) |

---

## 2. 🟢 Nivel básico

### 2.1 Contador — `setState` y ciclo de vida
📄 [lib/features/basics/counter_screen.dart](../lib/features/basics/counter_screen.dart) · Ruta `/ejemplos/contador`

| Concepto | Dónde verlo |
|---|---|
| `StatefulWidget` + `State` | [createState](../lib/features/basics/counter_screen.dart#L40 "→ createState()") |
| `initState` (se ejecuta una vez) | [initState](../lib/features/basics/counter_screen.dart#L59 "→ void initState") |
| `dispose` (liberar recursos) | [dispose](../lib/features/basics/counter_screen.dart#L68 "→ void dispose") |
| `setState` (redibujar) | [_increment](../lib/features/basics/counter_screen.dart#L73 "→ void _increment") |
| Animar un número con `AnimatedSwitcher` | [AnimatedSwitcher](../lib/features/basics/counter_screen.dart#L110 "→ AnimatedSwitcher(") |
| Botón desactivado (`onPressed: null`) | [IconButton.filledTonal](../lib/features/basics/counter_screen.dart#L128 "→ IconButton.filledTonal") |

**Cómo funciona:** al pulsar `+`, `_increment` cambia `_count` dentro de `setState`; Flutter vuelve a ejecutar `build()` y la pantalla muestra el nuevo valor. El registro "Ciclo de vida" de la pantalla muestra cada evento.

### 2.2 Layout
📄 [lib/features/basics/layout_screen.dart](../lib/features/basics/layout_screen.dart) · Ruta `/ejemplos/layout`

| Concepto | Dónde verlo |
|---|---|
| `Row` + `MainAxisAlignment` | [Row spaceBetween](../lib/features/basics/layout_screen.dart#L56 "→ MainAxisAlignment.spaceBetween") |
| `Column` + `CrossAxisAlignment.stretch` | [stretch](../lib/features/basics/layout_screen.dart#L76 "→ CrossAxisAlignment.stretch") |
| `Expanded` y `flex` | [Expanded(flex: 2)](../lib/features/basics/layout_screen.dart#L87 "→ flex: 2") |
| `Stack` + `Positioned` | [Stack](../lib/features/basics/layout_screen.dart#L106 "→ child: Stack(") |
| `Wrap` + `Chip` | [Wrap](../lib/features/basics/layout_screen.dart#L128 "→ child: Wrap(") |
| `BoxDecoration` (degradado, sombra) | [BoxDecoration](../lib/features/basics/layout_screen.dart#L154 "→ gradient: LinearGradient") |

**La regla de oro:** las restricciones bajan, los tamaños suben y el padre decide la posición (explicada al inicio del archivo).

### 2.3 Widgets comunes
📄 [lib/features/basics/widgets_screen.dart](../lib/features/basics/widgets_screen.dart) · Ruta `/ejemplos/widgets`

| Concepto | Dónde verlo |
|---|---|
| Estilos de texto del tema y `Text.rich` | [Text.rich](../lib/features/basics/widgets_screen.dart#L134 "→ Text.rich") |
| Botones (Filled, Tonal, Elevated, Outlined, Text, Icon) | [Botones](../lib/features/basics/widgets_screen.dart#L153 "→ title: 'Botones'") |
| `SwitchListTile`, `CheckboxListTile`, `Slider` | [Controles](../lib/features/basics/widgets_screen.dart#L197 "→ SwitchListTile(") |
| `SegmentedButton` | [SegmentedButton](../lib/features/basics/widgets_screen.dart#L228 "→ SegmentedButton<_Size>") |
| `FilterChip` (selección múltiple) | [FilterChip](../lib/features/basics/widgets_screen.dart#L248 "→ FilterChip(") |
| `SnackBar` con acción | [_showSnackBar](../lib/features/basics/widgets_screen.dart#L43 "→ void _showSnackBar") |
| `AlertDialog` que devuelve un resultado | [_showConfirmDialog](../lib/features/basics/widgets_screen.dart#L56 "→ Future<void> _showConfirmDialog") |
| `showModalBottomSheet` | [_showOptionsSheet](../lib/features/basics/widgets_screen.dart#L82 "→ Future<void> _showOptionsSheet") |
| `Card`, `ListTile`, `CircleAvatar`, `Badge` | [Badge.count](../lib/features/basics/widgets_screen.dart#L293 "→ Badge.count") |

### 2.4 Listas y cuadrículas
📄 [lib/features/basics/lists_screen.dart](../lib/features/basics/lists_screen.dart) · Ruta `/ejemplos/listas`

| Concepto | Dónde verlo |
|---|---|
| Pestañas superiores (`DefaultTabController` + `TabBar`) | [DefaultTabController](../lib/features/basics/lists_screen.dart#L29 "→ DefaultTabController(") |
| `ListView.builder` con 1.000 elementos | [_LongList](../lib/features/basics/lists_screen.dart#L58 "→ ListView.builder(") |
| `GridView.builder` adaptable | [MaxCrossAxisExtent](../lib/features/basics/lists_screen.dart#L80 "→ SliverGridDelegateWithMaxCrossAxisExtent") |
| Tirar para recargar (`RefreshIndicator`) | [_reload](../lib/features/basics/lists_screen.dart#L118 "→ Future<void> _reload") |
| Deslizar para borrar (`Dismissible`) | [Dismissible](../lib/features/basics/lists_screen.dart#L134 "→ return Dismissible(") |

---

## 3. 🟠 Nivel intermedio

### 3.1 Formularios
📄 [lib/features/intermediate/forms_screen.dart](../lib/features/intermediate/forms_screen.dart) · Ruta `/ejemplos/formularios`

| Concepto | Dónde verlo |
|---|---|
| `GlobalKey<FormState>` | [_formKey](../lib/features/intermediate/forms_screen.dart#L38 "→ final _formKey") |
| `TextEditingController` y `FocusNode` (+ `dispose`) | [controladores](../lib/features/intermediate/forms_screen.dart#L41 "→ final _nameController") |
| Validadores (`null` = válido) | [_validateEmail](../lib/features/intermediate/forms_screen.dart#L74 "→ String? _validateEmail") |
| Saltar al siguiente campo con el teclado | [onFieldSubmitted](../lib/features/intermediate/forms_screen.dart#L174 "→ _emailFocus.requestFocus()") |
| Contraseña con botón de "ojo" | [obscureText](../lib/features/intermediate/forms_screen.dart#L196 "→ obscureText: _obscurePassword") |
| `DropdownButtonFormField` | [Dropdown](../lib/features/intermediate/forms_screen.dart#L215 "→ DropdownButtonFormField<String>") |
| `FormField` genérico + `showDatePicker` | [_pickDate](../lib/features/intermediate/forms_screen.dart#L90 "→ Future<void> _pickDate") |
| Validar todo y enviar | [_submit](../lib/features/intermediate/forms_screen.dart#L105 "→ void _submit") |

### 3.2 Navegación (go_router)
La teoría está en [06 §4](06-construir-la-app.md#4-navegación-entre-pantallas) y la configuración completa en [11 §1](11-configuraciones-avanzadas.md#1-navegación-con-go_router); aquí solo ves dónde está cada pieza.

📄 [lib/features/intermediate/navigation_screens.dart](../lib/features/intermediate/navigation_screens.dart) · Ruta `/ejemplos/navegacion`

| Concepto | Dónde verlo |
|---|---|
| `context.push` con parámetro de ruta y de consulta | [push detalle](../lib/features/intermediate/navigation_screens.dart#L68 "→ AppRoutes.navigationDetail(42") |
| Leer los parámetros en el router | [detalle/:id](../lib/core/router/app_router.dart#L180 "→ path: 'detalle/:id'") |
| Esperar un resultado (`await push` / `pop(valor)`) | [_pickColor](../lib/features/intermediate/navigation_screens.dart#L41 "→ Future<void> _pickColor") · [pop(name)](../lib/features/intermediate/navigation_screens.dart#L201 "→ context.pop(name)") |
| `context.go` (cambiar de sección) | [go Tareas](../lib/features/intermediate/navigation_screens.dart#L95 "→ context.go(AppRoutes.todos)") |
| `Navigator.push` clásico | [MaterialPageRoute](../lib/features/intermediate/navigation_screens.dart#L107 "→ MaterialPageRoute<void>(") |
| Ruta protegida (`redirect`) | [redirect](../lib/core/router/app_router.dart#L98 "→ redirect: (context, state)") · [auth.dart](../lib/features/auth/auth.dart) |

### 3.3 Asincronía
📄 [lib/features/intermediate/async_screen.dart](../lib/features/intermediate/async_screen.dart) · Ruta `/ejemplos/asincronia`

| Concepto | Dónde verlo |
|---|---|
| `async/await` + `try/catch/finally` + `mounted` | [_load](../lib/features/intermediate/async_screen.dart#L73 "→ Future<void> _load") |
| `FutureBuilder` (y por qué no crear el Future en `build`) | [FutureBuilder](../lib/features/intermediate/async_screen.dart#L159 "→ FutureBuilder<int>(") |
| `StreamBuilder` (reloj) | [StreamBuilder](../lib/features/intermediate/async_screen.dart#L187 "→ StreamBuilder<DateTime>(") |
| `Timer.periodic` + cancelarlo | [_toggleTimer](../lib/features/intermediate/async_screen.dart#L93 "→ void _toggleTimer") |

### 3.4 API REST (http + JSON + Riverpod)
La lección está en [06 §8](06-construir-la-app.md#8-consumir-una-api-http--json) y las buenas prácticas del cliente en [11 §7](11-configuraciones-avanzadas.md#7-red-cliente-http-robusto).

📄 Carpeta [lib/features/posts/](../lib/features/posts/) · Ruta `/ejemplos/posts`

```
ApiClient (http)  →  PostsRepository (JSON → Post)  →  postsProvider (caché + estado)  →  PostsScreen (UI)
```

| Capa | Archivo | Qué enseña |
|---|---|---|
| Cliente HTTP | [api_client.dart](../lib/core/network/api_client.dart#L49 "→ class ApiClient") | URL base, timeout, errores unificados en `ApiException` |
| Modelo | [post.dart](../lib/features/posts/post.dart#L39 "→ factory Post.fromJson") | `fromJson` con *pattern matching*, `==`/`hashCode` |
| Repositorio | [posts_repository.dart](../lib/features/posts/posts_repository.dart#L32 "→ class PostsRepository") | Separar el origen de los datos de la UI |
| Providers | [postsProvider](../lib/features/posts/posts_repository.dart#L56 "→ final postsProvider") · [postProvider (family)](../lib/features/posts/posts_repository.dart#L61 "→ final postProvider") | `FutureProvider`, `.autoDispose`, `.family` |
| Lista | [PostsScreen](../lib/features/posts/posts_screens.dart#L33 "→ class PostsScreen") | `ref.watch`, `AsyncValue.when`, `ref.refresh`, `ref.invalidate` |
| Detalle | [PostDetailScreen](../lib/features/posts/posts_screens.dart#L97 "→ class PostDetailScreen") | Provider con parámetro + animación `Hero` |
| Tests | [posts_repository_test.dart](../test/features/posts/posts_repository_test.dart) | `MockClient`, errores, overrides |

### 3.5 Idiomas (i18n)
Pasos de configuración: [11 §4](11-configuraciones-avanzadas.md#4-internacionalización-i18n-con-gen-l10n).

📄 [lib/features/intermediate/localization_screen.dart](../lib/features/intermediate/localization_screen.dart) · Ruta `/ejemplos/idiomas`

| Concepto | Dónde verlo |
|---|---|
| Textos en español (plantilla) | [lib/l10n/app_es.arb](../lib/l10n/app_es.arb) |
| Textos en inglés | [lib/l10n/app_en.arb](../lib/l10n/app_en.arb) |
| Configuración de `gen-l10n` | [l10n.yaml](../l10n.yaml) |
| Texto con parámetro | [l10n.greeting](../lib/features/intermediate/localization_screen.dart#L82 "→ l10n.greeting(") |
| Plurales | [l10n.todosPending](../lib/features/intermediate/localization_screen.dart#L94 "→ l10n.todosPending(") |
| Fechas, números y monedas con `intl` | [NumberFormat](../lib/features/intermediate/localization_screen.dart#L121 "→ NumberFormat.simpleCurrency") |
| Cambiar idioma en caliente | [setLocale](../lib/core/settings/settings_controller.dart#L73 "→ Future<void> setLocale") |

---

## 4. 🔴 Nivel avanzado

### 4.1 Animaciones
📄 [lib/features/advanced/animations_screen.dart](../lib/features/advanced/animations_screen.dart) · Ruta `/ejemplos/animaciones`

| Tipo | Dónde verlo |
|---|---|
| Implícita: `AnimatedContainer` | [AnimatedContainer](../lib/features/advanced/animations_screen.dart#L103 "→ child: AnimatedContainer(") |
| ⚠️ Lección: no animar hacia `double.infinity` (usar el ancho real de `LayoutBuilder`) | [constraints.maxWidth](../lib/features/advanced/animations_screen.dart#L111 "→ width: _expanded ? constraints.maxWidth") · [prueba de regresión](../test/features/advanced/animations_test.dart#L23 "→ AnimatedContainer se expande y se contrae") |
| Implícita: `AnimatedOpacity` + `AnimatedSlide` | [AnimatedSlide](../lib/features/advanced/animations_screen.dart#L135 "→ AnimatedSlide(") |
| `TweenAnimationBuilder` | [TweenAnimationBuilder](../lib/features/advanced/animations_screen.dart#L152 "→ TweenAnimationBuilder<double>(") |
| Explícita: `AnimationController` + `Tween` + `CurvedAnimation` | [initState](../lib/features/advanced/animations_screen.dart#L48 "→ _controller = AnimationController(") |
| `AnimatedBuilder` (rotación + escala) | [AnimatedBuilder](../lib/features/advanced/animations_screen.dart#L174 "→ AnimatedBuilder(") |
| `Hero` entre pantallas | [_HeroDetail](../lib/features/advanced/animations_screen.dart#L215 "→ class _HeroDetail") |

### 4.2 Diseño adaptable
📄 [lib/features/advanced/responsive_screen.dart](../lib/features/advanced/responsive_screen.dart) · Ruta `/ejemplos/responsive`

| Concepto | Dónde verlo |
|---|---|
| `MediaQuery.sizeOf`, `orientationOf`, `paddingOf`… | [MediaQuery](../lib/features/advanced/responsive_screen.dart#L36 "→ MediaQuery.sizeOf") |
| `LayoutBuilder` + breakpoints | [LayoutBuilder](../lib/features/advanced/responsive_screen.dart#L80 "→ child: LayoutBuilder(") |
| `GridView` dentro de `ListView` | [shrinkWrap](../lib/features/advanced/responsive_screen.dart#L101 "→ shrinkWrap: true") |
| Widgets `.adaptive` (estilo iOS/Android) | [Switch.adaptive](../lib/features/advanced/responsive_screen.dart#L137 "→ Switch.adaptive(") |

### 4.3 Código nativo (MethodChannel)
Tipos de canal y recomendaciones: [11 §8](11-configuraciones-avanzadas.md#8-código-nativo-platform-channels).

📄 Dart: [lib/features/advanced/native_channel.dart](../lib/features/advanced/native_channel.dart) · Ruta `/ejemplos/nativo`

| Lado | Dónde verlo |
|---|---|
| Dart: definir el canal | [MethodChannel](../lib/features/advanced/native_channel.dart#L43 "→ static const _channel") |
| Dart: llamar y recibir un `Map` | [invokeMapMethod](../lib/features/advanced/native_channel.dart#L47 "→ invokeMapMethod") |
| Dart: manejar `PlatformException` / `MissingPluginException` | [_call](../lib/features/advanced/native_channel.dart#L73 "→ Future<void> _call") |
| Android (Kotlin) | [MainActivity.kt → configureFlutterEngine](../android/app/src/main/kotlin/com/jeanrondon/mi_primera_app/MainActivity.kt#L30 "→ override fun configureFlutterEngine") |
| iOS (Swift) | [AppDelegate.swift → setMethodCallHandler](../ios/Runner/AppDelegate.swift#L46 "→ channel.setMethodCallHandler") |

### 4.4 Isolates
📄 [lib/features/advanced/isolates_screen.dart](../lib/features/advanced/isolates_screen.dart) · Ruta `/ejemplos/isolates`

| Concepto | Dónde verlo |
|---|---|
| Función de nivel superior (requisito para isolates) | [countPrimes](../lib/features/advanced/isolates_screen.dart#L35 "→ int countPrimes") |
| Hilo principal vs `compute` | [_run](../lib/features/advanced/isolates_screen.dart#L63 "→ Future<void> _run") |
| Test de la función | [isolates_test.dart](../test/features/advanced/isolates_test.dart) |

---

## 5. 🟣 Apps reales: onboarding, pagos e IA

Funcionalidades que casi toda app publicada necesita. Cada una tiene su guía completa, que verás más adelante en la ruta (13, 14 y 15); por ahora basta con abrir las demos.

| Demo | Ruta | Qué enseña | Código | Guía |
|---|---|---|---|---|
| Onboarding | `/onboarding` | Primer uso con redirect del router, `PageView`, indicador, parallax, personalización | [onboarding_screen.dart](../lib/features/onboarding/onboarding_screen.dart#L85 "→ class OnboardingScreen") | [docs/13](13-onboarding.md) |
| Pago (checkout) | `/ejemplos/pagos` | Carrito, tarjeta visual, validación Luhn, Apple/Google Pay, recibo | [checkout_screen.dart](../lib/features/payments/checkout_screen.dart#L48 "→ class CheckoutScreen") | [docs/14](14-pagos.md) |
| Suscripción | `/ejemplos/suscripcion` | Paywall: planes, prueba gratis, restaurar compras | [paywall_screen.dart](../lib/features/payments/paywall_screen.dart#L76 "→ class PaywallScreen") | [docs/14](14-pagos.md#4-demo-suscripciones-paywall) |
| Estudio IA | `/ejemplos/ia` | Claude: consejos en streaming, documentos Markdown, SVG | [ai_studio_screen.dart](../lib/features/ai/ai_studio_screen.dart#L32 "→ class AiStudioScreen") | [docs/15](15-ia-y-agentes.md) |
| Agente IA | `/ejemplos/agente` | Bucle de herramientas sobre tus tareas reales | [todo_agent.dart](../lib/features/ai/todo_agent.dart#L193 "→ class ClaudeTodoAgent") | [docs/15 §5](15-ia-y-agentes.md#5-agentes) |

---

## 6. 🔷 Librerías populares

Demos de las librerías más descargadas y demandadas. La investigación completa (métricas de pub.dev, demanda laboral y comparativas) está en [12 · Librerías más usadas](12-librerias-mas-usadas.md), un documento de consulta que no hace falta leer ahora.

| Demo | Ruta | Qué enseña | Código |
|---|---|---|---|
| Mapas | `/ejemplos/mapas` | flutter_map + OpenStreetMap, marcadores, ruta, círculo, tu ubicación con geolocator | [map_screen.dart](../lib/features/packages/maps/map_screen.dart#L49 "→ class MapScreen") · [map_data.dart](../lib/features/packages/maps/map_data.dart#L117 "→ class LocationService") |
| Dio | `/ejemplos/dio` | Interceptores, GET/POST, errores tipados, cancelar peticiones | [dio_client.dart](../lib/features/packages/dio/dio_client.dart#L71 "→ Dio createDio") · [dio_demo_screen.dart](../lib/features/packages/dio/dio_demo_screen.dart#L18 "→ class DioDemoScreen") |
| Imágenes en caché | `/ejemplos/imagenes` | cached_network_image, placeholder shimmer, imagen rota, vaciar caché | [images_screen.dart](../lib/features/packages/images_screen.dart#L31 "→ class ImagesScreen") |
| Enlaces y compartir | `/ejemplos/enlaces` | url_launcher (web, teléfono, email, SMS, mapas) y share_plus | [links_share_screen.dart](../lib/features/packages/links_share_screen.dart#L32 "→ class LinksShareScreen") |

---

## 7. Pestañas de la app

### ✅ Tareas: una mini-app completa con Riverpod
Lección de estado: [06 §5](06-construir-la-app.md#5-gestión-de-estado) · referencia de providers: [11 §2](11-configuraciones-avanzadas.md#2-gestión-de-estado-con-riverpod-3).

📄 Carpeta [lib/features/todos/](../lib/features/todos/) · Ruta `/tareas`

| Pieza | Dónde verlo |
|---|---|
| Modelo inmutable + JSON | [todo.dart](../lib/features/todos/todo.dart#L16 "→ class Todo") |
| `Notifier` con estado inicial cargado del disco | [build()](../lib/features/todos/todos_controller.dart#L36 "→ List<Todo> build") |
| Guardar como JSON | [_save](../lib/features/todos/todos_controller.dart#L51 "→ Future<void> _save") |
| No mutar el estado (crear listas nuevas) | [add](../lib/features/todos/todos_controller.dart#L58 "→ void add") |
| Borrar y deshacer (devolver un *record*) | [remove](../lib/features/todos/todos_controller.dart#L81 "→ (Todo, int)? remove") |
| Providers derivados | [filteredTodosProvider](../lib/features/todos/todos_controller.dart#L122 "→ final filteredTodosProvider") · [pendingCountProvider](../lib/features/todos/todos_controller.dart#L132 "→ final pendingCountProvider") |
| `ref.watch` vs `ref.read` | [watch en build](../lib/features/todos/todos_screen.dart#L69 "→ final todos = ref.watch") · [read en un callback](../lib/features/todos/todos_screen.dart#L43 "→ ref.read(todosProvider.notifier).add") |
| `.select` (redibujar menos) | [select](../lib/features/todos/todos_screen.dart#L73 "→ todosProvider.select") |
| `ValueListenableBuilder` | [botón Añadir](../lib/features/todos/todos_screen.dart#L110 "→ ValueListenableBuilder(") |
| SnackBar "Deshacer" | [_remove](../lib/features/todos/todos_screen.dart#L47 "→ void _remove") |
| Tests de la lógica | [todos_controller_test.dart](../test/features/todos/todos_controller_test.dart) |

### ⚙️ Ajustes
📄 [lib/features/settings/settings_screen.dart](../lib/features/settings/settings_screen.dart) · Ruta `/ajustes`

| Pieza | Dónde verlo |
|---|---|
| Tema claro/oscuro/sistema | [SegmentedButton<ThemeMode>](../lib/features/settings/settings_screen.dart#L48 "→ SegmentedButton<ThemeMode>") |
| Idioma con `RadioGroup` | [RadioGroup](../lib/features/settings/settings_screen.dart#L77 "→ RadioGroup<String>(") |
| Modo de compilación (`kReleaseMode`…) | [buildMode](../lib/features/settings/settings_screen.dart#L32 "→ final buildMode") |
| Variables `--dart-define` | [Env](../lib/core/config/env.dart#L33 "→ abstract final class Env") |
| Controlador de ajustes (persistido) | [SettingsController](../lib/core/settings/settings_controller.dart#L47 "→ class SettingsController") |

---

## 8. Cómo añadir tu propia demo (ejercicio)

1. Crea `lib/features/<nivel>/mi_demo_screen.dart` usando [DemoScaffold](../lib/core/widgets/demo_scaffold.dart#L22 "→ class DemoScaffold") como base.
2. Añade la constante de ruta en [routes.dart](../lib/core/router/routes.dart).
3. Registra la ruta como hija de `/ejemplos` en [app_router.dart](../lib/core/router/app_router.dart#L134 "→ routes: [") .
4. Añade un `Demo(...)` a la lista [demos](../lib/features/catalog/demo_catalog.dart#L44 "→ const demos").
5. Hot restart (`R`) y aparecerá en el catálogo.

**🏋️ Reto: tu propia demo.** Sigue los 5 pasos anteriores para añadir una demo titulada `Mi demo` al catálogo (nivel básico) que se abra al tocarla y use `DemoScaffold`.

- ✅ **Cómo saber que lo lograste:** `flutter test exercises/e04_mi_demo_test.dart` pasa a verde, y ves `Mi demo` en el catálogo y se abre al tocarla.
- 💡 **Pista:** copia la estructura de una demo existente, por ejemplo [counter_screen.dart](../lib/features/basics/counter_screen.dart), y fíjate en cómo declara su entrada [demo_catalog.dart](../lib/features/catalog/demo_catalog.dart#L44 "→ const demos").
- 🔑 **Solución (inténtalo antes):** [e04_mi_demo](../exercises/solutions/e04_mi_demo.md)

---

## ✅ Comprueba que entendiste

1. ¿Qué dos archivos tocas, además de la pantalla nueva, para que una demo aparezca en el catálogo y se abra?
   <details><summary>Respuesta</summary>

   La lista de demos ([demo_catalog.dart](../lib/features/catalog/demo_catalog.dart)) y el router, donde registras la ruta como hija de `/ejemplos` (paso 3), además de la constante en `routes.dart`.

   </details>
2. ¿Por qué `/login` y `/onboarding` se ven a pantalla completa, sin la barra inferior?
   <details><summary>Respuesta</summary>

   Son rutas fuera de las pestañas: se registran con `parentNavigatorKey`, así que se abren sobre todo el shell. Ver [11 §1](11-configuraciones-avanzadas.md#1-navegación-con-go_router).

   </details>
3. En el contador, ¿qué pasa si cambias `_count` sin llamar a `setState`?
   <details><summary>Respuesta</summary>

   El valor cambia en memoria, pero Flutter no vuelve a ejecutar `build()`, así que la pantalla no muestra el nuevo número. `setState` es lo que pide el redibujado.

   </details>
4. ¿Por qué la demo de animaciones usa `constraints.maxWidth` en lugar de animar hacia `double.infinity`?
   <details><summary>Respuesta</summary>

   Un ancho infinito no se puede interpolar con uno finito, por lo que hay que usar el ancho real que da `LayoutBuilder`. La [prueba de regresión](../test/features/advanced/animations_test.dart#L23 "→ AnimatedContainer se expande y se contrae") lo protege.

   </details>
5. En la pestaña Tareas, ¿cuándo usas `ref.watch` y cuándo `ref.read`?
   <details><summary>Respuesta</summary>

   `ref.watch` dentro de `build` (redibuja al cambiar); `ref.read` en callbacks como el del botón Añadir (lee una vez). Ver [watch](../lib/features/todos/todos_screen.dart#L69 "→ final todos = ref.watch") y [read](../lib/features/todos/todos_screen.dart#L43 "→ ref.read(todosProvider.notifier).add").

   </details>

## ➡️ Siguiente paso

Continúa con **[07 · Pruebas y calidad](07-pruebas-y-calidad.md)**: ya conoces el código de la app, ahora aprende a comprobar que funciona. Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).
