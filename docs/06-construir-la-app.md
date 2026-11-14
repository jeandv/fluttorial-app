# 06 · Construir la app: widgets, pantallas, estado y paquetes

> Anterior: [05 · Dart esencial](05-dart-esencial.md) · Volver al [índice](../README.md) · Siguiente: [16 · Cómo piensa Flutter](16-como-piensa-flutter.md)

> 🎯 **Aprenderás:** componer pantallas con widgets, navegar entre ellas, decidir dónde vive el estado (`setState` o Riverpod) y consumir una API.
> 📋 **Necesitas antes:** [05 · Dart esencial](05-dart-esencial.md)
> ⏱️ **Tiempo:** ~60 min de lectura + ~45 min practicando

---

## 1. La idea central: **todo es un widget**

Una app Flutter es un **árbol de widgets**. Cada widget describe una parte de la interfaz: un texto, un botón, un margen, una pantalla entera…

```
MaterialApp                ← configuración global (tema, rutas)
└── Scaffold               ← estructura de pantalla (appBar, body, botón flotante)
    ├── AppBar
    │   └── Text('Título')
    ├── Center
    │   └── Column
    │       ├── Text('Has pulsado...')
    │       └── Text('0')
    └── FloatingActionButton
        └── Icon(Icons.add)
```

Ese es el árbol típico de una pantalla sencilla (el clásico contador). En este proyecto, [`main.dart`](../lib/main.dart#L47 "→ ProviderScope") solo arranca la app (`ProviderScope` → `MyApp`) y **cada pantalla es su propio subárbol**; por ejemplo, [CounterScreen](../lib/features/basics/counter_screen.dart#L34 "→ class CounterScreen extends StatefulWidget").

### `StatelessWidget` vs `StatefulWidget`

> 📂 **En este proyecto:** Stateless: [_DemoTile](../lib/features/catalog/catalog_screen.dart#L104 "→ class _DemoTile extends StatelessWidget") · Stateful: [CounterScreen](../lib/features/basics/counter_screen.dart#L34 "→ class CounterScreen extends StatefulWidget") · con Riverpod: [ConsumerWidget](../lib/features/posts/posts_screens.dart#L33 "→ class PostsScreen extends ConsumerWidget") (→ lo verás en [§5](#5-gestión-de-estado); por ahora quédate con `StatelessWidget` y `StatefulWidget`) .

| | `StatelessWidget` | `StatefulWidget` |
|---|---|---|
| ¿Tiene datos que cambian? | No | Sí (en su objeto `State`) |
| ¿Cómo se actualiza? | Solo si su padre lo reconstruye | Llamando a `setState(() { ... })` |
| Ejemplo | Un título, una tarjeta de producto | Un contador, un formulario, un checkbox |

```dart
class Saludo extends StatelessWidget {
  const Saludo({super.key, required this.nombre});
  final String nombre;

  @override
  Widget build(BuildContext context) => Text('Hola, $nombre');
}

class Contador extends StatefulWidget {
  const Contador({super.key});
  @override
  State<Contador> createState() => _ContadorState();
}

class _ContadorState extends State<Contador> {
  int _valor = 0;

  @override
  void initState() {         // se ejecuta UNA vez al crear el widget
    super.initState();
  }

  @override
  void dispose() {           // se ejecuta al destruirlo (libera controladores)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => _valor++), // ← redibuja
        child: Text('$_valor'),
      );
}
```

> 💡 En VS Code escribe `stless` o `stful` + Enter para generar la plantilla.

---

## 2. Cómo organizar `lib/`

> 📂 **En este proyecto:** se usa la organización **por funcionalidad**: [lib/core/](../lib/core/) + [lib/features/](../lib/features/). Explicación en [docs/11 §0](11-configuraciones-avanzadas.md#0-arquitectura-del-proyecto).

Para apps pequeñas o medianas (**recomendado para empezar**):

```
lib/
├── main.dart              # Solo arranca la app: runApp(const MyApp())
├── app.dart               # MaterialApp, tema, rutas
├── screens/               # Una pantalla por archivo
│   ├── home_screen.dart
│   └── detalle_screen.dart
├── widgets/               # Widgets reutilizables
│   └── producto_card.dart
├── models/                # Clases de datos (Producto, Usuario…)
│   └── producto.dart
├── services/              # Acceso a API, base de datos, almacenamiento
│   └── api_service.dart
├── providers/ o state/    # Gestión de estado (Riverpod, Bloc, ChangeNotifier…)
└── utils/                 # Constantes, helpers, extensiones, tema
    ├── constants.dart
    └── theme.dart
```

Para apps grandes, se organiza **por funcionalidad** (*feature-first*):

```
lib/
├── main.dart
├── core/                  # Tema, router, cliente HTTP, utilidades compartidas
└── features/
    ├── auth/
    │   ├── data/          # Repositorios, fuentes de datos, DTOs
    │   ├── domain/        # Modelos y lógica de negocio
    │   └── presentation/  # Pantallas, widgets y estado de esta funcionalidad
    └── productos/
        ├── data/
        ├── domain/
        └── presentation/
```

> 💡 **En este proyecto** cada funcionalidad es una carpeta **plana**, sin `data/`, `domain/` ni `presentation/`: con pocos archivos, más subcarpetas serían ruido; sepáralas cuando una funcionalidad crezca. El árbol real está en [02 · Estructura del proyecto](02-estructura-del-proyecto.md) y la arquitectura en [11 §0](11-configuraciones-avanzadas.md#0-arquitectura-del-proyecto).

Más detalle en [lib/README.md](../lib/README.md).

---

## 3. Widgets que usarás constantemente

### Estructura
| Widget | Para qué |
|---|---|
| `MaterialApp` | Raíz de la app (tema, rutas, idioma) — estilo Material (Android/Google) |
| `CupertinoApp` | Igual pero con estilo iOS |
| `Scaffold` | Esqueleto de pantalla: `appBar`, `body`, `drawer`, `bottomNavigationBar`, `floatingActionButton` |
| `AppBar` | Barra superior |
| `SafeArea` | Evita el notch, la isla dinámica y las barras del sistema |

### Layout (posicionar cosas)

> 📂 **En este proyecto:** todos estos widgets funcionando en [layout_screen.dart](../lib/features/basics/layout_screen.dart) (demo *Layout*).
| Widget | Para qué |
|---|---|
| `Column` / `Row` | Hijos en vertical / horizontal |
| `Stack` + `Positioned` | Superponer widgets |
| `Container` | Caja con tamaño, color, borde, margen, padding |
| `Padding` | Espacio interno |
| `SizedBox` | Tamaño fijo o espacio entre widgets (`SizedBox(height: 16)`) |
| `Center` / `Align` | Centrar / alinear |
| `Expanded` / `Flexible` | Ocupar el espacio restante dentro de `Row`/`Column` |
| `Wrap` | Como `Row` pero salta de línea |
| `ListView` / `ListView.builder` | Lista con scroll (`.builder` para listas largas) |
| `GridView` | Cuadrícula |
| `SingleChildScrollView` | Hacer scroll a un contenido que no cabe |
| `LayoutBuilder` / `MediaQuery` | Adaptar el diseño al tamaño de pantalla |

### Contenido
| Widget | Para qué |
|---|---|
| `Text` | Texto |
| `Icon` | Icono (`Icons.home`, `CupertinoIcons.heart`) |
| `Image.asset` / `Image.network` | Imagen local / de internet |
| `CircleAvatar` | Foto de perfil redonda |
| `Card` / `ListTile` | Tarjeta / fila de lista estándar |
| `CircularProgressIndicator` | Indicador de carga |

### Interacción

> 📂 **En este proyecto:** botones, controles, diálogos y SnackBars en [widgets_screen.dart](../lib/features/basics/widgets_screen.dart); formularios completos en [forms_screen.dart](../lib/features/intermediate/forms_screen.dart).
| Widget | Para qué |
|---|---|
| `ElevatedButton`, `FilledButton`, `TextButton`, `OutlinedButton`, `IconButton` | Botones |
| `TextField` / `TextFormField` + `Form` | Campos de texto y formularios con validación |
| `Checkbox`, `Switch`, `Radio`, `Slider` | Controles |
| `GestureDetector` / `InkWell` | Detectar toques en cualquier widget |
| `showDialog`, `showModalBottomSheet`, `ScaffoldMessenger.of(context).showSnackBar` | Diálogos, hojas inferiores, mensajes |

> 📚 Catálogo visual completo: [docs.flutter.dev/ui/widgets](https://docs.flutter.dev/ui/widgets)

### Ejemplo: tarjeta de producto

> 📂 **En este proyecto:** un widget reutilizable real: [DemoSection](../lib/core/widgets/demo_scaffold.dart#L107 "→ class DemoSection") (lo usan todas las demos).
```dart
class ProductoCard extends StatelessWidget {
  const ProductoCard({super.key, required this.nombre, required this.precio, this.onTap});

  final String nombre;
  final double precio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shopping_bag),
        title: Text(nombre),
        subtitle: Text('\$${precio.toStringAsFixed(2)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

---

## 4. Navegación entre pantallas

> 📂 **En este proyecto:** [todas las rutas](../lib/core/router/app_router.dart#L70 "→ final routerProvider") · [demo de navegación](../lib/features/intermediate/navigation_screens.dart) · [Navigator.push clásico](../lib/features/intermediate/navigation_screens.dart#L107 "→ MaterialPageRoute<void>(") .

### Opción simple: `Navigator`
```dart
// Ir a otra pantalla
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const DetalleScreen(id: 42)),
);

// Volver atrás (opcionalmente devolviendo un valor)
Navigator.of(context).pop(resultado);

// Reemplazar la pantalla actual (ej. tras el login)
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (_) => const HomeScreen()),
);
```

### Opción recomendada para apps reales: [`go_router`](https://pub.dev/packages/go_router)
```bash
flutter pub add go_router
```
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/producto/:id',
      builder: (context, state) => DetalleScreen(id: state.pathParameters['id']!),
    ),
  ],
);

// En main/app:
MaterialApp.router(routerConfig: router);

// Navegar:
context.go('/producto/42');   // reemplaza el historial
context.push('/producto/42'); // apila
context.pop();
```
Ventajas: URLs, deep links, redirecciones (ej. a login si no hay sesión), navegación anidada con pestañas.

### Lección: de `Navigator.push` a rutas declarativas

**El problema.** Con `Navigator.push` la pantalla destino se construye dentro del botón que navega (`MaterialPageRoute(builder: ...)`). La app no tiene un "mapa" de pantallas: no hay una dirección como `/producto/42`, así que un enlace externo no sabe qué pantalla abrir, no puedes saber ni restaurar "dónde estás", y cada botón repite su `builder`.

**La idea.** En vez de *ordenar* "apila esta pantalla" (imperativo), declaras **una vez** la tabla *dirección → pantalla* y navegar es *decir una dirección* (declarativo). Eso es el `GoRouter` de arriba. Así se usa desde dos pantallas:

```dart
import 'package:go_router/go_router.dart';

class ListaScreen extends StatelessWidget {
  const ListaScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lista')),
        body: Column(
          children: [
            TextButton(
              onPressed: () => context.go('/producto/42'),
              child: const Text('go'),
            ),
            TextButton(
              onPressed: () => context.push('/producto/42'),
              child: const Text('push'),
            ),
          ],
        ),
      );
}

class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key, required this.id});
  final String id; // llega desde la URL: /producto/:id

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: Text('Producto $id')));
}
```

**`go` o `push`.** Con las dos rutas hermanas de arriba (`/` y `/producto/:id`):

| Llamada | Qué hace | Resultado |
|---|---|---|
| `context.go('/producto/42')` | Salta a esa dirección y **reemplaza** el historial | El detalle no tiene botón "atrás" |
| `context.push('/producto/42')` | **Apila** la pantalla encima de la actual | El botón "atrás" vuelve a la lista |

Regla práctica: `push` para "abrir un detalle y poder volver"; `go` para "ir a un destino" (cambiar de pestaña, tras el login).

**Parámetros.** `:id` en la ruta llega como `state.pathParameters['id']` (siempre un `String`: conviértelo con `int.parse` si lo necesitas). Los de consulta (`/buscar?q=pan`) se leen con `state.uri.queryParameters['q']`.

**¿Y si la pantalla exige sesión?** Una función `redirect` del router decide, antes de mostrar nada, si mandas al usuario a otra dirección (por ejemplo `/login`). Mira [la del proyecto](../lib/core/router/app_router.dart#L98 "→ redirect: (context, state)") y la configuración completa en [11 §1](11-configuraciones-avanzadas.md#1-navegación-con-go_router).

---

## 5. Gestión de estado

> 📂 **En este proyecto:** `setState` en [CounterScreen](../lib/features/basics/counter_screen.dart#L73 "→ void _increment") · Riverpod `Notifier` en [TodosController](../lib/features/todos/todos_controller.dart#L33 "→ class TodosController extends Notifier") · `FutureProvider` en [postsProvider](../lib/features/posts/posts_repository.dart#L56 "→ final postsProvider") .

"Estado" = datos que, al cambiar, deben redibujar la interfaz.

| Nivel | Solución | Cuándo |
|---|---|---|
| 1 | `setState` | Estado local de **un** widget (contador, checkbox, campo de texto) |
| 2 | `ValueNotifier` / `ChangeNotifier` + `ListenableBuilder` | Compartir un poco de estado sin paquetes |
| 3 | [**Riverpod**](https://riverpod.dev) (`flutter_riverpod`) | ⭐ Recomendado: estado global, caché, async, testeable |
| 3 | [**Bloc / Cubit**](https://bloclibrary.dev) (`flutter_bloc`) | Muy usado en empresas; separación estricta eventos → estados |
| 3 | [**Provider**](https://pub.dev/packages/provider) | Más antiguo y sencillo; base de muchos tutoriales |

**Consejo**: empieza con `setState`. Cuando dos pantallas necesiten los mismos datos, pasa a Riverpod o Bloc (elige uno y aprende ese bien).

### Lección: estado local, estado compartido y *lifting state up*

- **Estado local:** lo usa un solo widget (un checkbox, un contador). `setState` basta.
- **Estado compartido:** lo leen o cambian **dos o más** widgets. Ya no puede vivir dentro de uno de ellos.

La primera solución es **subir el estado** (*lifting state up*): lo guarda el ancestro común, lo baja a los hijos como parámetro y los hijos avisan de los cambios con un callback.

```dart
class Padre extends StatefulWidget {
  const Padre({super.key});

  @override
  State<Padre> createState() => _PadreState();
}

class _PadreState extends State<Padre> {
  int _valor = 0; // el estado vive en el ancestro común

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Mostrador(valor: _valor), // baja como parámetro
          Botonera(onIncrementar: () => setState(() => _valor++)), // sube con un callback
        ],
      );
}

class Mostrador extends StatelessWidget {
  const Mostrador({super.key, required this.valor});
  final int valor;

  @override
  Widget build(BuildContext context) => Text('Valor: $valor');
}

class Botonera extends StatelessWidget {
  const Botonera({super.key, required this.onIncrementar});
  final VoidCallback onIncrementar;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onIncrementar, child: const Text('Sumar'));
}
```

**Dónde duele.** Con dos hijos directos funciona de maravilla. Pero si `Mostrador` está cinco niveles más abajo, **cada widget intermedio** debe recibir y reenviar `valor` y `onIncrementar` aunque no los use (*prop drilling*), y cada `setState` reconstruye todo el subárbol del padre. Y si otra pantalla necesita el mismo dato, hay que subirlo hasta la raíz.

### Lección: por qué Riverpod

Riverpod saca el estado **fuera del árbol de widgets**: lo declaras en un *provider* y cualquier widget lo lee directamente, sin pasarlo por los de en medio.

| | Subir el estado | Riverpod |
|---|---|---|
| ¿Dónde vive? | En un `State` de un ancestro | En un provider, fuera del árbol |
| ¿Cómo llega al widget? | Parámetros que pasan por todos los intermedios | `ref` en el propio widget |
| ¿Quién se reconstruye? | Todo el subárbol del padre | Solo los widgets que observan ese provider |
| ¿Se puede probar sin widgets? | No | Sí (ver [07 §3](07-pruebas-y-calidad.md#3-prueba-unitaria)) |

### Ejemplo mínimo con Riverpod
```bash
flutter pub add flutter_riverpod
```
```dart
final contadorProvider = NotifierProvider<ContadorNotifier, int>(ContadorNotifier.new);

class ContadorNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void incrementar() => state++;
}

void main() => runApp(const ProviderScope(child: MyApp()));

class ContadorTexto extends ConsumerWidget {
  const ContadorTexto({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valor = ref.watch(contadorProvider);
    return TextButton(
      onPressed: () => ref.read(contadorProvider.notifier).incrementar(),
      child: Text('$valor'),
    );
  }
}
```

### Lección: `Provider`, `NotifierProvider`, `ref.watch` y `ref.read`

| Tipo | Para qué | Ejemplo |
|---|---|---|
| `Provider` | Un valor que **solo se lee** (un objeto o algo calculado) | un cliente HTTP |
| `NotifierProvider` | Estado que **cambia con métodos** | el contador de arriba |

(No lo confundas con el paquete `provider`, otro paquete distinto.) La lista completa de tipos está en [11 §2](11-configuraciones-avanzadas.md#2-gestión-de-estado-con-riverpod-3).

Y así quedan dos widgets que no se conocen y comparten el mismo contador, sin parámetros:

```dart
class Mostrador extends ConsumerWidget {
  const Mostrador({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Text('Valor: ${ref.watch(contadorProvider)}'); // observa: redibuja al cambiar
}

class Botonera extends ConsumerWidget {
  const Botonera({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ElevatedButton(
        onPressed: () => ref.read(contadorProvider.notifier).incrementar(), // solo actúa
        child: const Text('Sumar'),
      );
}
```

- **`ref.watch`** dentro de `build`: "quiero este valor **y** que me redibujes cuando cambie".
- **`ref.read`** dentro de callbacks (`onPressed`): "dame el valor o el notifier **ahora**, una vez". Si lo usas en `build`, el widget **no se redibuja** cuando el valor cambia.

Las demás reglas (`ref.listen`, `.select`, `ref.onDispose`) están en [11 §2](11-configuraciones-avanzadas.md#2-gestión-de-estado-con-riverpod-3).

---

## 6. Paquetes (pub.dev)

> 📂 **En este proyecto:** paquetes instalados y para qué se usa cada uno: [pubspec.yaml](../pubspec.yaml#L62 "→ go_router:") .

Busca en [pub.dev](https://pub.dev). Antes de elegir uno revisa: **likes**, **pub points**, **popularidad**, fecha de la última versión y que soporte **Android e iOS**.

```bash
flutter pub add <paquete>        # añadir
flutter pub remove <paquete>     # quitar
flutter pub outdated             # ver actualizaciones
```

### Paquetes más usados

> 📊 **Investigación completa con datos reales de pub.dev**, demanda laboral y cuándo elegir cada uno: [12 · Librerías más usadas y demandadas](12-librerias-mas-usadas.md).
| Necesidad | Paquete |
|---|---|
| Peticiones HTTP | `http` (simple) · `dio` (avanzado: interceptores, timeouts) |
| Navegación | `go_router` |
| Estado | `flutter_riverpod` · `flutter_bloc` · `provider` |
| Guardar datos simples (clave-valor) | `shared_preferences` |
| Guardar datos sensibles (tokens) | `flutter_secure_storage` |
| Base de datos local | `drift` · `sqflite` · `hive_ce` |
| Modelos / JSON | `json_serializable` + `json_annotation` · `freezed` |
| Imágenes de internet con caché | `cached_network_image` |
| SVG | `flutter_svg` |
| Iconos de la app | `flutter_launcher_icons` (dev) |
| Pantalla de carga nativa | `flutter_native_splash` (dev) |
| Fuentes de Google | `google_fonts` |
| Fechas y traducciones | `intl` |
| Permisos | `permission_handler` |
| Cámara / galería | `image_picker` · `camera` |
| Ubicación / mapas | `geolocator` · `google_maps_flutter` |
| Abrir enlaces | `url_launcher` |
| Compartir | `share_plus` |
| Info del dispositivo/app | `device_info_plus` · `package_info_plus` |
| Backend completo | `firebase_core`, `firebase_auth`, `cloud_firestore` · `supabase_flutter` |
| Notificaciones | `firebase_messaging` · `flutter_local_notifications` |
| Variables de entorno | `--dart-define` (sin paquete) · `envied` |

> Paquetes con código nativo (cámara, ubicación…) requieren **detener y volver a ejecutar** la app tras instalarlos ([hot reload no basta: ver 04, Paso 5](04-ejecutar-y-simular.md#paso-5--desarrollar-con-hot-reload)), y a menudo añadir **permisos** (ver sección 9).

---

## 7. Assets: imágenes y fuentes

1. Crea las carpetas:
   ```
   assets/images/logo.png
   assets/fonts/Poppins-Regular.ttf
   assets/fonts/Poppins-Bold.ttf
   ```
2. Regístralas en [`pubspec.yaml`](../pubspec.yaml) (dentro de `flutter:`, con 2 espacios):
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - assets/images/          # toda la carpeta (no incluye subcarpetas)
     fonts:
       - family: Poppins
         fonts:
           - asset: assets/fonts/Poppins-Regular.ttf
           - asset: assets/fonts/Poppins-Bold.ttf
             weight: 700
   ```
3. `flutter pub get` y **hot restart** (`R`).
4. Úsalas:
   ```dart
   Image.asset('assets/images/logo.png', width: 120)
   Text('Hola', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold))
   // o para toda la app:
   ThemeData(fontFamily: 'Poppins')
   ```

**Imágenes para varias densidades**: `assets/images/logo.png`, `assets/images/2.0x/logo.png`, `assets/images/3.0x/logo.png` → Flutter elige la adecuada.

---

## 8. Consumir una API (HTTP + JSON)

> 📂 **En este proyecto:** versión completa y robusta en [api_client.dart](../lib/core/network/api_client.dart#L60 "→ Future<Object?> getJson") → [posts_repository.dart](../lib/features/posts/posts_repository.dart#L37 "→ Future<List<Post>> fetchPosts") → [posts_screens.dart](../lib/features/posts/posts_screens.dart#L54 "→ postsAsync.when") (demo *API REST*).

```bash
flutter pub add http
```
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Post {
  final int id;
  final String titulo;
  const Post({required this.id, required this.titulo});

  factory Post.fromJson(Map<String, dynamic> json) =>
      Post(id: json['id'] as int, titulo: json['title'] as String);
}

Future<List<Post>> obtenerPosts() async {
  final resp = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
  if (resp.statusCode != 200) {
    throw Exception('Error ${resp.statusCode}');
  }
  final lista = jsonDecode(resp.body) as List<dynamic>;
  return lista.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
}
```

Mostrarlo con `FutureBuilder`:
```dart
FutureBuilder<List<Post>>(
  future: _futuroPosts, // créalo en initState, NO dentro de build
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
    final posts = snapshot.data!;
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (_, i) => ListTile(title: Text(posts[i].titulo)),
    );
  },
)
```

> ⚠️ **Android en release necesita el permiso INTERNET** (en debug ya viene): cómo declararlo en la [sección 9](#9-permisos-nativos).
> ⚠️ iOS bloquea `http://` (sin s) por defecto. Usa siempre `https://`.

---

## 9. Permisos nativos

> 📂 **En este proyecto:** [permiso INTERNET ya declarado](../android/app/src/main/AndroidManifest.xml#L31 "→ android.permission.INTERNET") para la demo de API REST.

Cuando un paquete accede a hardware o datos del usuario, hay que **declararlo** en cada plataforma.

### Android → [`android/app/src/main/AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml)
Dentro de `<manifest>`, **antes** de `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS → [`ios/Runner/Info.plist`](../ios/Runner/Info.plist)
Cada permiso necesita un **texto explicativo** (Apple rechaza la app si falta o es genérico):
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos la cámara para tomar tu foto de perfil.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a tus fotos para elegir una imagen de perfil.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Usamos tu ubicación para mostrarte tiendas cercanas.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos el micrófono para grabar notas de voz.</string>
```

La documentación de cada paquete en pub.dev indica qué permisos requiere.

---

## 10. Tema, colores y modo oscuro

> 📂 **En este proyecto:** [AppTheme](../lib/core/theme/app_theme.dart#L27 "→ abstract final class AppTheme") · [extensión de tema propia](../lib/core/theme/app_theme.dart#L77 "→ class LevelColors") · [aplicado en MaterialApp](../lib/app.dart#L47 "→ theme: AppTheme.light()") · [selector en Ajustes](../lib/features/settings/settings_screen.dart#L48 "→ SegmentedButton<ThemeMode>") .

```dart
MaterialApp(
  theme: ThemeData(
    // Material 3 ya viene activado por defecto (desde Flutter 3.16).
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
  ),
  themeMode: ThemeMode.system, // sigue el ajuste del teléfono
);

// Usar colores/estilos del tema en cualquier widget:
final colores = Theme.of(context).colorScheme;
final textos = Theme.of(context).textTheme;
Text('Hola', style: textos.headlineMedium?.copyWith(color: colores.primary));
```

Temas de componentes, `ThemeExtension` y modo oscuro persistido: [11 §3](11-configuraciones-avanzadas.md#3-tema-avanzado).

---

## 11. Diseño adaptable (diferentes tamaños de pantalla)

> 📂 **En este proyecto:** [MediaQuery](../lib/features/advanced/responsive_screen.dart#L36 "→ MediaQuery.sizeOf") · [LayoutBuilder con breakpoints](../lib/features/advanced/responsive_screen.dart#L83 "→ final columns =") · [widgets .adaptive](../lib/features/advanced/responsive_screen.dart#L137 "→ Switch.adaptive(") .

```dart
final ancho = MediaQuery.sizeOf(context).width;
final esTablet = ancho >= 600;

LayoutBuilder(
  builder: (context, constraints) => constraints.maxWidth > 600
      ? const VistaTablet()
      : const VistaMovil(),
);
```

### Material (Android) vs Cupertino (iOS)
Flutter dibuja la **misma** interfaz en las dos plataformas. Si quieres un aspecto nativo en cada una:
```dart
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';

Platform.isIOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator();
```
Muchos widgets tienen constructor adaptable: `Switch.adaptive`, `Slider.adaptive`, `CircularProgressIndicator.adaptive()`, `AlertDialog.adaptive`.

---

## 12. Traducciones (internacionalización)

> 📂 **En este proyecto:** ya está configurado: [l10n.yaml](../l10n.yaml) · [app_es.arb](../lib/l10n/app_es.arb) · [app_en.arb](../lib/l10n/app_en.arb) · [delegates en MaterialApp](../lib/app.dart#L55 "→ localizationsDelegates:") · [demo](../lib/features/intermediate/localization_screen.dart). Guía paso a paso: [docs/11 §4](11-configuraciones-avanzadas.md#4-internacionalización-i18n-con-gen-l10n).

1. `flutter pub add flutter_localizations --sdk=flutter` y `flutter pub add intl`.
2. En `pubspec.yaml` → `flutter: generate: true`.
3. Crea `l10n.yaml` y archivos `lib/l10n/app_es.arb`, `app_en.arb`.
4. `flutter gen-l10n` (o se genera al ejecutar).
5. Usa `AppLocalizations.of(context)!.saludo`.

Guía oficial: [docs.flutter.dev/ui/accessibility-and-internationalization/internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

---

## 13. Ruta de práctica sugerida (proyectos)

> 📂 **En este proyecto:** los proyectos 1 (contador) y 2 (tareas con guardado) ya están hechos en la app: [counter_screen.dart](../lib/features/basics/counter_screen.dart) y [lib/features/todos/](../lib/features/todos/). La parte de API del 3 está en [lib/features/posts/](../lib/features/posts/).

1. ✅ **Contador** (este proyecto): `StatefulWidget`, `setState`, hot reload.
2. 📝 **Lista de tareas**: `TextField`, `ListView.builder`, `Checkbox`, `shared_preferences` para guardar.
3. 🌦️ **App del clima**: `http`, JSON, `FutureBuilder`, permisos de ubicación.
4. 🛒 **Catálogo de productos**: varias pantallas con `go_router`, Riverpod o Bloc, imágenes de red.
5. 💬 **Chat o red social**: Firebase Auth + Firestore, `StreamBuilder`, notificaciones.
6. 🚀 **Publica** una de ellas en TestFlight y Google Play (pruebas internas) → [08 · Compilar y publicar](08-compilar-y-publicar.md).

---

## ✅ Comprueba que entendiste

1. ¿Por qué `build` debe ser rápido y no hacer peticiones HTTP?
   <details><summary>Respuesta</summary>

   Porque Flutter lo ejecuta muchas veces (cada `setState`, cambio de tema, rotación). Crea los `Future` en `initState` o en tu gestor de estado (§3, §8).

   </details>
2. ¿Cuándo basta `setState` y cuándo conviene Riverpod?
   <details><summary>Respuesta</summary>

   `setState` para estado local de un widget. Cuando dos o más widgets (o pantallas) necesitan los mismos datos, súbelos o usa Riverpod para no pasar parámetros por todos los intermedios (§5).

   </details>
3. ¿Qué diferencia hay entre `context.go` y `context.push`?
   <details><summary>Respuesta</summary>

   `go` reemplaza el historial y salta a esa dirección; `push` apila la pantalla encima y conserva el botón "atrás" (§4).

   </details>
4. ¿Qué pasa si usas `ref.read` dentro de `build` en lugar de `ref.watch`?
   <details><summary>Respuesta</summary>

   El widget lee el valor una vez pero no se redibuja cuando cambia (§5).

   </details>
5. ¿Qué permiso falta en Android si tu app release no puede usar internet?
   <details><summary>Respuesta</summary>

   `android.permission.INTERNET` en `AndroidManifest.xml`; en debug ya viene incluido (§9).

   </details>

## 🏋️ Reto

**Límite en el contador.** Desactiva el botón `+` cuando el contador llegue a 20 (igual que `−` está desactivado en 0). Archivo: [`counter_screen.dart`](../lib/features/basics/counter_screen.dart).

- ✅ **Cómo saber que lo lograste:** `flutter test exercises/e01_contador_limite_test.dart` pasa a verde.
- 💡 **Pista:** mira cómo el botón `−` recibe `onPressed: null` cuando `_count == 0`; un botón con `onPressed: null` aparece desactivado.
- 🔑 **Solución (inténtalo antes):** [e01_contador_limite](../exercises/solutions/e01_contador_limite.md)

## ➡️ Siguiente paso

Continúa con **[16 · Cómo piensa Flutter](16-como-piensa-flutter.md)**: ya sabes construir pantallas; ahora entenderás *por qué* Flutter se comporta así (árboles, restricciones, rebuilds). Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).
