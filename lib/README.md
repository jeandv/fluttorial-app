# 📁 `lib/` — El código de tu app

> Volver al [índice](../README.md) · Guía completa: [06 · Construir la app](../docs/06-construir-la-app.md)

Aquí vive **todo el código Dart** de la aplicación. Es la carpeta donde pasarás la mayor parte del tiempo. El mismo código se compila para **iOS y Android**.

## Qué hay ahora

| Archivo | Qué contiene |
|---|---|
| [`main.dart`](main.dart) | `main()` → `runApp(MyApp())`, el tema y la pantalla del contador. Comentado línea por línea |

## Cómo organizarla a medida que crece

```
lib/
├── main.dart          # Solo: void main() => runApp(const App());
├── app.dart           # MaterialApp: tema, rutas, idioma
├── screens/           # Pantallas completas      → home_screen.dart, login_screen.dart
├── widgets/           # Piezas reutilizables     → producto_card.dart, boton_primario.dart
├── models/            # Clases de datos          → producto.dart, usuario.dart
├── services/          # API, BD, almacenamiento  → api_service.dart, auth_service.dart
├── providers/         # Estado (Riverpod/Bloc)   → carrito_provider.dart
└── utils/             # Constantes, tema, helpers → constants.dart, theme.dart
```

Para proyectos grandes: organización **por funcionalidad** (`lib/features/<nombre>/{data,domain,presentation}`). Ver [docs/06, sección 2](../docs/06-construir-la-app.md#2-cómo-organizar-lib).

## Reglas

- Nombres de archivo en `snake_case.dart`; clases en `UpperCamelCase`.
- Una pantalla o widget grande por archivo.
- Importa tus archivos con el nombre del paquete:
  ```dart
  import 'package:mi_primera_app/screens/home_screen.dart';
  ```
- Los archivos o clases que empiezan por `_` son privados (solo visibles en su archivo).
- Código generado (`*.g.dart`, `*.freezed.dart`) no se edita a mano: se regenera con `dart run build_runner build`.

## Comandos relacionados

```bash
flutter run          # ejecutar (r = hot reload, R = hot restart)
flutter analyze      # revisar errores en lib/
dart format lib      # formatear
dart fix --apply     # aplicar correcciones automáticas
```
