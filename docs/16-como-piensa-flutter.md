# 16 · Cómo piensa Flutter (modelos mentales)

> Anterior: [15 · IA y agentes](15-ia-y-agentes.md) · Volver al [índice](../README.md) · Siguiente: [17 · Calidad de producción](17-calidad-de-produccion.md)

> 🎯 **Aprenderás:** a explicar por qué Flutter reconstruye widgets sin que sea caro, cómo las restricciones deciden el tamaño de cada widget y cuándo una `Key` evita bugs de estado.
> 📋 **Necesitas antes:** [06 · Construir la app](06-construir-la-app.md) (widgets, `setState`, navegación y estado básicos).
> ⏱️ **Tiempo:** ~25 min de lectura + ~10 min practicando

---

Hasta aquí aprendiste **qué escribir**. Este documento explica **por qué funciona así**. Con estos 11 modelos mentales los errores raros (`overflow`, estado que "salta" de una fila a otra, pantallas que van lentas) dejan de ser misterios.

> 💡 Cada sección sigue el mismo ritmo: **la respuesta en una frase → un ejemplo mínimo → por qué importa → el error típico**. Si ya dominas una, salta a la siguiente.

---

## 1. Los tres árboles (Widget, Element, RenderObject)

**Respuesta corta:** un widget es una *descripción* barata e inmutable; Flutter mantiene por debajo otros dos árboles que son los que viven y dibujan.

```
 Widget tree            Element tree              RenderObject tree
 (qué quieres)          (qué hay montado)         (medir y pintar)
 ─────────────          ─────────────────         ──────────────────
 Padding(…)      ──►    Element (vive mucho) ──►  RenderPadding
 └─ Text('Hola') ──►    └─ Element           ──►  RenderParagraph
   se recrea en        se REUTILIZA entre         hace layout y pintado
   cada build()        builds                     (es lo caro)
```

- **Widget:** configuración inmutable. Crear miles es barato.
- **Element:** la "instancia viva" de un widget en una posición concreta del árbol. Guarda el `State` de los `StatefulWidget`.
- **RenderObject:** calcula tamaños y pinta. Es lo costoso, por eso Flutter lo conserva.

Cuando `build()` devuelve widgets nuevos, Flutter compara cada uno con el anterior **en la misma posición**: si tienen el mismo tipo y la misma `key`, reutiliza el `Element` y solo le pasa la configuración nueva; si no, lo tira y crea otro.

> 📂 **En este proyecto:** cada pantalla es un subárbol; por ejemplo [CounterScreen](../lib/features/basics/counter_screen.dart#L34 "→ class CounterScreen extends StatefulWidget") es el widget y su `State` vive en el `Element`.

**Por qué importa:** explica por qué reconstruir es barato y por qué el `State` sobrevive a un `build()`.
**Error típico:** creer que `build()` "crea la pantalla desde cero". Solo crea una *descripción* nueva.

---

## 2. `BuildContext`: tu posición en el árbol

**Respuesta corta:** el `context` es el `Element` de tu widget; sirve para **buscar hacia arriba** en el árbol.

```dart
// Sube por los ancestros hasta encontrar un Theme:
final colores = Theme.of(context).colorScheme;
```

`Theme.of`, `Navigator.of`, `MediaQuery.of` o `Localizations.of` hacen lo mismo: recorren los ancestros de ese `context` hasta dar con el widget que buscan.

**Por qué importa:** si el `context` está **por encima** del widget que buscas, no lo encuentra. Un caso clásico es usar el `context` del método `build` que *crea* el `Scaffold` para llamar a `Scaffold.of(context)`: ese `context` es el del padre, no el de un hijo. Solución: un `Builder` o extraer un widget hijo, que tendrá su propio `context`.

**Error típico:** guardar el `context` y usarlo **después de un `await`**: el widget pudo desmontarse. Comprueba `if (!context.mounted) return;` antes de usarlo.

---

## 3. Restricciones: "las restricciones bajan, los tamaños suben"

**Respuesta corta:** el padre le da al hijo un rango (mínimo y máximo de ancho y alto); el hijo elige su tamaño **dentro** de ese rango; el padre lo coloca.

```
   Padre ──── restricciones (min/max ancho y alto) ────► Hijo
   Padre ◄──── tamaño elegido (dentro del rango) ─────── Hijo
   Padre decide la POSICIÓN
```

Dos ejemplos que lo hacen visible:

- **`Center` suelta la restricción** al hijo: pasa de "ocupa exactamente esto" a "ocupa lo que quieras, hasta esto".
- **`Row` no limita el ancho de sus hijos** en su eje principal: un `Text` largo quiere más ancho del que queda y aparece la franja amarilla y negra de *overflow*. Se arregla envolviéndolo en `Expanded`, que sí le da un ancho concreto.

> 📂 **En este proyecto:** la demo de layout lo enseña con este comentario: [«Las restricciones bajan, los tamaños suben»](../lib/features/basics/layout_screen.dart#L11 "→ Las restricciones bajan, los tamaños suben") y te invita a pulsar `p` en la terminal (debug paint) para ver los bordes de cada widget.

**Por qué importa:** casi todos los errores de layout se resuelven preguntando "¿qué restricciones recibe este widget y qué tamaño pide?".
**Error típico:** meter un `ListView` dentro de una `Column` sin `Expanded`: la `Column` le da alto **ilimitado** y Flutter lanza `Vertical viewport was given unbounded height`.

---

## 4. Rebuilds, `const` y por qué `build` debe ser barato

**Respuesta corta:** `build()` puede ejecutarse muchas veces (cada `setState`, cada cambio de un `Provider` observado, cada fotograma de una animación), así que debe ser **rápido y sin efectos secundarios**.

```dart
// ✅ barato: solo describe widgets
Widget build(BuildContext context) => Text('$_count');

// ❌ caro o con efectos: cálculos pesados, red, escribir en disco
Widget build(BuildContext context) {
  final primos = contarPrimos(5000000); // se repetiría en cada rebuild
  return Text('$primos');
}
```

Dos herramientas para reconstruir menos:

1. **`const`**: un widget `const` es la **misma instancia** en cada `build`; Flutter comprueba que es idéntica y no necesita revisar ese subárbol.
2. **Reutilizar `child`**: los `AnimatedBuilder` y similares te dejan pasar un `child` que se construye **una vez** y se reaplica en cada fotograma.

> 📂 **En este proyecto:** [`const FlutterLogo`](../lib/features/advanced/animations_screen.dart#L181 "→ const FlutterLogo(size: 64)") se pasa como `child` del `AnimatedBuilder`, y en la misma pantalla verás muchos [`const Duration`](../lib/features/advanced/animations_screen.dart#L50 "→ duration: const Duration(seconds: 2),") y `const EdgeInsets`.

**Por qué importa:** una animación llama a `build` ~60 veces por segundo. Todo lo que no cambie debe quedar fuera de ese camino.
**Error típico:** un `setState` en el widget raíz de una pantalla grande cuando solo cambia un contador: baja el `setState` (o el `ref.watch`) al widget más pequeño que lo necesita.

---

## 5. Keys: cuándo importan

**Respuesta corta:** una `Key` le dice a Flutter **qué widget es cuál** cuando cambia el orden o la cantidad de hermanos; sin ella, Flutter los empareja por posición.

```
Lista antes:   [A][B][C]        Sin keys, borrar A:  Flutter reutiliza el
Lista después: [B][C]           Element 0 (de A) para B → el State de A
                                "se pega" a B.
```

- **No necesitas keys** en listas estáticas ni cuando los hijos no tienen estado propio.
- **Sí las necesitas** cuando los hijos se reordenan, se insertan o se borran **y** guardan estado (un `TextField`, un `Checkbox`, una animación) o usan `Dismissible`.
- `ValueKey(id)` usa un valor estable y único (el `id`, no el índice). `GlobalKey` es la pesada: da acceso al `State` desde fuera; úsala con moderación.

> 📂 **En este proyecto:** [las tareas](../lib/features/todos/todos_screen.dart#L157 "→ key: ValueKey(todo.id),") usan el `id` de cada `Todo` para que al deslizar y borrar una no se arrastre el estado de otra, y [la demo de listas](../lib/features/basics/lists_screen.dart#L137 "→ key: ValueKey(item),") hace lo mismo al reordenar.

**Error típico:** usar el **índice** como key (cambia al borrar) o no poner ninguna en una lista reordenable con estado.

---

## 6. Ciclo de vida de `State`

**Respuesta corta:** un `State` nace, se configura, se reconstruye muchas veces y muere; cada fase tiene un método para engancharte.

```
createState → initState → didChangeDependencies → build
                                   ▲                 │
        didUpdateWidget ───────────┼── setState ─────┘   (build se repite)
                                   │
                    deactivate → dispose   (sale del árbol)
```

| Método | Cuándo se ejecuta | Para qué |
|---|---|---|
| `initState` | **Una vez**, al insertarse | Crear controladores, suscripciones. Llama a `super.initState()` primero. |
| `didChangeDependencies` | Tras `initState` y cuando cambia un `InheritedWidget` del que dependes | Leer `Theme.of`, `MediaQuery.of`, `Localizations.of`: en `initState` aún no puedes depender de ellos. |
| `didUpdateWidget` | Cuando el padre te reconstruye con otra configuración | Reaccionar a cambios de las propiedades del widget. |
| `dispose` | **Una vez**, al salir | Cerrar controladores y suscripciones. Llama a `super.dispose()` al final. |

> 📂 **En este proyecto:** la demo del contador registra cada fase en pantalla: mira [`initState`](../lib/features/basics/counter_screen.dart#L61 "→ debugPrint('CounterScreen.initState');") y [`dispose`](../lib/features/basics/counter_screen.dart#L69 "→ debugPrint('CounterScreen.dispose');"). Entra y sal de la demo con la terminal abierta para verlos.

**Por qué importa:** todo lo que creas en `initState` y no cierras en `dispose` es una fuga (controladores, `Timer`, streams).
**Error típico:** llamar a `setState` cuando el `State` ya no está montado; si hay un `await` por medio, comprueba `if (!mounted) return;`.

---

## 7. ¿Quién es dueño del estado?

**Respuesta corta:** el estado vive en **el widget más bajo del árbol que sea ancestro común de todos los que lo necesitan**.

- Solo lo usa un widget → `State` local (`setState`).
- Lo usan varios hermanos → súbelo al padre común y pásalo hacia abajo (*lifting state up*).
- Lo usan pantallas lejanas, o debe sobrevivir a ellas → un gestor de estado como Riverpod.

El flujo siempre es el mismo: **el estado baja** como datos y **los eventos suben** como callbacks. Eso hace que cada cambio tenga un único responsable.

📖 La lección práctica, con código, está en [06 · Gestión de estado](06-construir-la-app.md#5-gestión-de-estado).

---

## 8. Inmutabilidad: por qué no se muta el estado

**Respuesta corta:** en vez de modificar un objeto, creas una **copia nueva** con el cambio; así quien observa puede detectar que algo cambió comparando "antes" y "después".

```dart
// ❌ mutar: la lista es el MISMO objeto, nadie se entera
estado.add(nueva);

// ✅ copiar: objeto distinto, el cambio es detectable
estado = [...estado, nueva];
```

Además da historial gratis (el estado anterior sigue intacto), evita que dos partes de la app se pisen y facilita las pruebas.

> 📂 **En este proyecto:** [`Todo.copyWith`](../lib/features/todos/todo.dart#L29 "→ Todo copyWith") devuelve una tarea nueva con otro `title` o `done` y conserva `id` y `createdAt`. El controlador de tareas reemplaza la lista entera en vez de editarla: así Riverpod ve un valor distinto y reconstruye lo que lo observa.

**Error típico:** hacer `todos.add(...)` sobre la lista del estado: la pantalla no se actualiza porque el objeto es el mismo.

---

## 9. Navegación imperativa vs declarativa

**Respuesta corta:** *imperativa* = das órdenes ("empuja esta pantalla", `Navigator.push`); *declarativa* = describes **dónde estás** (una URL como `/tareas`) y el router construye la pila a partir de ahí.

- La imperativa es simple para flujos cortos, pero la pila vive "escondida" en el `Navigator`.
- La declarativa (go_router en este proyecto) hace que la ruta sea **un dato**: puedes abrir enlaces profundos, redirigir si no hay sesión y volver con el botón atrás del sistema sin código extra.

📖 La lección práctica, con ejemplos, está en [06 · Navegación entre pantallas](06-construir-la-app.md#4-navegación-entre-pantallas).

---

## 10. El event loop de Dart: microtasks, eventos e isolates

**Respuesta corta:** cada isolate ejecuta **una sola tarea a la vez**; entre tarea y tarea vacía primero la cola de *microtasks* y después toma el siguiente *evento* (toque, temporizador, respuesta de red, fotograma).

```
   ┌─ cola de microtasks ─┐   siempre se vacía primero
   │ scheduleMicrotask,   │
   │ then() de futuros ya │
   │ completados          │
   └──────────┬───────────┘
              ▼
   ┌─ cola de eventos ────┐   un evento por vuelta
   │ toques, timers, I/O  │
   └──────────────────────┘
```

- **`await` no crea otro hilo**: suspende tu función y deja que el loop siga con otras tareas hasta que el resultado llegue. Sirve para **esperar** (red, disco).
- **Calcular** sigue ocupando el hilo principal: si una función tarda 3 s, la interfaz no se dibuja durante 3 s. Para eso existen los **isolates**: otro hilo de Dart con su propia memoria; se comunican por mensajes.
- `compute(funcion, argumento)` (Flutter) e `Isolate.run(...)` (Dart) lanzan una función en otro isolate y devuelven un `Future` con el resultado.

> 📂 **En este proyecto:** la demo de isolates compara las dos opciones; mira [la llamada a `compute`](../lib/features/advanced/isolates_screen.dart#L73 "→ await compute(countPrimes, _limit)") y pulsa "En el hilo principal" para ver cómo se congela la ruedita.

**Error típico:** pensar que `async/await` hace el cálculo "en segundo plano". Solo reparte el tiempo; el trabajo pesado se mueve a un isolate. La función que ejecutas allí debe ser de nivel superior o `static`.

---

## 11. Scroll: viewports y slivers

**Respuesta corta:** un `Viewport` es una ventana que muestra solo la parte visible de una lista de **slivers** (trozos de contenido que se pueden desplazar); `ListView` es un atajo que ya trae uno.

```
CustomScrollView                 ← un único scroll
 ├─ SliverAppBar.large           ← cabecera que se encoge
 ├─ SliverList                   ← filas construidas bajo demanda
 └─ SliverToBoxAdapter           ← cualquier widget normal como "trozo"
```

- Los constructores `.builder` crean cada fila **solo cuando entra en pantalla**; una lista de 10 000 elementos no construye 10 000 widgets.
- Para mezclar cabeceras, listas y cuadrículas **en un solo scroll** (sin `ListView` dentro de `ListView`, que da errores de restricciones del apartado 3) usa `CustomScrollView` y slivers.

> 📂 **En este proyecto:** [el catálogo](../lib/features/catalog/catalog_screen.dart#L48 "→ body: CustomScrollView") combina un `SliverAppBar.large` que se encoge con el scroll y varias `SliverList`.

**Error típico:** anidar una lista dentro de otra con `shrinkWrap: true`: construye todo de golpe y pierde la carga bajo demanda.

---

## 🧭 Resumen en una tabla

| Modelo | Una frase para recordar |
|---|---|
| 3 árboles | Los widgets son descripciones baratas; el `Element` vive y el `RenderObject` pinta. |
| `BuildContext` | Es tu posición; las búsquedas (`of`) suben por los ancestros. |
| Restricciones | Bajan las restricciones, suben los tamaños. |
| Rebuilds | `build` se repite: que sea barato; usa `const`. |
| Keys | Identifican widgets cuando cambia el orden y hay estado. |
| Ciclo de vida | Lo que abres en `initState` se cierra en `dispose`. |
| Dueño del estado | En el ancestro común más bajo. |
| Inmutabilidad | Copia, no mutes. |
| Navegación | Declarativa = la ruta es un dato. |
| Event loop | `await` espera; los isolates calculan. |
| Slivers | Un scroll, muchos trozos, construidos bajo demanda. |

---

## ✅ Comprueba que entendiste

1. ¿Por qué es barato que `build()` cree widgets nuevos en cada rebuild?
   <details><summary>Respuesta</summary>

   Porque un widget solo es una descripción inmutable; Flutter reutiliza el `Element` y el `RenderObject` cuando el tipo y la `key` coinciden y solo actualiza lo que cambió (sección 1).

   </details>
2. ¿Qué pasa si pones un `ListView` dentro de una `Column` sin `Expanded`, y por qué?
   <details><summary>Respuesta</summary>

   Flutter lanza un error de *viewport con alto ilimitado*: la `Column` no limita el alto de sus hijos y el `ListView` necesita un alto concreto para saber cuánto scroll tiene (sección 3).

   </details>
3. ¿Por qué las tareas de [TodosScreen](../lib/features/todos/todos_screen.dart) usan `ValueKey(todo.id)` y no el índice de la lista?
   <details><summary>Respuesta</summary>

   El índice cambia al borrar una tarea, así que Flutter emparejaría el `State` de una fila con otra tarea; el `id` es estable y único y mantiene cada estado con su tarea (sección 5).

   </details>
4. ¿Dónde se debe leer `Theme.of(context)` en un `State`: en `initState` o en `didChangeDependencies`/`build`? ¿Y qué debes cerrar en `dispose`?
   <details><summary>Respuesta</summary>

   En `didChangeDependencies` o `build`, porque en `initState` aún no se puede depender de un `InheritedWidget`. En `dispose` se cierran los controladores y suscripciones creados en `initState` (sección 6).

   </details>
5. ¿Qué pasa si en un controlador de estado haces `estado.add(x)` en vez de crear una lista nueva?
   <details><summary>Respuesta</summary>

   El objeto sigue siendo el mismo (Riverpod 3 filtra las notificaciones con `==`: estado nuevo igual al anterior, no se avisa), quien observa no detecta el cambio y la interfaz no se actualiza. Con una copia nueva (como hace [`Todo.copyWith`](../lib/features/todos/todo.dart)) el cambio es detectable (sección 8).

   </details>

## 🏋️ Reto

**Mide los rebuilds.** Activa el conteo de rebuilds (en Android Studio: «Track widget rebuilds»; en DevTools, vista Performance: «Count widget builds»; ambos con la app en modo debug; detalle en [17 §4](17-calidad-de-produccion.md)), abre la demo Contador y mira qué widgets se reconstruyen al pulsar `+`; añade `const` donde puedas y compara.

- ✅ **Cómo saber que lo lograste:** puedes decir qué widgets se reconstruyeron antes y después de añadir `const`, y por qué los que cambian no pueden ser `const`.
- 💡 **Pista:** el número que se muestra junto a cada widget sube con cada reconstrucción; los widgets `const` y los que no dependen del contador no deberían subir.

---

## ➡️ Siguiente paso

Continúa con **[10 · Funcionalidades de la app](10-funcionalidades-de-la-app.md)**: ahora que sabes por qué funcionan los widgets, recorre el catálogo de demos y reconoce estos modelos en código real. Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).
