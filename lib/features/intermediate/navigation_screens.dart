// ============================================================================
// lib/features/intermediate/navigation_screens.dart — DEMO: NAVEGACIÓN
// ============================================================================
//
// QUÉ ENSEÑA (con go_router)
//   1. context.push(ruta)        → abre una pantalla ENCIMA (con botón atrás).
//   2. context.go(ruta)          → va a una ruta REEMPLAZANDO el historial.
//   3. Parámetros de ruta        → /detalle/:id     → state.pathParameters['id']
//   4. Parámetros de consulta    → ?desde=demo      → state.uri.queryParameters
//   5. Devolver un resultado     → final r = await context.push<T>(...);
//                                  y en la otra pantalla: context.pop(valor)
//   6. Navigator clásico         → Navigator.push(MaterialPageRoute(...))
//   7. Ruta protegida            → /privado redirige a /login si no hay sesión
//                                  (la lógica está en app_router.dart → redirect)
//
// DIFERENCIA push vs go
//   push: añade una pantalla a la pila  [catálogo] → [catálogo, detalle]
//   go:   cambia la ubicación completa  [catálogo, detalle] → [tareas]
//   Regla práctica: push para "entrar en detalle", go para "cambiar de sección".
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 1)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_primera_app/core/router/routes.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

/// Pantalla principal de la demo.
class NavigationDemoScreen extends StatefulWidget {
  const NavigationDemoScreen({super.key});

  @override
  State<NavigationDemoScreen> createState() => _NavigationDemoScreenState();
}

class _NavigationDemoScreenState extends State<NavigationDemoScreen> {
  String? _pickedColor;

  /// Abre la pantalla de selección y ESPERA el resultado.
  Future<void> _pickColor() async {
    // push<T> devuelve un Future<T?> que se completa cuando la otra pantalla
    // hace context.pop(valor). Si el usuario vuelve atrás sin elegir: null.
    final result = await context.push<String>(AppRoutes.navigationPicker);
    if (!mounted) return;
    setState(() => _pickedColor = result ?? 'ninguno (volviste atrás)');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Navegación',
      explanation:
          'go_router gestiona las pantallas con URLs. push apila una pantalla, '
          'go reemplaza el historial, pop vuelve atrás (y puede devolver un '
          'valor). Las rutas se definen en lib/core/router/app_router.dart.',
      sourceFile: 'lib/features/intermediate/navigation_screens.dart',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: '1. push con parámetros',
            description:
                'Abre /ejemplos/navegacion/detalle/42?desde=demo. El 42 es un '
                'parámetro de ruta y "desde" un parámetro de consulta.',
            child: FilledButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.navigationDetail(42, from: 'demo')),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir detalle #42'),
            ),
          ),
          DemoSection(
            title: '2. Esperar un resultado',
            description:
                'La pantalla de selección devuelve un valor con '
                'context.pop(valor).',
            child: Row(
              children: [
                FilledButton.tonal(
                  onPressed: _pickColor,
                  child: const Text('Elegir color'),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Resultado: ${_pickedColor ?? '—'}')),
              ],
            ),
          ),
          DemoSection(
            title: '3. go: cambiar de sección',
            description:
                'context.go reemplaza la ubicación: te lleva a la pestaña '
                'Tareas (la barra inferior se actualiza sola).',
            child: OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.todos),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Ir a Tareas'),
            ),
          ),
          DemoSection(
            title: '4. Navigator clásico (sin go_router)',
            description:
                'La API original de Flutter. Útil para pantallas temporales '
                'que no necesitan URL propia.',
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _ClassicScreen(),
                  fullscreenDialog: true, // se abre desde abajo con una ✕
                ),
              ),
              child: const Text('Abrir con Navigator.push'),
            ),
          ),
          DemoSection(
            title: '5. Ruta protegida (redirect)',
            description:
                'Si no has iniciado sesión, /privado te redirige a /login. '
                'Tras iniciar sesión vuelves automáticamente a /privado.',
            child: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.private),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Abrir zona privada'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de detalle: recibe los parámetros desde el router.
class NavigationDetailScreen extends StatelessWidget {
  const NavigationDetailScreen({super.key, required this.id, this.from});

  final int id;
  final String? from;

  @override
  Widget build(BuildContext context) {
    // GoRouterState.of(context) da acceso a la URL actual completa.
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      appBar: AppBar(title: Text('Detalle #$id')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('id (pathParameters): $id'),
              Text('desde (queryParameters): ${from ?? '—'}'),
              const SizedBox(height: 8),
              SelectableText(
                'URL: $location',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                // Abre el detalle siguiente apilado: prueba a volver atrás.
                onPressed: () =>
                    context.push(AppRoutes.navigationDetail(id + 1)),
                child: Text('Abrir detalle #${id + 1}'),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Volver (context.pop)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla que DEVUELVE un valor a quien la abrió.
class ColorPickerScreen extends StatelessWidget {
  const ColorPickerScreen({super.key});

  static const _options = {
    'Rojo': Colors.red,
    'Verde': Colors.green,
    'Azul': Colors.blue,
    'Ámbar': Colors.amber,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elige un color')),
      body: ListView(
        children: [
          for (final MapEntry(key: name, value: color) in _options.entries)
            ListTile(
              leading: CircleAvatar(backgroundColor: color),
              title: Text(name),
              // pop(valor) cierra la pantalla y entrega `name` al `await`.
              onTap: () => context.pop(name),
            ),
        ],
      ),
    );
  }
}

class _ClassicScreen extends StatelessWidget {
  const _ClassicScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigator.push')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Esta pantalla se abrió con Navigator.of(context).push y '
            'MaterialPageRoute. No tiene URL propia.\n\n'
            'Ciérrala con la ✕ o con Navigator.of(context).pop().',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
