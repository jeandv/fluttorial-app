// ============================================================================
// lib/features/shell/home_shell.dart — BARRA DE NAVEGACIÓN INFERIOR (pestañas)
// ============================================================================
//
// QUÉ HACE
//   Dibuja la barra inferior con 3 pestañas (Ejemplos, Tareas, Ajustes) y, en
//   el centro, la pantalla de la pestaña activa.
//
// CÓMO FUNCIONA (go_router: StatefulShellRoute)
//   - En app_router.dart, StatefulShellRoute.indexedStack define 3 "ramas"
//     (branches), una por pestaña. Cada rama tiene su PROPIO historial.
//   - go_router construye este widget y le pasa `navigationShell`, que:
//       · es el contenido de la pestaña activa (se pone en `body`),
//       · sabe qué pestaña está activa (`currentIndex`),
//       · cambia de pestaña con `goBranch(index)`.
//   - "indexedStack" mantiene vivas las 3 pestañas: si entras en una demo,
//     cambias a Tareas y vuelves, sigues dentro de la demo.
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 1)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_primera_app/l10n/app_localizations.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      // Si tocas la pestaña en la que ya estás, vuelve a su pantalla inicial
      // (comportamiento estándar en iOS y Android).
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      // NavigationBar = barra inferior de Material 3.
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: l10n.tabExamples,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: const Icon(Icons.check_circle),
            label: l10n.tabTodos,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
