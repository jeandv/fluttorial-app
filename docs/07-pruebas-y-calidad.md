# 07 · Pruebas y calidad de código

> Anterior: [06 · Construir la app](06-construir-la-app.md) · Volver al [índice](../README.md) · Siguiente: [08 · Compilar y publicar](08-compilar-y-publicar.md)

---

## 1. Rutina antes de cada commit

> 📂 **En este proyecto:** GitHub ejecuta esta misma rutina en cada push: [flutter-ci.yml](../.github/workflows/flutter-ci.yml#L47 "→ run: flutter test") .

```bash
dart format .        # 1. formatear
flutter analyze      # 2. sin errores ni advertencias
flutter test         # 3. todas las pruebas en verde
```

Si `flutter analyze` muestra problemas que se pueden corregir solos:
```bash
dart fix --apply
```

---

## 2. Tipos de pruebas en Flutter

| Tipo | Qué prueba | Dónde | Velocidad | Necesita simulador |
|---|---|---|---|---|
| **Unitaria** | Una función o clase (lógica pura) | `test/` | ⚡ Muy rápida | No |
| **De widget** | Un widget o pantalla aislada | `test/` | ⚡ Rápida | No |
| **De integración** | La app completa, como un usuario | `integration_test/` | 🐢 Lenta | Sí |

Proporción recomendada: muchas unitarias, bastantes de widget, pocas de integración.

---

## 3. Prueba unitaria

> 📂 **En este proyecto:** [lógica de tareas con ProviderContainer](../test/features/todos/todos_controller_test.dart#L26 "→ ProviderContainer createContainer") · [función pura](../test/features/advanced/isolates_test.dart#L14 "→ countPrimes cuenta") · [modelo JSON](../test/features/posts/posts_repository_test.dart#L30 "→ group('Post.fromJson'") .

```dart
// test/models/carrito_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/models/carrito.dart';

void main() {
  group('Carrito', () {
    test('empieza vacío', () {
      expect(Carrito().total, 0);
    });

    test('suma el precio de los productos', () {
      final carrito = Carrito()..agregar(precio: 10)..agregar(precio: 5.5);
      expect(carrito.total, 15.5);
    });
  });
}
```

---

## 4. Prueba de widget

> 📂 **En este proyecto:** [pantalla suelta](../test/widget_test.dart#L30 "→ el contador empieza en 0") · [app completa navegando entre pestañas](../test/widget_test.dart#L67 "→ arranca en el catálogo") · [helper pumpApp](../test/helpers/test_helpers.dart#L41 "→ Future<void> pumpApp") .

Ver el ejemplo real comentado en [`test/widget_test.dart`](../test/widget_test.dart).

| Función | Para qué |
|---|---|
| `testWidgets('...', (tester) async {...})` | Define una prueba de widget |
| `await tester.pumpWidget(MiWidget())` | Dibuja el widget |
| `await tester.pump()` | Avanza un frame (tras un `setState`) |
| `await tester.pumpAndSettle()` | Avanza hasta que terminen las animaciones |
| `await tester.tap(finder)` | Toca un widget |
| `await tester.enterText(finder, 'texto')` | Escribe en un `TextField` |
| `await tester.drag(finder, Offset(0, -300))` | Arrastra / hace scroll |
| `find.text('Hola')` | Busca por texto |
| `find.byIcon(Icons.add)` | Busca por icono |
| `find.byType(ElevatedButton)` | Busca por tipo de widget |
| `find.byKey(const Key('boton_login'))` | Busca por `Key` (la forma más robusta) |
| `expect(finder, findsOneWidget)` | Hay exactamente uno |
| `findsNothing`, `findsWidgets`, `findsNWidgets(3)` | Ninguno / al menos uno / exactamente N |

---

## 5. Prueba de integración (en simulador)

1. Añade la dependencia:
   ```bash
   flutter pub add --dev integration_test --sdk=flutter
   ```
2. Crea `integration_test/app_test.dart`:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:integration_test/integration_test.dart';
   import 'package:mi_primera_app/main.dart';

   void main() {
     IntegrationTestWidgetsFlutterBinding.ensureInitialized();

     testWidgets('el contador sube al pulsar +', (tester) async {
       await tester.pumpWidget(const MyApp());
       await tester.tap(find.byIcon(Icons.add));
       await tester.pumpAndSettle();
       expect(find.text('1'), findsOneWidget);
     });
   }
   ```
3. Con un simulador encendido:
   ```bash
   flutter test integration_test -d <id-dispositivo>
   ```

---

## 6. Simular dependencias (mocks)

> 📂 **En este proyecto:** sin paquetes extra: [MockClient de http](../test/features/posts/posts_repository_test.dart#L26 "→ ApiClient fakeApi") + [override de un provider](../test/features/posts/posts_repository_test.dart#L88 "→ apiClientProvider.overrideWithValue") + [almacenamiento en memoria](../test/helpers/test_helpers.dart#L36 "→ InMemorySharedPreferencesAsync.withData") .

Para probar código que llama a una API sin usar internet:
```bash
flutter pub add --dev mocktail
```
```dart
class MockApi extends Mock implements ApiService {}

final api = MockApi();
when(() => api.obtenerPosts()).thenAnswer((_) async => [const Post(id: 1, titulo: 'Hola')]);
```

---

## 7. Cobertura

```bash
flutter test --coverage
# genera coverage/lcov.info
brew install lcov                       # una sola vez
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 8. Linter (`analysis_options.yaml`)

> 📂 **En este proyecto:** [analysis_options.yaml](../analysis_options.yaml#L19 "→ include: package:flutter_lints") .

El archivo [`analysis_options.yaml`](../analysis_options.yaml) activa las reglas de `flutter_lints`. Puedes añadir reglas extra:

```yaml
linter:
  rules:
    prefer_single_quotes: true
    always_declare_return_types: true
    prefer_const_constructors: true
    require_trailing_commas: true
```

Ignorar una regla puntualmente:
```dart
// ignore: avoid_print
print('debug');

// En todo el archivo:
// ignore_for_file: avoid_print
```

Catálogo de reglas: [dart.dev/lints](https://dart.dev/lints). Paquete con reglas más estrictas: `very_good_analysis`.

---

## 9. Buenas prácticas de rendimiento

> 📂 **En este proyecto:** [ListView.builder](../lib/features/basics/lists_screen.dart#L58 "→ ListView.builder(") · [child reutilizado en AnimatedBuilder](../lib/features/advanced/animations_screen.dart#L181 "→ child: const FlutterLogo") · [Future creado en initState](../lib/features/intermediate/async_screen.dart#L53 "→ _luckyNumber = _fetchLuckyNumber()") · [.select de Riverpod](../lib/features/todos/todos_screen.dart#L73 "→ todosProvider.select") · [isolates para CPU](../lib/features/advanced/isolates_screen.dart#L73 "→ await compute(countPrimes") .

- Usa `const` en todos los widgets que no cambian.
- Usa `ListView.builder` (no `ListView(children: [...])`) para listas largas.
- No crees `Future`s ni objetos pesados dentro de `build()` (créalos en `initState` o en tu gestor de estado).
- Divide pantallas grandes en widgets pequeños: Flutter redibuja menos.
- Libera `TextEditingController`, `AnimationController`, `StreamSubscription`… en `dispose()`.
- Mide en modo **profile** en un dispositivo real, nunca en debug.
