# Solución · e04 · Tu propia demo

> Inténtalo antes de leer esto. Test: [`e04_mi_demo_test.dart`](../e04_mi_demo_test.dart).

## La idea

Una demo son tres piezas: la pantalla, su ruta y su entrada en el catálogo (que es una lista de datos).

## Qué cambiar

**1. Pantalla nueva** · `lib/features/basics/mi_demo_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class MiDemoScreen extends StatelessWidget {
  const MiDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoScaffold(
      title: 'Mi demo',
      explanation: 'Mi primera demo añadida al catálogo.',
      sourceFile: 'lib/features/basics/mi_demo_screen.dart',
      body: Center(child: Text('¡Hola desde mi demo!')),
    );
  }
}
```

**2. Ruta** · `lib/core/router/routes.dart`, junto a las demás del nivel básico:

```dart
static const miDemo = '$examples/mi-demo';
```

**3. GoRoute** · `lib/core/router/app_router.dart`: añade el import y, junto a la ruta `contador`, dentro de la misma lista de rutas hijas:

```dart
import 'package:mi_primera_app/features/basics/mi_demo_screen.dart';
```

```dart
GoRoute(
  path: 'mi-demo',
  builder: (context, state) => const MiDemoScreen(),
),
```

**4. Entrada en el catálogo** · `lib/features/catalog/demo_catalog.dart`, al final del nivel básico (tras "Listas y cuadrículas"):

```dart
Demo(
  title: 'Mi demo',
  description: 'Mi primera demo',
  icon: Icons.star_outline,
  route: AppRoutes.miDemo,
  level: DemoLevel.basic,
),
```

## Por qué funciona

- El catálogo recorre `demos` y dibuja una fila por elemento: la nueva aparece sola.
- Al tocarla se hace `push` a `AppRoutes.miDemo`; el `GoRoute` con `path: 'mi-demo'` (hijo de `/ejemplos`) construye `MiDemoScreen`.
- `DemoScaffold` aporta el AppBar con botón de volver.
