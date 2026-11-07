// ============================================================================
// lib/features/catalog/catalog_screen.dart — PANTALLA "EJEMPLOS" (pestaña 1)
// ============================================================================
//
// QUÉ HACE
//   Muestra todas las demos agrupadas por nivel (Básico, Intermedio, Avanzado).
//   Al tocar una, navega a su pantalla con `context.push(ruta)`.
//
// CÓMO FUNCIONA
//   - CustomScrollView + "slivers": la forma avanzada de construir listas con
//     scroll que mezclan distintos tipos de contenido (cabeceras, listas…).
//     SliverAppBar.large hace que el título grande se encoja al hacer scroll.
//   - Para cada nivel se filtra `demos` con `.where(...)` y se genera una
//     cabecera + una fila por demo con colecciones `for` dentro de la lista.
//   - Los colores de cada nivel vienen de la extensión de tema LevelColors.
//   - Los nombres de los niveles vienen de las traducciones (AppLocalizations).
//
// 📚 Guía: docs/10-funcionalidades-de-la-app.md
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_primera_app/core/theme/app_theme.dart';
import 'package:mi_primera_app/features/catalog/demo_catalog.dart';
import 'package:mi_primera_app/l10n/app_localizations.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levelColors = Theme.of(context).extension<LevelColors>()!;

    // Mapa nivel → (nombre traducido, color).
    final levels = {
      DemoLevel.basic: (l10n.levelBasic, levelColors.basic),
      DemoLevel.intermediate: (
        l10n.levelIntermediate,
        levelColors.intermediate,
      ),
      DemoLevel.advanced: (l10n.levelAdvanced, levelColors.advanced),
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(l10n.tabExamples)),
          // Por cada nivel: cabecera + filas de sus demos.
          for (final MapEntry(key: level, value: (name, color))
              in levels.entries) ...[
            SliverToBoxAdapter(
              child: _LevelHeader(name: name, color: color),
            ),
            SliverList.list(
              children: [
                for (final demo in demos.where((d) => d.level == level))
                  _DemoTile(demo: demo, color: color),
              ],
            ),
          ],
          // Espacio final para que el último elemento no quede pegado.
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: color, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.demo, required this.color});

  final Demo demo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        child: Icon(demo.icon),
      ),
      title: Text(demo.title),
      subtitle: Text(demo.description),
      trailing: const Icon(Icons.chevron_right),
      // push: apila la pantalla de la demo (con flecha "atrás").
      onTap: () => context.push(demo.route),
    );
  }
}
