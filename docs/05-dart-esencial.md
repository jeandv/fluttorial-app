# 05 · Dart esencial (lo mínimo para empezar)

> Anterior: [04 · Ejecutar y simular](04-ejecutar-y-simular.md) · Volver al [índice](../README.md) · Siguiente: [06 · Construir la app](06-construir-la-app.md)

Flutter se programa en **Dart**. Si conoces JavaScript, Java, Kotlin, Swift o C#, Dart te resultará familiar. Puedes practicar sin instalar nada en [dartpad.dev](https://dartpad.dev).

---

## 1. Variables y tipos

```dart
var nombre = 'Jean';          // tipo inferido (String)
String ciudad = 'Caracas';    // tipo explícito
int edad = 30;
double precio = 9.99;
bool activo = true;

final hoy = DateTime.now();   // se asigna UNA vez (en tiempo de ejecución)
const pi = 3.1416;            // constante en tiempo de compilación

dynamic cualquiera = 1;       // desactiva la comprobación de tipos (evítalo)
```

**Regla práctica**: usa `final` por defecto, `var` solo si la variable va a cambiar, y `const` para valores fijos (también en widgets: `const Text('Hola')` mejora el rendimiento).

### Strings
```dart
final saludo = 'Hola, $nombre';             // interpolación
final info = 'Tienes ${edad + 1} años';     // expresiones
final multilinea = '''
Línea 1
Línea 2
''';
```

---

## 2. Null safety (seguridad ante nulos)

> 📂 **En este proyecto:** [`??` con valor por defecto](../lib/features/intermediate/navigation_screens.dart#L46 "→ result ?? 'ninguno") · [`?.` y `??` juntos](../lib/features/intermediate/async_screen.dart#L94 "→ _timer?.isActive ?? false") · [tipo nullable `Locale?`](../lib/core/settings/settings_controller.dart#L38 "→ final Locale? locale") .

```dart
String nombre = 'Ana';     // NUNCA puede ser null
String? apodo;             // PUEDE ser null (el ? lo permite)

print(apodo?.length);      // ?.  → si es null, devuelve null en vez de fallar
print(apodo ?? 'Sin apodo'); // ?? → valor por defecto si es null
apodo ??= 'Anita';         // ??= → asigna solo si es null
print(apodo!.length);      // !  → "confía en mí, no es null" (si lo es, la app falla)

late String token;         // se inicializará más tarde, antes de usarse
```

---

## 3. Colecciones

> 📂 **En este proyecto:** [`for` + `if/else` dentro de una lista](../lib/features/todos/todos_controller.dart#L75 "→ if (t.id == id") t.copyWith) · [spread `...`](../lib/features/todos/todos_controller.dart#L68 "→ state = [todo, ...state]") · [`where`](../lib/features/todos/todos_controller.dart#L126 "→ todos.where((t") => !t.done)) · [`map` + `toList`](../lib/features/posts/posts_repository.dart#L41 "→ list.map") .

```dart
// Lista (array)
final frutas = ['manzana', 'pera'];
frutas.add('uva');
print(frutas[0]);         // manzana
print(frutas.length);     // 3

// Mapa (diccionario / objeto)
final usuario = {'nombre': 'Jean', 'edad': 30};
print(usuario['nombre']);

// Conjunto (sin repetidos)
final ids = {1, 2, 3};

// Operaciones típicas
final mayusculas = frutas.map((f) => f.toUpperCase()).toList();
final conA = frutas.where((f) => f.contains('a')).toList();
final total = [1, 2, 3].reduce((a, b) => a + b);

// Colecciones con if/for (muy usado en Flutter para listas de widgets)
final items = [
  'Inicio',
  if (activo) 'Perfil',
  for (final f in frutas) 'Fruta: $f',
];

// Spread
final todas = [...frutas, 'kiwi'];
```

---

## 4. Funciones

> 📂 **En este proyecto:** [parámetros con nombre `required`](../lib/core/widgets/demo_scaffold.dart#L26 "→ required this.explanation") · [función local](../lib/features/basics/layout_screen.dart#L33 "→ Widget box(") · [callbacks como parámetro](../lib/features/advanced/native_channel.dart#L73 "→ Future<void> _call(Future<void> Function(") action) .

```dart
int sumar(int a, int b) => a + b;              // arrow function

void saludar(String nombre, [String? saludo]) { // parámetro posicional opcional
  print('${saludo ?? 'Hola'}, $nombre');
}

// Parámetros con nombre (los usa TODO Flutter)
void crearUsuario({required String nombre, int edad = 18}) {}
crearUsuario(nombre: 'Jean', edad: 30);

// Funciones como valores (callbacks)
void ejecutar(void Function() accion) => accion();
ejecutar(() => print('¡Hecho!'));
```

---

## 5. Clases

> 📂 **En este proyecto:** [clase inmutable con `copyWith`](../lib/features/todos/todo.dart#L29 "→ Todo copyWith") · [factory `fromJson`](../lib/features/todos/todo.dart#L44 "→ factory Todo.fromJson") · [`==` y `hashCode`](../lib/features/posts/post.dart#L62 "→ bool operator ==") · [getter](../lib/core/settings/settings_controller.dart#L49 "→ SharedPreferencesWithCache get _prefs") .

```dart
class Producto {
  final String nombre;
  final double precio;

  // Constructor con parámetros con nombre
  const Producto({required this.nombre, required this.precio});

  // Constructor "factory" para crear desde JSON
  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        nombre: json['nombre'] as String,
        precio: (json['precio'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'nombre': nombre, 'precio': precio};

  // Getter
  String get precioFormateado => '\$${precio.toStringAsFixed(2)}';

  // copyWith: patrón típico para objetos inmutables
  Producto copyWith({String? nombre, double? precio}) =>
      Producto(nombre: nombre ?? this.nombre, precio: precio ?? this.precio);

  @override
  String toString() => 'Producto($nombre, $precio)';
}
```

### Herencia, interfaces y mixins

> 📂 **En este proyecto:** [`extends` + mixin `with`](../lib/features/advanced/animations_screen.dart#L36 "→ with SingleTickerProviderStateMixin") · [`implements Exception`](../lib/core/network/api_client.dart#L38 "→ class ApiException implements Exception") · [`extends ThemeExtension`](../lib/core/theme/app_theme.dart#L77 "→ class LevelColors extends ThemeExtension") .
```dart
abstract class Animal {
  String hacerSonido();
}

class Perro extends Animal {
  @override
  String hacerSonido() => 'Guau';
}

mixin Volador {
  void volar() => print('Volando');
}

class Pato extends Animal with Volador {
  @override
  String hacerSonido() => 'Cuac';
}
```

### Enums

> 📂 **En este proyecto:** [DemoLevel](../lib/features/catalog/demo_catalog.dart#L24 "→ enum DemoLevel") · [TodoFilter](../lib/features/todos/todo.dart#L64 "→ enum TodoFilter") · [buscar un enum por nombre](../lib/core/settings/settings_controller.dart#L60 "→ ThemeMode.values.firstWhere") .
```dart
enum Estado { cargando, exito, error }

final e = Estado.cargando;
switch (e) {
  case Estado.cargando: print('...');
  case Estado.exito:    print('OK');
  case Estado.error:    print('Falló');
}
```

---

## 6. Asincronía: `Future`, `async`, `await`, `Stream`

> 📂 **En este proyecto:** [async/await + try/catch/finally](../lib/features/intermediate/async_screen.dart#L73 "→ Future<void> _load") · [Stream.periodic](../lib/features/intermediate/async_screen.dart#L55 "→ Stream.periodic") · [timeout de un Future](../lib/core/network/api_client.dart#L66 "→ .timeout(_timeout)") · [`async` en main](../lib/main.dart#L41 "→ Future<void> main") .

Todo lo que tarda (internet, base de datos, archivos) es **asíncrono**.

```dart
Future<String> descargarNombre() async {
  await Future.delayed(const Duration(seconds: 2)); // simula una espera
  return 'Jean';
}

Future<void> main() async {
  try {
    final nombre = await descargarNombre();
    print(nombre);
  } catch (e) {
    print('Error: $e');
  } finally {
    print('Terminado');
  }
}
```

**Stream** = varios valores en el tiempo (ej. mensajes de chat, ubicación GPS):
```dart
Stream<int> contador() async* {
  for (var i = 1; i <= 3; i++) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}

await for (final n in contador()) {
  print(n); // 1, 2, 3
}
```

---

## 7. Características modernas de Dart 3

### Records (tuplas)

> 📂 **En este proyecto:** [devolver un record](../lib/features/todos/todos_controller.dart#L81 "→ (Todo, int)? remove") · [desestructurarlo](../lib/features/todos/todos_screen.dart#L51 "→ final (item, index") = removed) · [records en un Map](../lib/features/catalog/catalog_screen.dart#L37 "→ DemoLevel.basic: (l10n.levelBasic") .
```dart
(String, int) obtenerUsuario() => ('Jean', 30);
final (nombre, edad) = obtenerUsuario();

({double lat, double lng}) ubicacion() => (lat: 10.5, lng: -66.9);
print(ubicacion().lat);
```

### Pattern matching y `switch` como expresión

> 📂 **En este proyecto:** [validar JSON con patrones](../lib/features/posts/post.dart#L40 "→ return switch (json)") · [`switch` sobre un enum](../lib/features/todos/todos_controller.dart#L124 "→ return switch (ref.watch(todoFilterProvider))") · [patrones en un `for`](../lib/features/catalog/catalog_screen.dart#L52 "→ for (final MapEntry(key: level") .
```dart
String describir(Object valor) => switch (valor) {
      int n when n < 0 => 'Negativo',
      int() => 'Entero',
      String s => 'Texto de ${s.length} letras',
      _ => 'Otra cosa',
    };
```

### Sealed classes (ideal para estados de pantalla)

> 📂 **En este proyecto:** `AsyncValue` de Riverpod es una sealed class (`AsyncData`, `AsyncError`, `AsyncLoading`); se usa en [PostsScreen](../lib/features/posts/posts_screens.dart#L54 "→ child: postsAsync.when(") .
```dart
sealed class Resultado {}
class Cargando extends Resultado {}
class Exito extends Resultado { final String datos; Exito(this.datos); }
class Fallo extends Resultado { final String error; Fallo(this.error); }

String mostrar(Resultado r) => switch (r) {
      Cargando() => 'Cargando...',
      Exito(:final datos) => datos,
      Fallo(:final error) => 'Error: $error',
    }; // el compilador avisa si olvidas un caso
```

### Dot shorthands (atajos con punto)
Desde Dart 3.10 puedes omitir el nombre del tipo cuando el contexto ya lo indica. La plantilla de `flutter create` los usa; en esta guía se escribe el nombre completo (`MainAxisAlignment.center`) para que sea más fácil de leer al aprender:
```dart
colorScheme: .fromSeed(seedColor: Colors.deepPurple), // = ColorScheme.fromSeed(...)
mainAxisAlignment: .center,                           // = MainAxisAlignment.center
```

---

## 8. Imports

```dart
import 'package:flutter/material.dart';        // paquete de Flutter
import 'package:http/http.dart' as http;       // paquete externo con alias
import 'package:mi_primera_app/models/producto.dart'; // archivo de TU proyecto
import '../widgets/boton.dart';                // ruta relativa
```

---

## 9. Convenciones de estilo

> 📂 **En este proyecto:** las reglas de estilo están en [analysis_options.yaml](../analysis_options.yaml); `flutter analyze` las comprueba y la [CI](../.github/workflows/flutter-ci.yml#L41 "→ dart format") verifica el formato en cada push.

| Elemento | Estilo | Ejemplo |
|---|---|---|
| Clases, enums, typedefs | `UpperCamelCase` | `ProductoCard` |
| Variables, funciones, parámetros | `lowerCamelCase` | `precioTotal` |
| Archivos y carpetas | `snake_case` | `producto_card.dart` |
| Privado (solo visible en el archivo) | prefijo `_` | `_contador`, `_MiEstado` |
| Constantes | `lowerCamelCase` | `const maxIntentos = 3;` |

`dart format .` aplica el formato oficial automáticamente. Pon **comas finales** (`,`) en listas de argumentos largas para que el formateador las separe en varias líneas.

---

📚 Más: [Tour del lenguaje Dart](https://dart.dev/language) · [Effective Dart](https://dart.dev/effective-dart) · [DartPad](https://dartpad.dev)
