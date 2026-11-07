// ============================================================================
// lib/core/widgets/demo_scaffold.dart — WIDGETS REUTILIZABLES DEL CATÁLOGO
// ============================================================================
//
// QUÉ HACE
//   - DemoScaffold: pantalla base de cada demo. Añade un botón (i) en la barra
//     superior que abre una hoja inferior explicando qué enseña la demo y en
//     qué archivo está su código.
//   - DemoSection: bloque con título, explicación y el ejemplo en vivo.
//
// POR QUÉ EXISTE
//   Es el patrón "extraer widgets reutilizables": en lugar de copiar el mismo
//   Scaffold + AppBar + botón en 15 pantallas, se escribe una vez aquí.
//   Si mañana quieres cambiar el diseño de todas las demos, lo cambias aquí.
//
// 📚 Guía: docs/06-construir-la-app.md (sección 3)
// ============================================================================

import 'package:flutter/material.dart';

/// Pantalla base para las demos.
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    super.key,
    required this.title,
    required this.explanation,
    required this.sourceFile,
    required this.body,
    this.floatingActionButton,
    this.bottom,
  });

  final String title;

  /// Qué enseña la demo (se muestra al pulsar el botón ⓘ).
  final String explanation;

  /// Ruta del archivo con el código de la demo, para ir a leerlo.
  final String sourceFile;

  final Widget body;
  final Widget? floatingActionButton;

  /// Widget opcional bajo la AppBar (por ejemplo, un TabBar).
  final PreferredSizeWidget? bottom;

  void _showInfo(BuildContext context) {
    // showModalBottomSheet: hoja que sube desde abajo. Devuelve un Future que
    // termina cuando se cierra.
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true, // la "rayita" para arrastrar
      isScrollControlled: true, // permite que sea más alta que media pantalla
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ocupa solo lo necesario
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(explanation),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.code, size: 18),
                  const SizedBox(width: 8),
                  // Expanded: el texto ocupa el espacio restante y hace salto
                  // de línea en vez de desbordarse.
                  Expanded(
                    child: SelectableText(
                      sourceFile,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: bottom,
        actions: [
          IconButton(
            tooltip: '¿Qué enseña esta demo?',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Bloque de una demo: título + descripción + ejemplo en vivo.
class DemoSection extends StatelessWidget {
  const DemoSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
