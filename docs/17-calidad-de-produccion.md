# 17 · Calidad de producción: accesibilidad, errores y rendimiento

> Anterior: [16 · Cómo piensa Flutter](16-como-piensa-flutter.md) · Volver al [índice](../README.md)

> 🎯 **Aprenderás:** hacer que una pantalla se entienda con lector de pantalla, capturar los errores que nadie vio venir, y medir (no adivinar) el rendimiento.
> 📋 **Necesitas antes:** [06 · Construir la app](06-construir-la-app.md) y [16 · Cómo piensa Flutter](16-como-piensa-flutter.md)
> ⏱️ **Tiempo:** ~25 min de lectura + ~20 min practicando

Una app que "funciona en mi simulador" aún no está lista para publicarse. Este documento cubre lo que separa una demo de una app de producción: que la use cualquier persona, que sepas cuándo falla y que no se sienta lenta.

| # | Tema | Pregunta que responde |
|---|---|---|
| 1 | Accesibilidad | ¿Puede usarla alguien con lector de pantalla o texto grande? |
| 2 | Ciclo de vida de la app | ¿Qué hago cuando la app pasa a segundo plano? |
| 3 | Errores globales | ¿Cómo me entero de un fallo en el teléfono de un usuario? |
| 4 | Rendimiento con DevTools | ¿Por qué va a tirones y dónde lo arreglo? |
| 5 | Pruebas golden | ¿Cómo detecto que un cambio rompió el aspecto? |

---

## 1. ♿ Accesibilidad

**Por qué importa en un lanzamiento:** las tiendas y muchas empresas exigen accesibilidad, y millones de personas usan VoiceOver (iOS) o TalkBack (Android). Con los widgets de Material ya tienes la mitad hecha; falta lo que Flutter no puede adivinar.

### 1.1 `Semantics`: dile al lector qué es cada cosa

Flutter construye un árbol de **semántica** paralelo al de widgets; el lector de pantalla lee ese árbol. Los botones y textos estándar ya aportan su etiqueta. Cuando dibujas algo propio (un icono suelto, un `GestureDetector`) debes describirlo:

```dart
// Un icono tocable "a mano": sin Semantics, el lector no sabe qué es.
Semantics(
  button: true,
  label: 'Añadir a favoritos', // lo que se lee en voz alta
  child: GestureDetector(
    onTap: _toggleFavorite,
    child: const Icon(Icons.favorite_border),
  ),
)
```

Herramientas que debes conocer:

| Widget | Para qué |
|---|---|
| `Semantics(label:, button:, ...)` | Añade o sobrescribe la descripción de un widget |
| `MergeSemantics` | Junta varios widgets en UN solo elemento (p. ej. icono + texto) |
| `ExcludeSemantics` | Oculta algo decorativo que solo estorbaría al lector |

La forma más barata de tener etiqueta en un botón con icono es el `tooltip`, que además sirve de ayuda visual:

> 📂 **En este proyecto:** el botón de sumar del contador usa [`tooltip`](../lib/features/basics/counter_screen.dart#L143 "→ tooltip: 'Incrementar'") en lugar de un `Semantics` explícito. Los lectores de pantalla anuncian el tooltip del botón; compruébalo tú mismo con VoiceOver/TalkBack (ver el reto del final).

⚠️ **Error más común:** `IconButton(icon: ..., onPressed: ...)` **sin** `tooltip` ni `Semantics`. El lector dice solo "botón" y la persona no sabe qué hace. Es el fallo de accesibilidad más frecuente en Flutter.

### 1.2 Escala de texto

Quien tiene la vista cansada sube el tamaño de fuente del sistema. Tu UI debe aguantarlo sin cortar texto ni desbordar (`RenderFlex overflowed`).

```dart
// Cuánto está ampliando el usuario el texto (1.0 = normal).
final escala = MediaQuery.textScalerOf(context).scale(1);
```

> 📂 **En este proyecto:** la demo de diseño adaptable lee el factor con [`textScalerOf`](../lib/features/advanced/responsive_screen.dart#L39 "→ MediaQuery.textScalerOf(context).scale(1)"). Cambia el tamaño de fuente en los ajustes del sistema y mira cómo cambia el valor.

Reglas prácticas:

- No fijes alturas en píxeles a contenedores con texto: deja que crezcan (`Flexible`, `Expanded`, `Wrap`, `ListView`).
- Prueba siempre con la escala al máximo del sistema.
- `MediaQuery.withClampedTextScaling(minScaleFactor: ..., maxScaleFactor: ...)` limita la escala en una zona concreta, pero úsalo solo como último recurso: estás quitándole control al usuario.

### 1.3 Contraste y áreas táctiles

| Requisito | Mínimo | Dónde se rompe |
|---|---|---|
| Contraste texto/fondo | 4,5 : 1 (WCAG AA) | Gris claro sobre blanco, texto sobre imágenes |
| Área táctil | 48 × 48 dp (Android) · 44 × 44 pt (iOS) | Iconos de 24 px con `GestureDetector` sin relleno |
| No solo color | Añade icono o texto | "Rojo = error" invisible para daltónicos |

Flutter puede comprobar etiquetas y áreas táctiles en un test. Esta prueba se verificó contra la pantalla del contador de este proyecto:

```dart
testWidgets('los botones tienen etiqueta y área táctil suficiente',
    (tester) async {
  final handle = tester.ensureSemantics(); // activa el árbol de semántica
  await tester.pumpWidget(wrapWithMaterialApp(const CounterScreen()));

  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  handle.dispose(); // no olvides liberarlo
});
```

> 📂 **En este proyecto:** `wrapWithMaterialApp` viene de [test_helpers.dart](../test/helpers/test_helpers.dart). Hoy el proyecto **no** tiene pruebas de accesibilidad: este ejemplo es lo que añadirías.

### 1.4 Pruébalo a mano

1. **Semantics Debugger:** pon `showSemanticsDebugger: true` en `MaterialApp` y verás las etiquetas dibujadas sobre la UI.
2. **Lector real:** VoiceOver (iOS: Ajustes → Accesibilidad) o TalkBack (Android). Recorre tu pantalla con los ojos cerrados.

---

## 2. 🔄 Ciclo de vida de la app

**Por qué importa:** el usuario sale de tu app a mitad de un pago, recibe una llamada o la bloquea. Si no guardas ni pausas lo que corresponde, pierdes datos o gastas batería.

`AppLifecycleListener` te avisa de los cambios de estado de la app (distinto del ciclo de vida de un `State`, que ves en [16 · Cómo piensa Flutter](16-como-piensa-flutter.md)):

```dart
class _MiPantallaState extends State<MiPantalla> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onResume: _recargarDatos,   // volvió a primer plano
      onPause: _guardarBorrador,  // pasó a segundo plano
      // onStateChange recibe el AppLifecycleState completo si lo necesitas
    );
  }

  @override
  void dispose() {
    _listener.dispose(); // ⚠️ obligatorio: si no, fuga de memoria
    super.dispose();
  }
  // ...
}
```

Qué hacer en cada momento:

| Callback | Úsalo para |
|---|---|
| `onResume` | Refrescar datos, volver a conectar un stream |
| `onPause` | Guardar borradores, pausar animaciones/vídeo/GPS |
| `onInactive` | Interrupción corta (llamada entrante, diálogo del sistema) |
| `onDetach` | Último aviso antes de cerrar (no está garantizado en móvil) |

⚠️ **Error más común:** crear el listener y olvidar `dispose()`. Otro: guardar solo en `onDetach`, que en móvil el sistema puede no llegar a dar: guarda en `onPause`.

> 📂 **En este proyecto:** la demo del contador ya enseña el ciclo de vida de un `State` (el [contador](../lib/features/basics/counter_screen.dart#L150 "→ title: 'Ciclo de vida',") tiene una sección "Ciclo de vida"). El proyecto **no** usa `AppLifecycleListener` todavía.

---

## 3. 🚨 Errores globales

**Por qué importa:** en producción no ves la consola del teléfono del usuario. Si no capturas los errores, solo te enteras por una reseña de una estrella.

Flutter tiene **dos** vías de error y necesitas enganchar las dos:

| Hook | Captura | Ejemplo |
|---|---|---|
| `FlutterError.onError` | Errores **del framework**: `build`, layout, pintado, gestos | `RenderFlex overflowed`, excepción dentro de `build()` |
| `PlatformDispatcher.instance.onError` | Errores **asíncronos no capturados** y de plataforma | Un `Future` sin `catch`, fallo dentro de un `Timer` o un `Stream` |

### 3.1 El código mínimo

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Errores del framework (build, layout, pintado).
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details); // sigue mostrándolo en consola
    _reportar(details.exception, details.stack);
  };

  // 2) Errores asíncronos que nadie capturó.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _reportar(error, stack);
    return true; // true = "ya lo manejé"; false = que siga el error por defecto
  };

  runApp(const MyApp());
}

void _reportar(Object error, StackTrace? stack) {
  // Aquí enchufas tu servicio (ver 3.2). De momento, solo log.
  debugPrint('Error no capturado: $error');
}
```

> 📂 **En este proyecto:** esto **todavía no está implementado**. Iría justo después de `WidgetsFlutterBinding.ensureInitialized();` dentro de [`main()`](../lib/main.dart#L42 "→ WidgetsFlutterBinding.ensureInitialized();") y antes de `runApp`. Recuerda que los cambios en `main()` no se aplican con hot reload: usa `R`.

Por defecto, `FlutterError.onError` ya llama a `FlutterError.presentError`. Al sustituirlo tú, **debes** llamarla si quieres seguir viendo el error en la consola.

### 3.2 Dónde enchufar Crashlytics o Sentry

Los servicios de reporte se conectan exactamente en esos dos hooks:

| Servicio | Qué haces |
|---|---|
| **Firebase Crashlytics** | Envías `details` desde `FlutterError.onError` y `error, stack` desde `PlatformDispatcher.instance.onError` a su API de registro |
| **Sentry** (`sentry_flutter`) | Su inicializador instala estos hooks por ti |

Ambos aparecen en [12 · Librerías más usadas](12-librerias-mas-usadas.md). Sigue su documentación oficial para los nombres exactos de llamada: no los repito aquí porque cambian entre versiones.

⚠️ **Errores más comunes:**

- Capturar solo uno de los dos hooks: los fallos de `Future` sin `catch` se pierden.
- Devolver `true` sin reportar nada: el error desaparece en silencio.
- Probar el reporte solo en debug: valídalo con una build **release** forzando un error de prueba.
- Enviar datos personales en el mensaje de error.

### 3.3 Pantalla de error amistosa

En modo release, un error de `build` deja una pantalla gris. Puedes cambiarla con `ErrorWidget.builder`, pero eso es opcional: lo importante es **reportar** el error.

---

## 4. 📈 Rendimiento con DevTools

**Por qué importa:** 60 fps dan unos 16 ms por fotograma (8 ms a 120 Hz). Si un fotograma tarda más, el usuario ve *jank* (tirones). La regla de oro: **mide antes de optimizar**.

### 4.1 Mide en las condiciones correctas

| Hacer | No hacer |
|---|---|
| Dispositivo físico, modo **profile** (`flutter run --profile`) | Medir en modo debug: es mucho más lento a propósito |
| Abrir **DevTools → Performance** | Optimizar "a ojo" |

### 4.2 UI thread vs raster thread

La pestaña Performance separa cada fotograma en dos tareas. Saber cuál se pasa de tiempo te dice dónde mirar:

| Hilo | Hace | Si va lento, sospecha de |
|---|---|---|
| **UI** | Ejecuta tu código Dart: `build`, layout | `build` pesado, cálculos en el hilo principal, demasiados rebuilds |
| **Raster** | Dibuja los píxeles en la GPU | Sombras y `opacity` anidados, `saveLayer`, imágenes enormes |

Los cálculos pesados en Dart (parsear JSON gigante, primos…) se mueven a un isolate: la demo de isolates de este proyecto lo muestra (ver [10 · Funcionalidades](10-funcionalidades-de-la-app.md)).

### 4.3 Rebuilds

En Android Studio / IntelliJ activa **Track widget rebuilds** (el IDE muestra qué widgets se reconstruyen en cada interacción). En DevTools, la vista **Performance** tiene el ajuste **Count widget builds**, que cuenta cuántas veces se construye cada widget (el nombre de estas opciones cambia entre versiones: si no lo ves, busca "rebuild" o "builds" en los ajustes). Si un `setState` arriba reconstruye media pantalla para cambiar un número, baja el estado, extrae widgets y usa `const` (el porqué está en [16 · Cómo piensa Flutter](16-como-piensa-flutter.md)).

> 📂 **En este proyecto:** el contador cambia su número con una [`ValueKey`](../lib/features/basics/counter_screen.dart#L117 "→ key: ValueKey(_count),") para que `AnimatedSwitcher` anime solo ese texto. Es un buen sitio para activar el seguimiento y ver qué se reconstruye al pulsar `+`.

### 4.4 `RepaintBoundary`

Cuando una parte de la pantalla se repinta muy a menudo (una animación) y el resto no, `RepaintBoundary` aísla ese trozo en su propia capa para que no obligue a repintar todo:

```dart
RepaintBoundary(
  child: MiAnimacionContinua(), // se repinta sola, sin arrastrar al resto
)
```

Para ver si te hace falta, activa **Highlight repaints** en el Inspector: las zonas que se repintan parpadean.

⚠️ **Error más común:** ponerlo "por si acaso" en todas partes. Cada capa cuesta memoria: añádelo solo cuando el profiler muestre un repintado innecesario.

### 4.5 Checklist rápida antes de optimizar

- [ ] Mido en profile y dispositivo real
- [ ] Sé si el cuello de botella es UI o raster
- [ ] Listas largas con `ListView.builder` (no `ListView(children: [...])` con miles de elementos)
- [ ] `const` donde se pueda
- [ ] Trabajo pesado fuera del hilo principal (isolates)

---

## 5. 🖼️ Pruebas golden

**Por qué importa:** una prueba normal comprueba que el texto "0" existe; no detecta que alguien cambió el color o rompió el espaciado. Una prueba **golden** compara la pantalla, píxel a píxel, con una imagen de referencia guardada.

> ⚠️ **Estado del proyecto:** hoy **no tiene pruebas golden**. El siguiente ejemplo es lo que añadirías; se verificó en una copia aparte del proyecto. Para el resto de pruebas, ver [07 · Pruebas y calidad](07-pruebas-y-calidad.md).

### 5.1 El código mínimo

Ejemplo sobre una pantalla existente, `CounterScreen`:

```dart
testWidgets('CounterScreen se ve igual que el golden', (tester) async {
  // Tamaño fijo: el golden no debe depender del tamaño de la ventana de test.
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(wrapWithMaterialApp(const CounterScreen()));
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(CounterScreen),
    matchesGoldenFile('goldens/counter_screen.png'), // ruta junto al test
  );
});
```

### 5.2 Flujo de trabajo

| Paso | Comando | Resultado |
|---|---|---|
| 1. Crear la imagen de referencia | `flutter test --update-goldens` | Genera `test/goldens/counter_screen.png`; revísala y súbela a git |
| 2. Ejecutar de normal | `flutter test` | Falla si la pantalla ya no coincide |
| 3. Cambio de diseño intencionado | `flutter test --update-goldens` | Reescribe la imagen; revisa el diff visual en el PR |

Sin imagen de referencia, la prueba **falla**: por eso el paso 1 va primero.

⚠️ **Errores más comunes:**

- Las fuentes y el renderizado difieren entre macOS, Windows y Linux: genera y compara los goldens en el **mismo sistema** (normalmente el de tu CI).
- Goldens de pantallas enteras con datos reales o fechas: frágiles. Mejor widgets pequeños con datos fijos.
- Actualizar el golden sin mirar la imagen: la prueba pasa, pero ya no protege nada.

---

## ✅ Comprueba que entendiste

1. ¿Qué pasa con un `IconButton` sin `tooltip` ni `Semantics` cuando lo recorre un lector de pantalla?
   <details><summary>Respuesta</summary>

   Solo anuncia "botón", sin decir qué hace. Arréglalo con `tooltip:` o con un `Semantics(label: ...)`, como en [§1.1](#11-semantics-dile-al-lector-qué-es-cada-cosa).

   </details>
2. ¿Por qué hay que enganchar `FlutterError.onError` **y** `PlatformDispatcher.instance.onError`?
   <details><summary>Respuesta</summary>

   Cada uno ve una clase de errores distinta: el primero los del framework (`build`, layout, pintado) y el segundo los asíncronos que nadie capturó. Con uno solo, el otro tipo se pierde. Ver [§3](#3--errores-globales).

   </details>
3. ¿Dónde iría el código de errores globales en este proyecto y por qué no se aplica con hot reload?
   <details><summary>Respuesta</summary>

   En `main()` de `lib/main.dart`, antes de `runApp`. `main()` solo se ejecuta al arrancar, así que hace falta hot restart (`R`).

   </details>
4. ¿Por qué no se mide el rendimiento en modo debug?
   <details><summary>Respuesta</summary>

   Debug compila con comprobaciones extra y es mucho más lento a propósito; los números no representan la app real. Usa `flutter run --profile` en un dispositivo físico.

   </details>
5. ¿Qué pasa si ejecutas una prueba con `matchesGoldenFile` y aún no existe la imagen?
   <details><summary>Respuesta</summary>

   Falla. Primero hay que generarla con `flutter test --update-goldens` y revisarla antes de subirla a git.

   </details>

## 🏋️ Reto

**Hazla accesible.** Activa VoiceOver o TalkBack (o `showSemanticsDebugger: true`) y recorre la demo Contador. ¿Se entiende cada botón sin mirar la pantalla? Añade lo que falte.

- ✅ **Cómo saber que lo lograste:** el lector anuncia una descripción útil para cada control y puedes sumar, restar y reiniciar con los ojos cerrados.
- 💡 **Pista:** los botones con icono ya tienen `tooltip`; revisa los demás controles y el número que cambia.

## ➡️ Siguiente paso

Continúa con **[13 · Onboarding](13-onboarding.md)**: ahora que sabes cuidar la calidad de una pantalla, verás cómo se construye una de bienvenida con animaciones. Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).
