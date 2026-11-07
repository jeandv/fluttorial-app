# 📁 `lib/` — El código de tu app

> Volver al [índice](../README.md) · Guías: [06 · Construir la app](../docs/06-construir-la-app.md) · [10 · Funcionalidades](../docs/10-funcionalidades-de-la-app.md) · [11 · Configuraciones avanzadas](../docs/11-configuraciones-avanzadas.md)

Aquí vive **todo el código Dart** de la aplicación. El mismo código se compila para **iOS y Android**.

## Estructura (organización *feature-first*)

```
lib/
├── main.dart              Arranque: carga preferencias, ProviderScope, runApp
├── app.dart               MaterialApp.router: tema, idioma, rutas
├── core/                  Infraestructura compartida (no depende de features/)
│   ├── config/env.dart        Variables --dart-define (API_URL, FLAVOR…)
│   ├── network/api_client.dart Cliente HTTP con timeout y errores tipados
│   ├── router/                go_router: rutas (routes.dart) y configuración (app_router.dart)
│   ├── settings/              Tema e idioma persistidos (Riverpod Notifier)
│   ├── storage/               shared_preferences + provider inyectable
│   ├── theme/                 ThemeData claro/oscuro + ThemeExtension propia
│   └── widgets/               DemoScaffold y DemoSection (reutilizables)
├── features/              Una carpeta por funcionalidad
│   ├── catalog/               Pestaña "Ejemplos": datos y pantalla del catálogo
│   ├── shell/                 Barra de navegación inferior (pestañas)
│   ├── basics/                Demos básicas: contador, layout, widgets, listas
│   ├── intermediate/          Formularios, navegación, asincronía, idiomas
│   ├── posts/                 API REST: modelo, repositorio + providers, pantallas
│   ├── advanced/              Animaciones, responsive, código nativo, isolates
│   ├── auth/                  Sesión simulada + pantallas login/privada
│   ├── onboarding/            Bienvenida de primer uso (docs/13)
│   ├── payments/              Checkout, validación de tarjetas, pasarela y paywall (docs/14)
│   ├── ai/                    Cliente de Claude, Estudio IA y agente con herramientas (docs/15)
│   ├── packages/              Librerías populares: mapas, Dio, imágenes en caché, enlaces (docs/12)
│   ├── todos/                 Pestaña "Tareas": modelo, controller, pantalla
│   └── settings/              Pestaña "Ajustes"
└── l10n/                  Traducciones
    ├── app_es.arb / app_en.arb   ← los editas tú
    └── app_localizations*.dart   ← generados por `flutter gen-l10n` (no editar)
```

Mapa de cada demo con enlaces a las líneas: [docs/10](../docs/10-funcionalidades-de-la-app.md).

## Reglas

- Nombres de archivo en `snake_case.dart`; clases en `UpperCamelCase`.
- `features/` puede importar `core/`; `core/` no importa `features/` (excepto el router, que conecta las pantallas).
- La lógica (providers, repositorios) va separada de la interfaz (pantallas): así se puede probar sin UI.
- Importa con el nombre del paquete:
  ```dart
  import 'package:mi_primera_app/core/router/routes.dart';
  ```
- Los archivos o clases que empiezan por `_` son privados (solo visibles en su archivo).
- Código generado (`app_localizations*.dart`, `*.g.dart`, `*.freezed.dart`) no se edita a mano.

## Comandos relacionados

```bash
flutter run                  # ejecutar (r = hot reload, R = hot restart)
flutter analyze              # revisar errores en lib/
dart format lib              # formatear
dart fix --apply             # aplicar correcciones automáticas
flutter gen-l10n             # regenerar traducciones tras editar los .arb
```
