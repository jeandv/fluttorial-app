# 12 · Librerías más usadas y demandadas en el mercado

> Anterior: [11 · Configuraciones avanzadas](11-configuraciones-avanzadas.md) · Volver al [índice](../README.md) · Siguiente: [13 · Onboarding](13-onboarding.md)

> 📖 **Documento de consulta:** no se lee de corrido; ábrelo cuando lo necesites.
> 🎯 **Te sirve para:** elegir un paquete (qué usar y cuándo), comparar mapas o ver qué se pide en el mercado laboral.
> 🧭 **Ruta de aprendizaje:** [00 · Ruta de aprendizaje](00-ruta-de-aprendizaje.md)

Qué paquetes usan de verdad las apps Flutter en producción, cuáles piden las empresas y cuál elegir en cada caso. Las cifras salen de datos públicos, no de opiniones; las recomendaciones están marcadas como tales.

---

## 1. Metodología (de dónde salen los datos)

| Fuente | Qué mide | Cómo se obtuvo |
|---|---|---|
| **pub.dev** (API pública) | Descargas de los últimos 30 días, likes, *pub points* (calidad, 0-160) y última versión | Consultado el **7 de noviembre de 2026** para 86 paquetes conocidos, con `https://pub.dev/api/packages/<nombre>/score` |
| **Ofertas de empleo y guías de contratación** | Qué tecnologías piden las empresas | Búsqueda de ofertas y guías de 2026 (fuentes al final) |

**Cómo leer las cifras:**
- **Descargas** = uso real. Incluyen descargas indirectas (cuando otro paquete depende de él) y de servidores de CI, así que miden **adopción**, no número de apps.
- **Likes** = popularidad acumulada en la comunidad. Un paquete antiguo puede tener muchos likes aunque hoy se use menos (ej. `get`, `provider`).
- **Pub points** = calidad técnica según pub.dev (documentación, análisis estático, plataformas). 160 es el máximo.
- Los datos de **demanda laboral** son cualitativos: no existe un registro público y verificable de ofertas por paquete. Ver §4.

> Para actualizar las cifras: abre `https://pub.dev/packages/<nombre>/score` o ejecuta la misma consulta a la API.

---

## 2. Top 25 por descargas (de los 86 analizados)

| # | Paquete | Descargas/30 días | Likes | Pub points |
|---:|---|---:|---:|---:|
| 1 | [`uuid`](https://pub.dev/packages/uuid) | 19,3 M | 2,7 K | 160/160 |
| 2 | [`json_annotation`](https://pub.dev/packages/json_annotation) | 15,6 M | 1,3 K | 150/160 |
| 3 | [`http`](https://pub.dev/packages/http) | 14,8 M | 8,5 K | 160/160 |
| 4 | [`intl`](https://pub.dev/packages/intl) | 13,6 M | 6,1 K | 160/160 |
| 5 | [`collection`](https://pub.dev/packages/collection) | 13,2 M | 1,4 K | 140/160 |
| 6 | [`flutter_lints`](https://pub.dev/packages/flutter_lints) | 11,1 M | 1,3 K | 160/160 |
| 7 | [`path_provider`](https://pub.dev/packages/path_provider) | 10,5 M | 5,6 K | 160/160 |
| 8 | [`url_launcher`](https://pub.dev/packages/url_launcher) | 9,7 M | 8,2 K | 160/160 |
| 9 | [`shared_preferences`](https://pub.dev/packages/shared_preferences) | 9,3 M | 10,6 K | 160/160 |
| 10 | [`build_runner`](https://pub.dev/packages/build_runner) | 7,6 M | 2,4 K | 160/160 |
| 11 | [`package_info_plus`](https://pub.dev/packages/package_info_plus) | 7,6 M | 2,8 K | 150/160 |
| 12 | [`equatable`](https://pub.dev/packages/equatable) | 7,6 M | 3,6 K | 160/160 |
| 13 | [`rxdart`](https://pub.dev/packages/rxdart) | 6,3 M | 2,9 K | 135/160 |
| 14 | [`flutter_svg`](https://pub.dev/packages/flutter_svg) | 6,2 M | 5,9 K | 160/160 |
| 15 | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) | 6,1 M | 4,5 K | 160/160 |
| 16 | [`firebase_core`](https://pub.dev/packages/firebase_core) | 6,1 M | 4,1 K | 160/160 |
| 17 | [`image_picker`](https://pub.dev/packages/image_picker) | 6,0 M | 7,8 K | 160/160 |
| 18 | [`dio`](https://pub.dev/packages/dio) | 5,4 M | 8,4 K | 160/160 |
| 19 | [`go_router`](https://pub.dev/packages/go_router) | 5,4 M | 5,8 K | 150/160 |
| 20 | [`share_plus`](https://pub.dev/packages/share_plus) | 5,3 M | 4,0 K | 140/160 |
| 21 | [`file_picker`](https://pub.dev/packages/file_picker) | 5,1 M | 5,0 K | 150/160 |
| 22 | [`device_info_plus`](https://pub.dev/packages/device_info_plus) | 4,9 M | 3,0 K | 150/160 |
| 23 | [`freezed_annotation`](https://pub.dev/packages/freezed_annotation) | 4,8 M | 564 | 150/160 |
| 24 | [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) | 4,6 M | 4,1 K | 160/160 |
| 25 | [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) | 4,4 M | 4,0 K | 160/160 |

**Los más "queridos" (likes):**

- [`get`](https://pub.dev/packages/get) (15,6 K)
- [`provider`](https://pub.dev/packages/provider) (11,0 K)
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) (10,6 K)
- [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) (9,8 K)
- [`http`](https://pub.dev/packages/http) (8,5 K)
- [`dio`](https://pub.dev/packages/dio) (8,4 K)
- [`url_launcher`](https://pub.dev/packages/url_launcher) (8,2 K)
- [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (8,1 K)
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) (8,0 K)
- [`image_picker`](https://pub.dev/packages/image_picker) (7,8 K)

Observaciones:
- Los primeros puestos son **utilidades básicas** que casi todas las apps usan directa o indirectamente: `uuid`, `json_annotation`, `http`, `intl`, `path_provider`, `url_launcher`, `shared_preferences`.
- **Riverpod** (`riverpod` + `flutter_riverpod`) supera hoy en descargas a **Bloc** y a **Provider**, aunque `provider` sigue siendo de los paquetes con más likes.
- **Firebase** (`firebase_core`) está en el top: es el backend más común en apps Flutter.

---

## 3. Por categoría: qué usar y cuándo

> ✅ = ya lo usa este proyecto (con enlace al código). Las columnas "Cuándo elegirlo" son **recomendaciones** basadas en los datos y en la práctica habitual.

### 3.1 Gestión de estado
**En breve:** empieza con **Riverpod**; aprende Bloc/Cubit lo justo para trabajar en equipos que lo usan. `get` solo en código heredado.

<details><summary>Ver la tabla completa (6 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | 4,3 M | 2,9 K | 3.5.0 | Estado global, async, caché, inyección de dependencias | ⭐ Recomendado por defecto en proyectos nuevos | ✅ [todos_controller.dart](../lib/features/todos/todos_controller.dart#L33 "→ class TodosController extends Notifier") |
| [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) | 2,3 M | 8,1 K | 9.1.1 | Patrón Bloc/Cubit: eventos → estados | Equipos grandes y empresas que buscan una arquitectura muy estricta | — |
| [`provider`](https://pub.dev/packages/provider) | 1,2 M | 11,0 K | 6.1.5+1 | Inyección y `ChangeNotifier` simple | Proyectos existentes y apps pequeñas; muchos tutoriales antiguos lo usan | — |
| [`get`](https://pub.dev/packages/get) | 791 K | 15,6 K | 4.7.3 | Estado + rutas + DI todo en uno (GetX) | Lo verás en proyectos heredados; poco recomendado para código nuevo (mezcla responsabilidades) | — |
| [`mobx`](https://pub.dev/packages/mobx) | 123 K | 1,3 K | 2.7.0 | Observables y reacciones | Equipos que vienen de MobX en JavaScript | — |
| [`signals`](https://pub.dev/packages/signals) | 26 K | 714 | 7.1.0 | Señales reactivas | Experimental / proyectos pequeños | — |

</details>

> 💼 **Para el mercado laboral:** domina **Riverpod** y aprende **Bloc/Cubit** lo suficiente para trabajar con él. Son las dos opciones que más se repiten en las ofertas (ver §4).

### 3.2 Navegación
**En breve:** `go_router` (oficial) por defecto; `auto_route` si prefieres rutas generadas.

<details><summary>Ver la tabla completa (2 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`go_router`](https://pub.dev/packages/go_router) | 5,4 M | 5,8 K | 18.1.3 | Rutas con URL, deep links, redirects, pestañas | ⭐ Opción oficial del equipo de Flutter; recomendado por defecto | ✅ [app_router.dart](../lib/core/router/app_router.dart#L70 "→ final routerProvider") |
| [`auto_route`](https://pub.dev/packages/auto_route) | 420 K | 3,4 K | 11.2.0 | Rutas generadas con código (tipadas) | Apps grandes que prefieren generación de código | — |

</details>

### 3.3 Red y APIs
**En breve:** `http` para APIs simples, `dio` cuando necesitas interceptores o tokens; `retrofit` encima de Dio para APIs grandes.

<details><summary>Ver la tabla completa (5 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`http`](https://pub.dev/packages/http) | 14,8 M | 8,5 K | 1.6.0 | Peticiones HTTP sencillas (oficial de Dart) | APIs simples, paquetes y scripts | ✅ [api_client.dart](../lib/core/network/api_client.dart#L49 "→ class ApiClient") |
| [`dio`](https://pub.dev/packages/dio) | 5,4 M | 8,4 K | 5.11.1 | HTTP con interceptores, cancelación, subida de archivos | ⭐ Apps profesionales con autenticación por token | ✅ [demo Dio](../lib/features/packages/dio/dio_client.dart#L71 "→ Dio createDio") |
| [`retrofit`](https://pub.dev/packages/retrofit) | 682 K | 2,1 K | 4.10.0 | Genera el cliente a partir de una interfaz (sobre Dio) | APIs REST grandes con muchos endpoints | — |
| [`chopper`](https://pub.dev/packages/chopper) | 158 K | 917 | 8.7.1 | Similar a Retrofit | Alternativa a retrofit | — |
| [`graphql_flutter`](https://pub.dev/packages/graphql_flutter) | 236 K | 914 | 5.3.0 | Cliente GraphQL | Si tu backend es GraphQL | — |

</details>

### 3.4 Modelos, JSON y generación de código
**En breve:** `json_serializable` + `freezed` (con `build_runner`) para modelos; `equatable` si no quieres generar código.

<details><summary>Ver la tabla completa (5 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`json_serializable`](https://pub.dev/packages/json_serializable) | 4,4 M | 4,0 K | 6.15.2 | Genera `fromJson`/`toJson` | ⭐ Cualquier app que consuma JSON (junto a `json_annotation`) | [ejemplo en docs/11 §9](11-configuraciones-avanzadas.md#9-generación-de-código-build_runner) |
| [`freezed`](https://pub.dev/packages/freezed) | 3,0 M | 4,5 K | 4.0.3 | Clases inmutables, `copyWith`, `==`, uniones | ⭐ Modelos y estados; muy común junto a Riverpod/Bloc | [ejemplo en docs/11 §9](11-configuraciones-avanzadas.md#9-generación-de-código-build_runner) |
| [`build_runner`](https://pub.dev/packages/build_runner) | 7,6 M | 2,4 K | 2.17.1 | Ejecuta los generadores de código | Siempre que uses freezed/json_serializable/retrofit | — |
| [`equatable`](https://pub.dev/packages/equatable) | 7,6 M | 3,6 K | 3.0.0 | `==` y `hashCode` sin generar código | Estados de Bloc y modelos simples | — |
| [`dart_mappable`](https://pub.dev/packages/dart_mappable) | 510 K | 469 | 4.10.0 | Alternativa todo-en-uno a freezed + json_serializable | Si prefieres una sola herramienta | — |

</details>

### 3.5 Almacenamiento local
**En breve:** `shared_preferences` para ajustes, `flutter_secure_storage` para secretos, `drift` si hay muchos datos. Evita `hive` e `isar`.

<details><summary>Ver la tabla completa (7 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | 9,3 M | 10,6 K | 2.5.6 | Clave-valor (ajustes, flags) | ⭐ Datos pequeños y no sensibles | ✅ [preferences.dart](../lib/core/storage/preferences.dart#L50 "→ Future<SharedPreferencesWithCache> createPreferences") |
| [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) | 6,1 M | 4,5 K | 11.2.0 | Clave-valor cifrado (Keychain/Keystore) | ⭐ Tokens, contraseñas, datos sensibles | — |
| [`path_provider`](https://pub.dev/packages/path_provider) | 10,5 M | 5,6 K | 2.1.6 | Rutas de carpetas del sistema | Guardar archivos (imágenes, PDFs, caché) | (lo usa `cached_network_image`) |
| [`sqflite`](https://pub.dev/packages/sqflite) | 3,3 M | 5,6 K | 2.4.5 | SQLite directo | SQL clásico, proyectos existentes | (lo usa `cached_network_image`) |
| [`drift`](https://pub.dev/packages/drift) | 1,9 M | 2,5 K | 2.35.3 | SQLite tipado y reactivo | ⭐ Bases de datos locales serias, apps *offline-first* | — |
| [`hive_ce`](https://pub.dev/packages/hive_ce) | 1,4 M | 574 | 2.23.1 | Base NoSQL rápida (*community edition*) | Alternativa ligera a drift; sustituye a `hive` | — |
| [`objectbox`](https://pub.dev/packages/objectbox) | 188 K | 1,6 K | 5.3.2 | Base de datos de objetos de alto rendimiento | Muchos datos, sincronización | — |

</details>

> ⚠️ **Con cuidado:** `hive` (última versión en 2022-06-30) e `isar` (última versión en 2023-04-25, 4 K descargas al mes) ya no se mantienen activamente. En proyectos nuevos usa `hive_ce` o `drift`.

### 3.6 Backend como servicio
**En breve:** Firebase (`firebase_core` + auth, Firestore, messaging, crashlytics) es lo más común; `supabase_flutter` si prefieres SQL.

<details><summary>Ver la tabla completa (7 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`firebase_core`](https://pub.dev/packages/firebase_core) | 6,1 M | 4,1 K | 5.1.0 | Base de cualquier paquete de Firebase | ⭐ El backend más común en Flutter | — |
| [`firebase_auth`](https://pub.dev/packages/firebase_auth) | 2,2 M | 4,3 K | 7.0.1 | Login (email, Google, Apple, teléfono) | Autenticación sin backend propio | — |
| [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) | 1,7 M | 3,8 K | 7.1.0 | Base de datos NoSQL en tiempo real | Datos sincronizados entre dispositivos | — |
| [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) | 4,4 M | 4,0 K | 17.0.1 | Notificaciones push (FCM) | ⭐ Casi toda app con notificaciones | — |
| [`firebase_crashlytics`](https://pub.dev/packages/firebase_crashlytics) | 2,6 M | 1,3 K | 6.0.1 | Informes de errores en producción | Toda app publicada | — |
| [`firebase_analytics`](https://pub.dev/packages/firebase_analytics) | 2,7 M | 1,3 K | 13.0.1 | Analítica de uso | Medir el uso de la app | — |
| [`supabase_flutter`](https://pub.dev/packages/supabase_flutter) | 1,3 M | 990 | 2.18.3 | Alternativa *open source* (PostgreSQL) | Si prefieres SQL o alojarlo tú | — |

</details>

> Firebase requiere crear un proyecto en la consola y configurarlo con `flutterfire configure`; por eso no hay demo aquí. Guía oficial: [firebase.google.com/docs/flutter/setup](https://firebase.google.com/docs/flutter/setup).

### 3.7 Interfaz y multimedia
**En breve:** `flutter_svg`, `cached_network_image`, `google_fonts` y `fl_chart` cubren la mayoría de interfaces.

<details><summary>Ver la tabla completa (8 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`flutter_svg`](https://pub.dev/packages/flutter_svg) | 6,2 M | 5,9 K | 2.3.2 | Mostrar imágenes SVG | ⭐ Iconos e ilustraciones vectoriales | — |
| [`cached_network_image`](https://pub.dev/packages/cached_network_image) | 3,8 M | 7,0 K | 4.0.6 | Imágenes de internet con caché en disco | ⭐ Cualquier lista con fotos de una API | ✅ [demo Imágenes](../lib/features/packages/images_screen.dart#L101 "→ child: CachedNetworkImage(") |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | 3,5 M | 6,5 K | 9.0.0 | Más de 1.000 fuentes de Google | Tipografías sin descargar archivos | — |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | 2,3 M | 7,2 K | 1.3.0 | Gráficos (líneas, barras, tarta) | ⭐ Dashboards, finanzas, salud | — |
| [`lottie`](https://pub.dev/packages/lottie) | 2,3 M | 4,6 K | 3.8.2 | Animaciones de After Effects (JSON) | Animaciones de diseñadores | — |
| [`shimmer`](https://pub.dev/packages/shimmer) | 1,7 M | 5,5 K | 4.0.0 | Efecto *skeleton* de carga | Estados de carga elegantes | ✅ [ShimmerBox](../lib/features/packages/images_screen.dart#L128 "→ class ShimmerBox") |
| [`flutter_animate`](https://pub.dev/packages/flutter_animate) | 1,3 M | 4,3 K | 4.5.2 | Animaciones encadenadas con poco código | Microinteracciones | — |
| [`carousel_slider`](https://pub.dev/packages/carousel_slider) | 1,0 M | 6,1 K | 5.1.2 | Carruseles de imágenes | Banners, galerías | — |

</details>

### 3.8 Funciones del dispositivo
**En breve:** `url_launcher`, `image_picker`, `share_plus` y `permission_handler` son los de uso casi universal.

<details><summary>Ver la tabla completa (10 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`url_launcher`](https://pub.dev/packages/url_launcher) | 9,7 M | 8,2 K | 6.3.3 | Abrir webs, teléfono, email, SMS, mapas | ⭐ Casi cualquier app | ✅ [demo Enlaces](../lib/features/packages/links_share_screen.dart#L36 "→ Future<void> _open") |
| [`package_info_plus`](https://pub.dev/packages/package_info_plus) | 7,6 M | 2,8 K | 10.2.2 | Versión y nombre de la app | Pantalla «Acerca de», forzar actualizaciones | — |
| [`image_picker`](https://pub.dev/packages/image_picker) | 6,0 M | 7,8 K | 1.2.4 | Elegir foto de la galería o cámara | ⭐ Fotos de perfil, subir imágenes | — |
| [`share_plus`](https://pub.dev/packages/share_plus) | 5,3 M | 4,0 K | 13.3.1 | Hoja nativa de compartir | Compartir contenido | ✅ [demo Enlaces](../lib/features/packages/links_share_screen.dart#L65 "→ SharePlus.instance.share") |
| [`file_picker`](https://pub.dev/packages/file_picker) | 5,1 M | 5,0 K | 13.3.2 | Elegir archivos (PDF, docs…) | Subir documentos | — |
| [`device_info_plus`](https://pub.dev/packages/device_info_plus) | 4,9 M | 3,0 K | 13.3.0 | Modelo y sistema del dispositivo | Soporte técnico, analítica | Alternativa al [MethodChannel propio](../lib/features/advanced/native_channel.dart#L39 "→ class DeviceInfoService")  |
| [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) | 4,6 M | 4,1 K | 7.3.2 | Tipo de conexión (wifi/datos/ninguna) | Avisar cuando no hay red | — |
| [`permission_handler`](https://pub.dev/packages/permission_handler) | 4,1 M | 6,0 K | 13.0.2 | Pedir y consultar cualquier permiso | Apps con muchos permisos | — |
| [`webview_flutter`](https://pub.dev/packages/webview_flutter) | 4,1 M | 4,5 K | 4.14.1 | Mostrar una web dentro de la app | Contenido web, pagos externos | — |
| [`camera`](https://pub.dev/packages/camera) | 1,1 M | 2,6 K | 0.12.2 | Control total de la cámara | Escáneres, apps de fotos | — |

</details>

### 3.9 Mapas y ubicación
**En breve:** `flutter_map` + `latlong2` para aprender y prototipos (sin API key); `google_maps_flutter` si tu empresa ya usa Google.

<details><summary>Ver la tabla completa (6 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`geolocator`](https://pub.dev/packages/geolocator) | 3,1 M | 6,1 K | 14.1.2 | Ubicación GPS y permisos | ⭐ Cualquier app con ubicación | ✅ [LocationService](../lib/features/packages/maps/map_data.dart#L117 "→ class LocationService") |
| [`flutter_map`](https://pub.dev/packages/flutter_map) | 1,2 M | 2,2 K | 8.3.2 | Mapas con OpenStreetMap u otros proveedores, sin API key | ⭐ Aprender, prototipos y apps que no quieren depender de Google | ✅ [demo Mapas](../lib/features/packages/maps/map_screen.dart#L162 "→ FlutterMap(") |
| [`latlong2`](https://pub.dev/packages/latlong2) | 1,4 M | 403 | 0.10.1 | Coordenadas y distancias | Junto a flutter_map | ✅ [routeDistanceKm](../lib/features/packages/maps/map_data.dart#L78 "→ double routeDistanceKm") |
| [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) | 1,2 M | 4,6 K | 2.19.0 | SDK oficial de Google Maps | ⭐ Empresas que ya usan Google (requiere API key y facturación) | — |
| [`geocoding`](https://pub.dev/packages/geocoding) | 784 K | 1,4 K | 5.0.1 | Dirección ↔ coordenadas | Buscadores de direcciones | — |
| [`mapbox_maps_flutter`](https://pub.dev/packages/mapbox_maps_flutter) | 153 K | 386 | 3.34.2 | SDK de Mapbox | Mapas muy personalizados, 3D, navegación | — |

</details>

Detalle completo de mapas en la §6.

### 3.10 Notificaciones
**En breve:** `flutter_local_notifications` para avisos locales y `firebase_messaging` para push remoto.

<details><summary>Ver la tabla completa (3 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) | 4,4 M | 4,0 K | 17.0.1 | Push desde el servidor (FCM) | ⭐ Notificaciones remotas | — |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) | 3,9 M | 7,4 K | 23.0.0 | Notificaciones locales programadas | ⭐ Recordatorios, alarmas, mostrar push en primer plano | — |
| [`awesome_notifications`](https://pub.dev/packages/awesome_notifications) | 90 K | 3,4 K | 0.12.1 | Notificaciones locales con más diseño | Alternativa a la anterior | — |

</details>

### 3.11 Arquitectura, calidad y monitorización
**En breve:** `flutter_lints` (por defecto), `mocktail` para tests, `get_it` si no usas Riverpod, `sentry_flutter` o Crashlytics en producción.

<details><summary>Ver la tabla completa (9 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`get_it`](https://pub.dev/packages/get_it) | 2,5 M | 4,7 K | 9.3.0 | Localizador de servicios (inyección de dependencias) | Proyectos con Bloc o sin Riverpod | Riverpod ya cubre la inyección con [overrides](../lib/main.dart#L50 "→ sharedPreferencesProvider.overrideWithValue")  |
| [`injectable`](https://pub.dev/packages/injectable) | 438 K | 1,5 K | 3.0.0 | Genera el registro de get_it | Junto a get_it en apps grandes | — |
| [`flutter_lints`](https://pub.dev/packages/flutter_lints) | 11,1 M | 1,3 K | 6.0.0 | Reglas recomendadas del linter | ⭐ Todos los proyectos (viene por defecto) | ✅ [analysis_options.yaml](../analysis_options.yaml) |
| [`very_good_analysis`](https://pub.dev/packages/very_good_analysis) | 1,4 M | 774 | 11.0.0 | Reglas más estrictas | Equipos que quieren más rigor | — |
| [`mocktail`](https://pub.dev/packages/mocktail) | 3,9 M | 1,2 K | 1.0.5 | Mocks para tests sin generar código | ⭐ Tests unitarios | — |
| [`mockito`](https://pub.dev/packages/mockito) | 2,8 M | 1,5 K | 5.8.1 | Mocks con generación de código | Proyectos que ya lo usan | — |
| [`bloc_test`](https://pub.dev/packages/bloc_test) | 1,5 M | 669 | 10.0.0 | Tests de Blocs y Cubits | Si usas Bloc | — |
| [`logger`](https://pub.dev/packages/logger) | 3,5 M | 3,7 K | 2.8.0 | Logs bonitos por niveles | Depuración | — |
| [`sentry_flutter`](https://pub.dev/packages/sentry_flutter) | 2,0 M | 1,1 K | 10.3.0 | Errores y rendimiento en producción | Alternativa a Crashlytics | — |

</details>

### 3.12 Monetización
**En breve:** `purchases_flutter` (RevenueCat) para suscripciones, `in_app_purchase` oficial, `google_mobile_ads` para publicidad.

<details><summary>Ver la tabla completa (3 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`google_mobile_ads`](https://pub.dev/packages/google_mobile_ads) | 1,1 M | 2,5 K | 9.2.0 | Anuncios de AdMob | Apps gratuitas con publicidad | — |
| [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) | 807 K | 2,5 K | 3.3.1 | Compras dentro de la app (oficial) | Pagos de contenido digital | — |
| [`purchases_flutter`](https://pub.dev/packages/purchases_flutter) | 680 K | 924 | 11.0.1 | RevenueCat: suscripciones simplificadas | ⭐ Suscripciones (evita escribir la validación de recibos) | — |

</details>

### 3.13 Utilidades transversales
**En breve:** `intl` para fechas e idiomas, `uuid` para identificadores, `collection` para utilidades de listas.

<details><summary>Ver la tabla completa (6 paquetes)</summary>

| Paquete | Descargas/30 días | Likes | Versión | Para qué | Cuándo elegirlo | En este proyecto |
|---|---:|---:|---|---|---|---|
| [`intl`](https://pub.dev/packages/intl) | 13,6 M | 6,1 K | 0.20.3 | Fechas, números, monedas, traducciones | ⭐ Toda app con fechas o varios idiomas | ✅ [localization_screen.dart](../lib/features/intermediate/localization_screen.dart#L121 "→ NumberFormat.simpleCurrency") |
| [`uuid`](https://pub.dev/packages/uuid) | 19,3 M | 2,7 K | 4.6.0 | Identificadores únicos | IDs de registros locales | — |
| [`collection`](https://pub.dev/packages/collection) | 13,2 M | 1,4 K | 1.19.1 | Utilidades para listas y mapas | `firstWhereOrNull`, `groupBy`… | — |
| [`rxdart`](https://pub.dev/packages/rxdart) | 6,3 M | 2,9 K | 0.28.0 | Streams avanzados | Programación reactiva con Streams | — |
| [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) | 4,1 M | 8,0 K | 0.14.4 | Genera los iconos de la app | ⭐ Antes de publicar | [docs/08](08-compilar-y-publicar.md#icono) |
| [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) | 2,0 M | 9,8 K | 2.4.8 | Genera la pantalla de carga nativa | Antes de publicar | [docs/08](08-compilar-y-publicar.md#pantalla-de-carga-splash) |

</details>

---

## 4. Demanda en el mercado laboral

No hay una estadística oficial y verificable de ofertas por paquete. Este es el **patrón que se repite** en las ofertas y guías de contratación revisadas (2026):

| Tecnología | Qué piden las ofertas | Prioridad para aprender |
|---|---|---|
| **Gestión de estado** | Casi siempre: **Riverpod** y **Bloc/Cubit** como los más citados; Provider y GetX en proyectos existentes | 🔴 Imprescindible |
| **Firebase** | Auth, Firestore, Cloud Messaging (FCM), Analytics, Crashlytics | 🔴 Imprescindible |
| **APIs REST** | Consumo de APIs y JSON (Dio o http); a veces GraphQL | 🔴 Imprescindible |
| **Arquitectura** | Clean Architecture, separación en capas, inyección de dependencias | 🟠 Muy valorado |
| **Testing** | Tests unitarios y de widget; mocks | 🟠 Muy valorado |
| **Publicación** | Publicar en App Store y Google Play, firma, versiones | 🟠 Muy valorado |
| **CI/CD** | GitHub Actions, Codemagic, fastlane | 🟡 Diferenciador |
| **Nativo** | Platform channels, algo de Kotlin/Swift | 🟡 Diferenciador |
| **Mapas y ubicación** | Google Maps / geolocalización en apps de delivery, transporte, inmobiliarias | 🟡 Según el sector |

> Una web de currículums afirma que Riverpod aparece en ~47 % y Bloc/Cubit en ~41 % de las ofertas de Flutter en EE. UU. en 2026, pero **no publica su metodología**: tómalo como orientativo.

### Ruta de aprendizaje recomendada (por prioridad)
1. **Base:** Dart + widgets + `setState` → [docs/05](05-dart-esencial.md), [docs/06](06-construir-la-app.md).
2. **Estado y navegación:** Riverpod + go_router → ya en este proyecto ([docs/11](11-configuraciones-avanzadas.md)).
3. **Red y modelos:** Dio + freezed/json_serializable.
4. **Persistencia:** shared_preferences + flutter_secure_storage (+ drift si hay muchos datos).
5. **Firebase:** Auth + Firestore + Messaging + Crashlytics.
6. **Calidad:** tests con mocktail, CI con GitHub Actions → [docs/07](07-pruebas-y-calidad.md).
7. **Bloc/Cubit:** para poder trabajar en proyectos que lo usan.
8. **Funciones del dispositivo:** image_picker, mapas, notificaciones locales.
9. **Publicar** una app real en las dos tiendas → [docs/08](08-compilar-y-publicar.md).

---

## 5. Cómo elegir un paquete (checklist)

Antes de añadir cualquier paquete con `flutter pub add`, revisa en su página de pub.dev:

- [ ] **Pub points** altos (idealmente ≥ 140/160).
- [ ] **Última versión reciente** (menos de 6-12 meses). Si lleva años sin actualizarse, busca alternativas.
- [ ] **Publisher verificado** (✓ junto al autor): `flutter.dev`, `dart.dev`, `firebase.google.com`, `fluttercommunity.dev`…
- [ ] Insignia **Flutter Favorite** (seleccionados por el equipo de Flutter).
- [ ] **Plataformas** soportadas: que diga Android **e** iOS.
- [ ] **Descargas** altas: más uso = más respuestas en internet cuando algo falle.
- [ ] Repositorio con **issues atendidos** (mira GitHub).
- [ ] ¿Requiere **configuración nativa** (permisos, claves)? Léelo en su README antes de instalar.
- [ ] ¿Lo necesitas de verdad? Cada dependencia es código que no controlas.

---

## 6. Mapas en detalle

### Comparativa

| | [`flutter_map`](https://pub.dev/packages/flutter_map) | [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) | [`mapbox_maps_flutter`](https://pub.dev/packages/mapbox_maps_flutter) |
|---|---|---|---|
| Descargas/30 días | 1,2 M | 1,2 M | 153 K |
| API key | No (con OSM) | Sí (Google Cloud) | Sí (token Mapbox) |
| Coste | Gratis con OSM (con límites de uso); proveedores de pago opcionales | Capa gratuita mensual y después de pago | Capa gratuita y después de pago |
| Tecnología | Widgets de Flutter puros | Vista nativa de Google | SDK nativo de Mapbox |
| Personalización | Total (los marcadores son widgets) | Estilos JSON, marcadores con imágenes | Estilos avanzados, 3D |
| Cuándo | Aprender, prototipos, independencia de Google | Empresas, Street View, Places, rutas de Google | Mapas de marca, navegación, 3D |
| En este proyecto | ✅ [demo Mapas](../lib/features/packages/maps/map_screen.dart#L49 "→ class MapScreen") | — | — |

### Lo que enseña la demo de mapas
| Concepto | Código |
|---|---|
| Mapa con teselas de OpenStreetMap | [TileLayer](../lib/features/packages/maps/map_screen.dart#L181 "→ urlTemplate:") |
| Identificar la app ante OSM (obligatorio) | [userAgentPackageName](../lib/features/packages/maps/map_screen.dart#L183 "→ userAgentPackageName:") |
| Marcadores con cualquier widget | [MarkerLayer](../lib/features/packages/maps/map_screen.dart#L214 "→ MarkerLayer(") |
| Ruta (polilínea) | [PolylineLayer](../lib/features/packages/maps/map_screen.dart#L188 "→ PolylineLayer(") |
| Círculo en metros | [CircleLayer](../lib/features/packages/maps/map_screen.dart#L204 "→ useRadiusInMeter: true") |
| Tocar el mapa para añadir puntos | [_onMapTap](../lib/features/packages/maps/map_screen.dart#L112 "→ void _onMapTap") |
| Mover la cámara / zoom | [_zoom](../lib/features/packages/maps/map_screen.dart#L76 "→ void _zoom") |
| Atribución obligatoria | [RichAttributionWidget](../lib/features/packages/maps/map_screen.dart#L261 "→ RichAttributionWidget(") |
| Flujo de permisos de ubicación | [getCurrentLocation](../lib/features/packages/maps/map_data.dart#L120 "→ Future<LatLng> getCurrentLocation") |
| Distancia real de una ruta | [routeDistanceKm](../lib/features/packages/maps/map_data.dart#L78 "→ double routeDistanceKm") |
| Permiso iOS | [Info.plist](../ios/Runner/Info.plist#L29 "→ NSLocationWhenInUseUsageDescription") |
| Permiso Android | [AndroidManifest.xml](../android/app/src/main/AndroidManifest.xml#L23 "→ ACCESS_FINE_LOCATION") |
| Tests | [map_data_test.dart](../test/features/packages/map_data_test.dart) |

**Simular tu ubicación:** en el simulador de iOS, menú *Features → Location → Custom Location…*; en el emulador de Android, *⋯ → Location*.

**Aviso en la consola:** en modo debug, `flutter_map` escribe un mensaje recordando que los servidores públicos de OpenStreetMap *no son gratis para cualquier uso* ([política de uso](https://operations.osmfoundation.org/policies/tiles/)). Es correcto para aprender y prototipos; para una app publicada con usuarios reales, usa un proveedor de teselas.

**Cambiar el proveedor de mapas** (para producción o estilos distintos): solo cambia `urlTemplate`, por ejemplo con MapTiler, Stadia Maps o Thunderforest (requieren una clave gratuita en su web).

### Cómo se configuraría Google Maps (referencia)
1. Crea un proyecto en [Google Cloud Console](https://console.cloud.google.com), activa **Maps SDK for Android** y **Maps SDK for iOS** y crea una **API key** (restríngela a tu app).
2. `flutter pub add google_maps_flutter`
3. **Android** → en `AndroidManifest.xml`, dentro de `<application>`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY" android:value="TU_API_KEY"/>
   ```
4. **iOS** → en `AppDelegate.swift`: `import GoogleMaps` y `GMSServices.provideAPIKey("TU_API_KEY")` al arrancar.
5. Widget:
   ```dart
   GoogleMap(
     initialCameraPosition: const CameraPosition(target: LatLng(10.50, -66.91), zoom: 13),
     markers: {const Marker(markerId: MarkerId('plaza'), position: LatLng(10.5061, -66.9146))},
     myLocationEnabled: true,
   )
   ```
⚠️ No subas la API key a un repositorio público sin restricciones; configura restricciones por app en Google Cloud.

---

## 7. Demos de este proyecto

| Demo | Paquetes | Código | Tests |
|---|---|---|---|
| **Mapas** | flutter_map, latlong2, geolocator | [lib/features/packages/maps/](../lib/features/packages/maps/) | [map_data_test.dart](../test/features/packages/map_data_test.dart) |
| **Dio** | dio | [lib/features/packages/dio/](../lib/features/packages/dio/) | [dio_client_test.dart](../test/features/packages/dio_client_test.dart) |
| **Imágenes en caché** | cached_network_image, shimmer | [images_screen.dart](../lib/features/packages/images_screen.dart) | — |
| **Enlaces y compartir** | url_launcher, share_plus | [links_share_screen.dart](../lib/features/packages/links_share_screen.dart) | — |

Detalles de la demo de Dio:

| Concepto | Código |
|---|---|
| Configuración base (URL, timeouts, cabeceras) | [BaseOptions](../lib/features/packages/dio/dio_client.dart#L77 "→ BaseOptions(") |
| Interceptor que añade el token | [AuthInterceptor](../lib/features/packages/dio/dio_client.dart#L28 "→ class AuthInterceptor") |
| Interceptor de logs | [LogCollectorInterceptor](../lib/features/packages/dio/dio_client.dart#L43 "→ class LogCollectorInterceptor") |
| Errores tipados con `switch` exhaustivo | [describeDioError](../lib/features/packages/dio/dio_client.dart#L96 "→ String describeDioError") |
| Cancelar peticiones | [CancelToken](../lib/features/packages/dio/dio_demo_screen.dart#L49 "→ _cancelToken?.cancel('Pantalla cerrada')") |
| Probar Dio sin internet (adaptador falso) | [_FakeAdapter](../test/features/packages/dio_client_test.dart#L22 "→ class _FakeAdapter") |

**Por qué estas demos y no otras:** son de las librerías más descargadas, no requieren cuentas ni claves (salvo las teselas públicas de OSM) y apenas añaden configuración nativa. Firebase, Google Maps y notificaciones push requieren cuentas externas: están documentados arriba pero no incluidos como demo. Los pagos sí tienen demo, pero **simulada** (sin cuenta ni cobros reales): ver [14 · Pagos](14-pagos.md).

---

## 8. Fuentes

- Métricas: API pública de pub.dev, `https://pub.dev/api/packages/<paquete>/score` (consultada el 7/11/2026).
- [Paquetes Flutter Favorite en pub.dev](https://pub.dev/packages?q=is%3Aflutter-favorite)
- [Glassdoor: ofertas "flutter firebase" (2026)](https://www.glassdoor.com/Job/flutter-firebase-jobs-SRCH_IN115_KO0,16.htm)
- [KORE1: How to Hire Flutter Developers in 2026](https://www.kore1.com/hire-flutter-developers-2026/)
- [TFTUS: Key Skills for Flutter Developers in 2026](https://www.tftus.com/blog/key-skills-for-flutter-developers)
- [TechieCV: Flutter Developer Resume Skills & ATS Keywords (2026)](https://www.techiecv.com/resume-skills/flutter-developer) (cifras sin metodología publicada)
- [Flutter Roadmap 2026 (Medium)](https://medium.com/@dadhishankar1/flutter-roadmap-2026-from-hello-world-to-high-paying-job-bd9af9d26642)
- [DEV Community: Flutter State Management in 2026 — Riverpod vs Bloc vs Provider in production](https://dev.to/lycore/flutter-state-management-in-2026-riverpod-vs-bloc-vs-provider-in-production-2i53)
- [Política de uso de teselas de OpenStreetMap](https://operations.osmfoundation.org/policies/tiles/)

---

## ➡️ Siguiente paso

Vuelve a la [ruta de aprendizaje](00-ruta-de-aprendizaje.md).
