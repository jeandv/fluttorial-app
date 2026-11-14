# 07 · Pruebas y calidad de código

> Anterior: [06 · Construir la app](06-construir-la-app.md) · Volver al [índice](../README.md) · Siguiente: [08 · Compilar y publicar](08-compilar-y-publicar.md)

> 🎯 **Aprenderás:** escribir pruebas unitarias y de widget, simular dependencias y dejar el código listo para cada commit.
> 📋 **Necesitas antes:** [06 · Construir la app](06-construir-la-app.md) y [10 · Funcionalidades de la app](10-funcionalidades-de-la-app.md) (las pruebas usan sus pantallas).
> ⏱️ **Tiempo:** ~30 min de lectura + ~30 min practicando

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

> 📂 **En este proyecto:**
> - [lógica de tareas con `ProviderContainer`](../test/features/todos/todos_controller_test.dart#L26 "→ ProviderContainer createContainer") (un contenedor de Riverpod para probar estado sin widgets; → lo verás en [11 §2](11-configuraciones-avanzadas.md#2-gestión-de-estado-con-riverpod-3))
> - [función pura](../test/features/advanced/isolates_test.dart#L14 "→ countPrimes cuenta") (`countPrimes` es el cálculo pesado que la demo de isolates ejecuta con `compute`; → lo verás en [10 · Funcionalidades](10-funcionalidades-de-la-app.md))
> - [modelo JSON](../test/features/posts/posts_repository_test.dart#L30 "→ group('Post.fromJson'")
> - [Luhn: el mismo caso del ejemplo](../test/features/payments/payments_test.dart#L26 "→ 'luhnValid'")

```dart
// test/features/payments/luhn_ejemplo_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_primera_app/features/payments/card_utils.dart';

void main() {
  group('luhnValid', () {
    test('acepta una tarjeta de prueba válida', () {
      expect(luhnValid('4242 4242 4242 4242'), isTrue);
    });

    test('rechaza un número con un dígito cambiado', () {
      expect(luhnValid('4242 4242 4242 4241'), isFalse);
    });
  });
}
```

Una prueba unitaria no dibuja nada ni necesita simulador: llama a una función con unos datos y comprueba el resultado. Ejecútala con `flutter test test/features/payments/luhn_ejemplo_test.dart`.

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
   import 'package:mi_primera_app/core/storage/preferences.dart';

   import '../test/helpers/test_helpers.dart'; // reutiliza pumpApp

   void main() {
     IntegrationTestWidgetsFlutterBinding.ensureInitialized();

     testWidgets('abre el contador desde el catálogo y suma 1', (tester) async {
       // Arranca la app completa, con el idioma en español.
       await pumpApp(tester, initialData: {PrefsKeys.locale: 'es'});

       await tester.tap(find.text('Contador (setState)'));
       await tester.pumpAndSettle();

       await tester.tap(find.byIcon(Icons.add));
       await tester.pumpAndSettle();
       expect(find.text('1'), findsOneWidget);
     });
   }
   ```
   > ⚠️ No basta `pumpWidget(const MyApp())`: `MyApp` necesita un `ProviderScope` con las preferencias inyectadas, igual que hace [`main()`](../lib/main.dart#L41 "→ Future<void> main"). [`pumpApp`](../test/helpers/test_helpers.dart#L41 "→ Future<void> pumpApp") ya lo prepara (y usa preferencias en memoria, sin tocar el disco del teléfono).
3. Con un simulador encendido:
   ```bash
   flutter test integration_test -d <id-dispositivo>
   ```

---

## 6. Simular dependencias (mocks)

> 📂 **En este proyecto:** sin paquetes extra:
> - [MockClient de http](../test/features/posts/posts_repository_test.dart#L26 "→ ApiClient fakeApi")
> - [override de un provider](../test/features/posts/posts_repository_test.dart#L88 "→ apiClientProvider.overrideWithValue") (cambiar un provider de Riverpod por una versión falsa en la prueba; → lo verás en [11 §2](11-configuraciones-avanzadas.md#2-gestión-de-estado-con-riverpod-3))
> - [almacenamiento en memoria](../test/helpers/test_helpers.dart#L36 "→ InMemorySharedPreferencesAsync.withData")

Para probar código que llama a una API **sin usar internet**, este proyecto no necesita ningún paquete extra: `package:http/testing.dart` (viene con `http`) trae `MockClient`, un cliente HTTP falso que responde lo que tú decidas.

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_primera_app/core/network/api_client.dart';
import 'package:mi_primera_app/features/posts/posts_repository.dart';

void main() {
  test('fetchPost convierte el JSON en un Post', () async {
    final api = ApiClient(
      client: MockClient(
        (request) async => http.Response(
          jsonEncode({'id': 1, 'userId': 7, 'title': 'Hola', 'body': 'Cuerpo'}),
          200,
        ),
      ),
      baseUrl: 'https://fake.api',
    );

    final post = await PostsRepository(api).fetchPost(1);

    expect(post.title, 'Hola');
  });
}
```

Si necesitas simular **cualquier clase** (no solo un cliente HTTP), el paquete más usado es `mocktail` (no está instalado en este proyecto):
```bash
flutter pub add --dev mocktail
```
```dart
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

// dentro de un test:
final api = MockApiClient();
when(() => api.getJson('/posts/1')).thenAnswer(
  (_) async => {'id': 1, 'userId': 7, 'title': 'Hola', 'body': 'Cuerpo'},
);
final post = await PostsRepository(api).fetchPost(1);
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

> 📂 **En este proyecto:**
> - [ListView.builder](../lib/features/basics/lists_screen.dart#L58 "→ ListView.builder(")
> - [child reutilizado en AnimatedBuilder](../lib/features/advanced/animations_screen.dart#L181 "→ child: const FlutterLogo")
> - [Future creado en initState](../lib/features/intermediate/async_screen.dart#L53 "→ _luckyNumber = _fetchLuckyNumber()")
> - [.select de Riverpod](../lib/features/todos/todos_screen.dart#L73 "→ todosProvider.select") (redibujar solo si cambia una parte del estado; → lo verás en [11 §2](11-configuraciones-avanzadas.md#2-gestión-de-estado-con-riverpod-3))
> - [isolates para CPU](../lib/features/advanced/isolates_screen.dart#L73 "→ await compute(countPrimes") (ejecutar un cálculo pesado en otro hilo con `compute` para no congelar la interfaz; → lo verás en [10 · Funcionalidades](10-funcionalidades-de-la-app.md))

- Usa `const` en todos los widgets que no cambian.
- Usa `ListView.builder` (no `ListView(children: [...])`) para listas largas.
- No crees `Future`s ni objetos pesados dentro de `build()` (créalos en `initState` o en tu gestor de estado).
- Divide pantallas grandes en widgets pequeños: Flutter redibuja menos.
- Libera `TextEditingController`, `AnimationController`, `StreamSubscription`… en `dispose()`.
- Mide en modo **profile** en un dispositivo real, nunca en debug.

---

## ✅ Comprueba que entendiste

1. ¿Por qué hay muchas pruebas unitarias, bastantes de widget y pocas de integración?
   <details><summary>Respuesta</summary>

   Las unitarias y de widget son rápidas y no necesitan simulador; las de integración son lentas y requieren un dispositivo (§2).

   </details>
2. ¿Qué diferencia hay entre `tester.pump()` y `tester.pumpAndSettle()`?
   <details><summary>Respuesta</summary>

   `pump()` avanza un frame (por ejemplo tras un `setState`); `pumpAndSettle()` sigue avanzando hasta que terminan las animaciones (§4).

   </details>
3. ¿Por qué no basta `pumpWidget(const MyApp())` en las pruebas de este proyecto?
   <details><summary>Respuesta</summary>

   Porque `MyApp` necesita un `ProviderScope` con las preferencias inyectadas, igual que `main()`; el helper `pumpApp` ya lo prepara (§5).

   </details>
4. ¿Cómo pruebas código que llama a una API sin usar internet?
   <details><summary>Respuesta</summary>

   Con `MockClient` de `package:http/testing.dart`, un cliente HTTP falso que responde lo que decidas; para simular cualquier otra clase, `mocktail` (§6).

   </details>
5. ¿Qué tres comandos ejecutas antes de cada commit?
   <details><summary>Respuesta</summary>

   `dart format .`, `flutter analyze` y `flutter test` (§1).

   </details>

## 🏋️ Reto

**Tus propios tests.** Escribe pruebas unitarias para [`validateExpiry`](../lib/features/payments/card_utils.dart#L114 "→ String? validateExpiry") (con `now` fijo): mes inválido, tarjeta caducada y fecha válida, sin copiar las de [`payments_test.dart`](../test/features/payments/payments_test.dart).

- ✅ **Cómo saber que lo lograste:** `flutter test` pasa a verde con tus tres casos nuevos.
- 💡 **Pista:** `validateExpiry` acepta `now:` como parámetro opcional; pásale una fecha fija (por ejemplo `DateTime(2026, 6, 1)`) para que la prueba no dependa del día en que se ejecute.

## ➡️ Siguiente paso

Continúa con **[11 · Configuraciones avanzadas](11-configuraciones-avanzadas.md)**: ya sabes probar tu código; ahora verás con más detalle el router, Riverpod, el tema y la internacionalización. Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).
