// ============================================================================
// lib/features/catalog/demo_catalog.dart — LISTA DE DEMOS (datos)
// ============================================================================
//
// QUÉ HACE
//   Describe cada demo como DATOS (título, descripción, icono, ruta, nivel).
//   La pantalla del catálogo (catalog_screen.dart) recorre esta lista y dibuja
//   una fila por demo.
//
// POR QUÉ SEPARAR DATOS Y PANTALLA
//   Para añadir una demo nueva solo agregas un elemento a `demos` (y su ruta
//   en app_router.dart). No tocas la interfaz. Esta separación datos/vista es
//   la base de cualquier app mantenible.
//
// 📚 Guía completa de cada demo: docs/10-funcionalidades-de-la-app.md
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/router/routes.dart';

/// Nivel de dificultad. Un `enum` es un conjunto cerrado de valores.
/// `product` = funcionalidades de apps reales: onboarding, pagos, IA (docs/13-15).
/// `packages` = demos de las librerías más usadas (ver docs/12).
enum DemoLevel { basic, intermediate, advanced, product, packages }

/// Datos de una demo. Todas las propiedades son `final` y el constructor es
/// `const`, así la lista completa puede ser una constante.
class Demo {
  const Demo({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.level,
  });

  final String title;
  final String description;
  final IconData icon;
  final String route;
  final DemoLevel level;
}

const demos = <Demo>[
  // ---------------------------------------------------------------- BÁSICO
  Demo(
    title: 'Contador (setState)',
    description: 'StatefulWidget, setState y ciclo de vida',
    icon: Icons.exposure_plus_1,
    route: AppRoutes.counter,
    level: DemoLevel.basic,
  ),
  Demo(
    title: 'Layout',
    description: 'Row, Column, Expanded, Stack, Wrap, Container',
    icon: Icons.dashboard_outlined,
    route: AppRoutes.layout,
    level: DemoLevel.basic,
  ),
  Demo(
    title: 'Widgets comunes',
    description: 'Textos, botones, controles, diálogos y SnackBars',
    icon: Icons.widgets_outlined,
    route: AppRoutes.widgets,
    level: DemoLevel.basic,
  ),
  Demo(
    title: 'Listas y cuadrículas',
    description: 'ListView.builder, GridView, Dismissible, pull-to-refresh',
    icon: Icons.view_list_outlined,
    route: AppRoutes.lists,
    level: DemoLevel.basic,
  ),

  // ------------------------------------------------------------ INTERMEDIO
  Demo(
    title: 'Formularios',
    description: 'Form, validación, controladores, foco y selector de fecha',
    icon: Icons.edit_note,
    route: AppRoutes.forms,
    level: DemoLevel.intermediate,
  ),
  Demo(
    title: 'Navegación',
    description: 'go_router: parámetros, devolver resultados, rutas protegidas',
    icon: Icons.alt_route,
    route: AppRoutes.navigation,
    level: DemoLevel.intermediate,
  ),
  Demo(
    title: 'Asincronía',
    description: 'Future, async/await, FutureBuilder y StreamBuilder',
    icon: Icons.hourglass_bottom,
    route: AppRoutes.async,
    level: DemoLevel.intermediate,
  ),
  Demo(
    title: 'API REST',
    description: 'http + JSON + Riverpod (FutureProvider, family, refresh)',
    icon: Icons.cloud_download_outlined,
    route: AppRoutes.posts,
    level: DemoLevel.intermediate,
  ),
  Demo(
    title: 'Idiomas (i18n)',
    description: 'Traducciones .arb, plurales, fechas y monedas con intl',
    icon: Icons.translate,
    route: AppRoutes.localization,
    level: DemoLevel.intermediate,
  ),

  // -------------------------------------------------------------- AVANZADO
  Demo(
    title: 'Animaciones',
    description: 'Implícitas, explícitas (AnimationController) y Hero',
    icon: Icons.animation,
    route: AppRoutes.animations,
    level: DemoLevel.advanced,
  ),
  Demo(
    title: 'Diseño adaptable',
    description: 'LayoutBuilder, MediaQuery y widgets .adaptive',
    icon: Icons.devices,
    route: AppRoutes.responsive,
    level: DemoLevel.advanced,
  ),
  Demo(
    title: 'Código nativo',
    description: 'MethodChannel: Dart ↔ Kotlin (Android) y Swift (iOS)',
    icon: Icons.memory,
    route: AppRoutes.nativeChannel,
    level: DemoLevel.advanced,
  ),
  Demo(
    title: 'Isolates',
    description: 'Trabajo pesado en segundo plano sin congelar la interfaz',
    icon: Icons.speed,
    route: AppRoutes.isolates,
    level: DemoLevel.advanced,
  ),

  // ------------------------------------------------------------ APPS REALES
  // Funcionalidades que casi toda app publicada necesita (docs/13, 14, 15).
  Demo(
    title: 'Onboarding',
    description: 'Bienvenida con páginas, indicador, parallax y primer uso',
    icon: Icons.waving_hand_outlined,
    route: AppRoutes.onboardingDemo,
    level: DemoLevel.product,
  ),
  Demo(
    title: 'Pago (checkout)',
    description: 'Carrito, tarjeta con validación, Apple/Google Pay, recibo',
    icon: Icons.shopping_cart_checkout,
    route: AppRoutes.checkout,
    level: DemoLevel.product,
  ),
  Demo(
    title: 'Suscripción (paywall)',
    description: 'Planes, prueba gratis, restaurar compras, textos legales',
    icon: Icons.workspace_premium_outlined,
    route: AppRoutes.paywall,
    level: DemoLevel.product,
  ),
  Demo(
    title: 'Estudio IA',
    description: 'Claude: consejos en streaming, documentos e ilustraciones',
    icon: Icons.auto_awesome,
    route: AppRoutes.aiStudio,
    level: DemoLevel.product,
  ),
  Demo(
    title: 'Agente IA',
    description: 'Un agente que usa herramientas para gestionar tus tareas',
    icon: Icons.smart_toy_outlined,
    route: AppRoutes.agent,
    level: DemoLevel.product,
  ),

  // ---------------------------------------------------- LIBRERÍAS POPULARES
  // Elegidas por descargas y demanda laboral: ver docs/12.
  Demo(
    title: 'Mapas',
    description:
        'flutter_map + OpenStreetMap, marcadores, rutas y tu ubicación',
    icon: Icons.map_outlined,
    route: AppRoutes.maps,
    level: DemoLevel.packages,
  ),
  Demo(
    title: 'Dio',
    description: 'Cliente HTTP profesional: interceptores, errores, cancelar',
    icon: Icons.http,
    route: AppRoutes.dio,
    level: DemoLevel.packages,
  ),
  Demo(
    title: 'Imágenes en caché',
    description: 'cached_network_image + efecto shimmer de carga',
    icon: Icons.photo_library_outlined,
    route: AppRoutes.images,
    level: DemoLevel.packages,
  ),
  Demo(
    title: 'Enlaces y compartir',
    description: 'url_launcher (web, teléfono, email, mapas) + share_plus',
    icon: Icons.share_outlined,
    route: AppRoutes.linksShare,
    level: DemoLevel.packages,
  ),
];
