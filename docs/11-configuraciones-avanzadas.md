# 11 · Configuraciones avanzadas

> Anterior: [10 · Funcionalidades de la app](10-funcionalidades-de-la-app.md) · Volver al [índice](../README.md) · Siguiente: [12 · Librerías más usadas](12-librerias-mas-usadas.md)

> 🎯 **Aprenderás:** cómo está montada la infraestructura de la app (router, estado, tema, i18n, entornos, red) y cómo replicarla en tus proyectos.
> 📋 **Necesitas antes:** [06 · Construir la app](06-construir-la-app.md) (§4 navegación y §5 estado) y [10 · Funcionalidades de la app](10-funcionalidades-de-la-app.md).
> ⏱️ **Tiempo:** ~35 min de lectura + ~20 min practicando

Cómo está montada la "infraestructura" de esta app y cómo replicarla en tus proyectos. Cada sección enlaza al código real (los enlaces `#L` abren la línea exacta).

---

## 0. Arquitectura del proyecto

```
lib/
├── main.dart                  → arranque: preferencias + ProviderScope
├── app.dart                   → MaterialApp.router: tema, idioma, router
├── core/                      → infraestructura compartida
│   ├── config/env.dart        → variables --dart-define
│   ├── network/api_client.dart→ cliente HTTP
│   ├── router/                → go_router (rutas, redirect, pestañas)
│   ├── settings/              → tema e idioma persistidos
│   ├── storage/               → shared_preferences
│   ├── theme/                 → ThemeData claro/oscuro + ThemeExtension
│   └── widgets/               → widgets reutilizables
├── features/                  → una carpeta por funcionalidad ("feature-first")
│   ├── basics/ intermediate/ advanced/   → demos
│   ├── posts/                 → API REST (modelo, repositorio, providers, UI)
│   ├── todos/                 → tareas (modelo, controller, UI)
│   ├── auth/ settings/ shell/ catalog/
└── l10n/                      → traducciones .arb + código generado
```

**Regla de dependencias:** `features/` puede usar `core/`, pero `core/` nunca importa nada de `features/` (salvo el router, que es quien conecta las pantallas).

---

## 1. Navegación con go_router

📄 [lib/core/router/app_router.dart](../lib/core/router/app_router.dart) · [routes.dart](../lib/core/router/routes.dart) · [home_shell.dart](../lib/features/shell/home_shell.dart)

| Configuración | Dónde |
|---|---|
| Router dentro de un Provider (para leer otros providers) | [routerProvider](../lib/core/router/app_router.dart#L70 "→ final routerProvider") |
| Conectarlo a la app | [routerConfig](../lib/app.dart#L60 "→ routerConfig: router") |
| Pestañas con historial propio (`StatefulShellRoute.indexedStack`) | [StatefulShellRoute](../lib/core/router/app_router.dart#L136 "→ StatefulShellRoute.indexedStack(") |
| Barra inferior que cambia de rama (`goBranch`) | [_onTabSelected](../lib/features/shell/home_shell.dart#L31 "→ void _onTabSelected") |
| Rutas hijas (path relativo) | [contador](../lib/core/router/app_router.dart#L151 "→ path: 'contador'") |
| Parámetros de ruta y de consulta | [detalle/:id](../lib/core/router/app_router.dart#L180 "→ path: 'detalle/:id'") |
| Rutas a pantalla completa (`parentNavigatorKey`) | [login](../lib/core/router/app_router.dart#L117 "→ path: AppRoutes.login") |
| Rutas protegidas (`redirect`) | [redirect](../lib/core/router/app_router.dart#L98 "→ redirect: (context, state)") |
| Re-evaluar el redirect al cambiar la sesión (`refreshListenable`) | [authListenable](../lib/core/router/app_router.dart#L73 "→ final authListenable") |
| Página 404 | [errorBuilder](../lib/core/router/app_router.dart#L129 "→ errorBuilder:") |
| Logs de navegación en consola | [debugLogDiagnostics](../lib/core/router/app_router.dart#L93 "→ debugLogDiagnostics: true") |

### API de navegación
```dart
context.go('/tareas');                      // ir (reemplaza historial)
context.push('/ejemplos/posts/3');          // apilar
final r = await context.push<String>(ruta); // esperar resultado
context.pop('valor');                       // volver devolviendo un valor
context.canPop();                           // ¿hay pantalla anterior?
GoRouterState.of(context).uri;              // URL actual
```

### Deep links (abrir la app desde una URL)
Como cada pantalla tiene URL, solo falta registrar un esquema en cada plataforma:

**Android** → en [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L74 "→ android.intent.category.LAUNCHER"), dentro de `<activity>`:
```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="miprimeraapp" android:host="app" />
</intent-filter>
```
**iOS** → en [Info.plist](../ios/Runner/Info.plist):
```xml
<key>FlutterDeepLinkingEnabled</key><true/>
<key>CFBundleURLTypes</key>
<array><dict>
  <key>CFBundleURLSchemes</key><array><string>miprimeraapp</string></array>
</dict></array>
```
**Probar:**
```bash
xcrun simctl openurl booted "miprimeraapp://app/ejemplos/posts/3"
```
```bash
adb shell am start -a android.intent.action.VIEW -d "miprimeraapp://app/ejemplos/posts/3"
```
Para enlaces `https://` (Universal Links / App Links) también hay que publicar un archivo de verificación en tu dominio: [docs.flutter.dev/ui/navigation/deep-linking](https://docs.flutter.dev/ui/navigation/deep-linking).

---

## 2. Gestión de estado con Riverpod 3

| Tipo de provider | Para qué | Ejemplo en el proyecto |
|---|---|---|
| `Provider` | Un objeto o valor calculado | [apiClientProvider](../lib/core/network/api_client.dart#L91 "→ final apiClientProvider") · [filteredTodosProvider](../lib/features/todos/todos_controller.dart#L122 "→ final filteredTodosProvider") |
| `NotifierProvider` | Estado que cambia con métodos | [todosProvider](../lib/features/todos/todos_controller.dart#L104 "→ final todosProvider") · [settingsProvider](../lib/core/settings/settings_controller.dart#L86 "→ final settingsProvider") · [authProvider](../lib/features/auth/auth.dart#L37 "→ final authProvider") |
| `FutureProvider` | Resultado de una operación asíncrona | [postsProvider](../lib/features/posts/posts_repository.dart#L56 "→ final postsProvider") |
| `.family` | Provider con parámetro | [postProvider](../lib/features/posts/posts_repository.dart#L61 "→ final postProvider") |
| `.autoDispose` | Liberar al dejar de usarse | [postsProvider](../lib/features/posts/posts_repository.dart#L56 "→ FutureProvider.autoDispose<List<Post>>") |
| `StreamProvider` / `AsyncNotifierProvider` | Streams / estado asíncrono con métodos | (no usados aquí; misma idea) |

### Reglas de oro
1. **`ProviderScope`** envuelve la app → [main.dart](../lib/main.dart#L47 "→ ProviderScope(") .
2. **`ref.watch`** dentro de `build` (redibuja) · **`ref.read`** en callbacks (una vez) → [TodosScreen](../lib/features/todos/todos_screen.dart#L69 "→ final todos = ref.watch") .
3. **Nunca mutes el estado**: crea uno nuevo → [add](../lib/features/todos/todos_controller.dart#L68 "→ state = [todo, ...state]") .
4. **`ref.listen`** para reaccionar a un cambio **sin redibujar** (efectos: mostrar un SnackBar, navegar, avisar a otro objeto). Aquí el router lo usa para enterarse de que cambió la sesión y volver a evaluar `redirect` → [ref.listen](../lib/core/router/app_router.dart#L74 "→ ref.listen(") .
5. **`.select`** para redibujar solo si cambia una parte → [select](../lib/features/todos/todos_screen.dart#L73 "→ todosProvider.select") .
6. **`ref.onDispose`** para liberar recursos → [ApiClient](../lib/core/network/api_client.dart#L93 "→ ref.onDispose(client.close)") .

### Widgets que leen providers
| Widget | Cuándo |
|---|---|
| `ConsumerWidget` | Sin estado local → [PostsScreen](../lib/features/posts/posts_screens.dart#L33 "→ class PostsScreen extends ConsumerWidget") |
| `ConsumerStatefulWidget` | Con estado local (controladores) → [TodosScreen](../lib/features/todos/todos_screen.dart#L26 "→ class TodosScreen extends ConsumerStatefulWidget") |
| `Consumer(builder: ...)` | Solo una parte pequeña de un widget normal |

### Inyectar objetos asíncronos (patrón override)
Un provider que lanza error y se sobrescribe en `main` con el objeto ya inicializado:
[sharedPreferencesProvider](../lib/core/storage/preferences.dart#L64 "→ final sharedPreferencesProvider") → [overrideWithValue en main](../lib/main.dart#L50 "→ overrideWithValue(preferences)") → [y en los tests](../test/helpers/test_helpers.dart#L55 "→ sharedPreferencesProvider.overrideWithValue(prefs)") .

> Alternativas a Riverpod: **Bloc/Cubit** (`flutter_bloc`), **Provider**, **Signals**, **GetX** (no recomendado). Los conceptos (estado inmutable, separar lógica y UI, inyección) son los mismos.

---

## 3. Tema avanzado

📄 [lib/core/theme/app_theme.dart](../lib/core/theme/app_theme.dart)

| Configuración | Dónde |
|---|---|
| Paleta Material 3 desde un color (`ColorScheme.fromSeed`) | [_build](../lib/core/theme/app_theme.dart#L35 "→ ColorScheme.fromSeed(") |
| Temas de componentes (AppBar, Card, Input, SnackBar) | [cardTheme](../lib/core/theme/app_theme.dart#L48 "→ cardTheme: CardThemeData(") |
| Tus propios valores en el tema (`ThemeExtension`) | [LevelColors](../lib/core/theme/app_theme.dart#L77 "→ class LevelColors") |
| Leer la extensión en un widget | [catalog_screen](../lib/features/catalog/catalog_screen.dart#L33 "→ extension<LevelColors>") |
| Claro / oscuro / sistema persistido | [app.dart](../lib/app.dart#L49 "→ themeMode: settings.themeMode") |

Fuentes personalizadas: [`google_fonts`](https://pub.dev/packages/google_fonts) o archivos `.ttf` en `pubspec.yaml` (ver [docs/06 §7](06-construir-la-app.md#7-assets-imágenes-y-fuentes)).

---

## 4. Internacionalización (i18n) con `gen-l10n`

| Paso | Archivo |
|---|---|
| 1. Dependencias `flutter_localizations` + `intl` | [pubspec.yaml](../pubspec.yaml#L83 "→ flutter_localizations:") |
| 2. Activar la generación (`generate: true`) | [pubspec.yaml](../pubspec.yaml#L186 "→ generate: true") |
| 3. Configuración | [l10n.yaml](../l10n.yaml) |
| 4. Textos (plantilla en español) | [app_es.arb](../lib/l10n/app_es.arb) · [app_en.arb](../lib/l10n/app_en.arb) |
| 5. Registrar en MaterialApp | [localizationsDelegates](../lib/app.dart#L55 "→ localizationsDelegates:") |
| 6. Usar | [AppLocalizations.of(context)](../lib/features/todos/todos_screen.dart#L48 "→ final l10n = AppLocalizations.of(context)") |

```bash
flutter gen-l10n        # regenerar a mano (también se hace en flutter run / pub get)
```

**Sintaxis ARB:**
```json
"greeting": "¡Hola, {name}!",
"todosPending": "{count, plural, =0{Ninguna} =1{Una tarea} other{{count} tareas}}",
"todayIs": "Hoy es {date}",
"@todayIs": { "placeholders": { "date": { "type": "DateTime", "format": "yMMMMEEEEd" } } }
```

**Añadir un idioma:** crea `lib/l10n/app_pt.arb` con las mismas claves → `flutter gen-l10n`. En iOS, añade también el idioma en Xcode → *Runner → Info → Localizations*.

---

## 5. Persistencia local

📄 [lib/core/storage/preferences.dart](../lib/core/storage/preferences.dart)

| Configuración | Dónde |
|---|---|
| Claves centralizadas + `allowList` | [PrefsKeys](../lib/core/storage/preferences.dart#L35 "→ abstract final class PrefsKeys") |
| `SharedPreferencesWithCache` (lecturas síncronas) | [createPreferences](../lib/core/storage/preferences.dart#L50 "→ Future<SharedPreferencesWithCache> createPreferences") |
| Guardar objetos como JSON | [_save](../lib/features/todos/todos_controller.dart#L51 "→ Future<void> _save") |
| Almacenamiento en memoria para tests | [createTestPreferences](../test/helpers/test_helpers.dart#L31 "→ Future<SharedPreferencesWithCache> createTestPreferences") |

| Necesidad | Solución |
|---|---|
| Ajustes y datos pequeños | `shared_preferences` (este proyecto) |
| Tokens, contraseñas | `flutter_secure_storage` (Keychain / Keystore) |
| Muchos datos, consultas, relaciones | `drift` (SQL tipado) · `sqflite` · `hive_ce` |
| Archivos (imágenes, PDFs) | `path_provider` + `dart:io` |
| Sincronización en la nube | Firebase Firestore · Supabase |

---

## 6. Entornos con `--dart-define`

📄 [lib/core/config/env.dart](../lib/core/config/env.dart) · [config/dev.json](../config/dev.json) · [config/prod.json](../config/prod.json)

```bash
flutter run --dart-define-from-file=config/dev.json
flutter build appbundle --dart-define-from-file=config/prod.json
flutter run --dart-define=API_URL=https://staging.miapi.com --dart-define=FLAVOR=staging
```
En Dart, cada variable se lee con un constructor `const` (se resuelve al compilar) y puede llevar valor por defecto; para booleanos usa `bool.fromEnvironment`:
```dart
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://miapi.com');
const debugLogs = bool.fromEnvironment('DEBUG_LOGS');
```
Un archivo JSON sirve para agrupar un entorno (`{ "API_URL": "https://dev.miapi.com", "DEBUG_LOGS": true }`).

| Configuración | Dónde |
|---|---|
| Leer valores (`String.fromEnvironment`) | [apiBaseUrl](../lib/core/config/env.dart#L36 "→ static const apiBaseUrl") |
| Usarlo en el cliente HTTP | [ApiClient](../lib/core/network/api_client.dart#L52 "→ _baseUrl = baseUrl ?? Env.apiBaseUrl") |
| Mostrarlo en Ajustes | [Entorno](../lib/features/settings/settings_screen.dart#L115 "→ Env.flavor") |
| `kDebugMode` / `kProfileMode` / `kReleaseMode` | [buildMode](../lib/features/settings/settings_screen.dart#L32 "→ final buildMode") |
| Perfiles de VS Code con variables | [launch.json](../.vscode/launch.json) |

⚠️ No guardes **secretos** aquí: se pueden extraer del binario.

**Flavors** (apps distintas instalables a la vez: "MiApp Dev" y "MiApp"): requieren `productFlavors` en [build.gradle.kts](../android/app/build.gradle.kts) y *schemes* en Xcode, y se eligen con `--flavor dev` (y, si usas otro archivo de entrada, `-t lib/main_dev.dart`) → [docs.flutter.dev/deployment/flavors](https://docs.flutter.dev/deployment/flavors).

---

## 7. Red: cliente HTTP robusto

📄 [lib/core/network/api_client.dart](../lib/core/network/api_client.dart)

| Buena práctica | Dónde |
|---|---|
| Un solo cliente compartido (Provider) | [apiClientProvider](../lib/core/network/api_client.dart#L91 "→ final apiClientProvider") |
| URL base configurable | [constructor](../lib/core/network/api_client.dart#L50 "→ ApiClient({http.Client? client") |
| Timeout | [_timeout](../lib/core/network/api_client.dart#L57 "→ static const _timeout") |
| Errores unificados (`ApiException`) | [getJson](../lib/core/network/api_client.dart#L60 "→ Future<Object?> getJson") |
| Cliente inyectable para tests (`MockClient`) | [fakeApi](../test/features/posts/posts_repository_test.dart#L26 "→ ApiClient fakeApi") |
| Permiso INTERNET en Android release | Ver [06 §9](06-construir-la-app.md#9-permisos-nativos) |

Para APIs más complejas: [`dio`](https://pub.dev/packages/dio) (interceptores para tokens, reintentos, subida de archivos) o [`retrofit`](https://pub.dev/packages/retrofit) (genera el cliente a partir de una interfaz).

---

## 8. Código nativo (Platform Channels)

| Lado | Dónde |
|---|---|
| Dart | [DeviceInfoService](../lib/features/advanced/native_channel.dart#L39 "→ class DeviceInfoService") |
| Android (Kotlin) | [configureFlutterEngine](../android/app/src/main/kotlin/com/jeanrondon/mi_primera_app/MainActivity.kt#L30 "→ override fun configureFlutterEngine") |
| iOS (Swift) | [didInitializeImplicitFlutterEngine](../ios/Runner/AppDelegate.swift#L35 "→ func didInitializeImplicitFlutterEngine") |

| Tipo de canal | Para qué |
|---|---|
| `MethodChannel` | Llamada → respuesta (lo usado aquí) |
| `EventChannel` | Flujo nativo → Dart (sensores, cambios de batería) como `Stream` |
| `BasicMessageChannel` | Mensajes libres en ambos sentidos |
| [`pigeon`](https://pub.dev/packages/pigeon) | Genera canales **tipados** (sin strings mágicos). Recomendado en proyectos grandes |

⚠️ Tras cambiar Kotlin/Swift, detén la app y ejecuta `flutter run` otra vez.

---

## 9. Generación de código (`build_runner`)

Muy usada en proyectos grandes para no escribir a mano `fromJson`, `copyWith`, `==`…

```bash
flutter pub add json_annotation freezed_annotation
flutter pub add --dev build_runner json_serializable freezed
```
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({required int id, required String title}) = _Post;
  factory Post.fromJson(Map<String, Object?> json) => _$PostFromJson(json);
}
```
```bash
dart run build_runner build --delete-conflicting-outputs   # una vez
dart run build_runner watch --delete-conflicting-outputs   # regenerar al guardar
```
Compara con el [Post escrito a mano](../lib/features/posts/post.dart#L25 "→ class Post") de este proyecto.

---

## 10. Pruebas avanzadas

Lo básico (unitarias, de widget, mocks, cobertura) está en [07 · Pruebas y calidad](07-pruebas-y-calidad.md); aquí solo las técnicas avanzadas de este proyecto.

| Técnica | Dónde |
|---|---|
| Helpers compartidos (`pumpApp`, preferencias en memoria) | [test_helpers.dart](../test/helpers/test_helpers.dart) |
| Probar la app completa con navegación real | [widget_test.dart](../test/widget_test.dart#L66 "→ group('App completa'") |
| Probar lógica Riverpod sin UI (`ProviderContainer`) | [todos_controller_test.dart](../test/features/todos/todos_controller_test.dart#L26 "→ ProviderContainer createContainer") |
| Simular reinicio de la app (persistencia) | [persistencia](../test/features/todos/todos_controller_test.dart#L103 "→ las tareas se guardan y se recuperan") |
| HTTP falso con `MockClient` | [posts_repository_test.dart](../test/features/posts/posts_repository_test.dart#L26 "→ ApiClient fakeApi") |
| Sobrescribir un provider de red | [override](../test/features/posts/posts_repository_test.dart#L88 "→ apiClientProvider.overrideWithValue") |
| Funciones puras e isolates | [isolates_test.dart](../test/features/advanced/isolates_test.dart) |

---

## 11. Integración continua (GitHub Actions)

📄 [.github/workflows/flutter-ci.yml](../.github/workflows/flutter-ci.yml)

Cada `git push` o Pull Request a `main` ejecuta automáticamente en GitHub: `pub get` → comprobar formato → `flutter analyze` → `flutter test`. Si algo falla, verás una ❌ en el commit. Resultados en la pestaña **Actions** del repositorio.

Para compilar y publicar automáticamente (APK/IPA a las tiendas), se añade **fastlane** o un servicio como **Codemagic**.

---

## 12. Mantener los enlaces de esta documentación

Los enlaces con `#L` apuntan a una línea concreta. Si editas el código y las líneas se mueven:
```bash
dart run tool/update_doc_links.dart
```
El script ([tool/update_doc_links.dart](../tool/update_doc_links.dart)) vuelve a buscar el texto de cada enlace (el que aparece al pasar el ratón, tras `→`) y corrige el número de línea.

---

## ✅ Comprueba que entendiste

1. ¿Por qué el router se crea dentro de un `Provider`?
   <details><summary>Respuesta</summary>

   Para poder leer otros providers, por ejemplo la sesión, y re-evaluar el `redirect` cuando cambia. Ver [routerProvider](../lib/core/router/app_router.dart#L70 "→ final routerProvider") y [authListenable](../lib/core/router/app_router.dart#L73 "→ final authListenable").

   </details>
2. ¿Para qué sirve `ref.listen` y en qué se diferencia de `ref.watch`?
   <details><summary>Respuesta</summary>

   `ref.listen` reacciona a un cambio sin redibujar (efectos como un SnackBar o navegar); `ref.watch` dentro de `build` sí redibuja el widget (§2, regla 4).

   </details>
3. ¿Por qué nunca debes mutar el estado de un `Notifier`?
   <details><summary>Respuesta</summary>

   El `Notifier` avisa a los widgets al asignar un estado nuevo (`state = [todo, ...state]`); mutar la lista en sitio no dispara ese aviso. Ver [add](../lib/features/todos/todos_controller.dart#L68 "→ state = [todo, ...state]").

   </details>
4. ¿Qué hace el patrón *override* con `sharedPreferencesProvider`?
   <details><summary>Respuesta</summary>

   El provider lanza error por defecto y `main` lo sobrescribe con el objeto ya inicializado; los tests lo sobrescriben con preferencias en memoria. Así el resto del código lo lee como si fuera síncrono.

   </details>
5. ¿Por qué no debes guardar secretos en `--dart-define`?
   <details><summary>Respuesta</summary>

   Los valores quedan dentro del binario y se pueden extraer de él (§6).

   </details>

## 🏋️ Reto

**Completar todas las tareas.** Añade `completeAll()` a `TodosController`: marca todas las tareas como hechas **sin mutar el estado** y persiste el resultado, como hacen `toggle` y `clearCompleted`.

- ✅ **Cómo saber que lo lograste:** `flutter test exercises/e02_todos_completar_todas_test.dart` pasa a verde.
- 💡 **Pista:** mira cómo [add](../lib/features/todos/todos_controller.dart#L58 "→ void add") crea una lista nueva y llama a [_save](../lib/features/todos/todos_controller.dart#L51 "→ Future<void> _save"); haz lo mismo con una lista de tareas copiadas.
- 🔑 **Solución (inténtalo antes):** [e02_todos_completar_todas](../exercises/solutions/e02_todos_completar_todas.md)

## ➡️ Siguiente paso

Continúa con **[17 · Calidad de producción](17-calidad-de-produccion.md)**: con la infraestructura clara, aprende accesibilidad, errores globales y rendimiento. Ruta completa: [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md).
