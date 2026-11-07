// ============================================================================
// lib/core/router/app_router.dart — CONFIGURACIÓN DE NAVEGACIÓN (go_router)
// ============================================================================
//
// QUÉ HACE
//   Define TODAS las pantallas de la app y su URL, en un solo lugar:
//   - Pestañas con historial propio (StatefulShellRoute).
//   - Rutas hijas y parámetros (/posts/:id).
//   - Rutas protegidas con `redirect` (login).
//   - Pantalla de error 404 (errorBuilder).
//
// CÓMO FUNCIONA
//   1. GoRouter recibe una lista de rutas (GoRoute) en forma de árbol.
//   2. Al navegar (context.go / context.push), busca la ruta cuyo `path`
//      coincide con la URL y llama a su `builder` para crear la pantalla.
//   3. Antes de mostrarla ejecuta `redirect`: si devuelve otra URL, va allí;
//      si devuelve null, sigue normalmente.
//   4. `refreshListenable`: cuando cambia la sesión, el router vuelve a
//      ejecutar `redirect` (así el login te lleva solo a la zona privada).
//
// POR QUÉ ESTÁ EN UN PROVIDER
//   El router necesita leer otros providers (authProvider). Al crearlo dentro
//   de un Provider recibe `ref`. lib/app.dart lo obtiene con ref.watch.
//
// DEEP LINKS
//   Como cada pantalla tiene URL, se puede abrir directamente desde fuera:
//     xcrun simctl openurl booted "miprimeraapp://app/ejemplos/posts/3"
//   (requiere configurar el esquema en Android/iOS: docs/11, sección 1).
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 1)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_primera_app/core/router/routes.dart';
import 'package:mi_primera_app/features/advanced/animations_screen.dart';
import 'package:mi_primera_app/features/ai/agent_screen.dart';
import 'package:mi_primera_app/features/ai/ai_studio_screen.dart';
import 'package:mi_primera_app/features/advanced/isolates_screen.dart';
import 'package:mi_primera_app/features/advanced/native_channel.dart';
import 'package:mi_primera_app/features/advanced/responsive_screen.dart';
import 'package:mi_primera_app/features/auth/auth.dart';
import 'package:mi_primera_app/features/basics/counter_screen.dart';
import 'package:mi_primera_app/features/basics/layout_screen.dart';
import 'package:mi_primera_app/features/basics/lists_screen.dart';
import 'package:mi_primera_app/features/basics/widgets_screen.dart';
import 'package:mi_primera_app/features/catalog/catalog_screen.dart';
import 'package:mi_primera_app/features/intermediate/async_screen.dart';
import 'package:mi_primera_app/features/intermediate/forms_screen.dart';
import 'package:mi_primera_app/features/intermediate/localization_screen.dart';
import 'package:mi_primera_app/features/intermediate/navigation_screens.dart';
import 'package:mi_primera_app/features/onboarding/onboarding_controller.dart';
import 'package:mi_primera_app/features/onboarding/onboarding_screen.dart';
import 'package:mi_primera_app/features/packages/dio/dio_demo_screen.dart';
import 'package:mi_primera_app/features/packages/images_screen.dart';
import 'package:mi_primera_app/features/packages/links_share_screen.dart';
import 'package:mi_primera_app/features/packages/maps/map_screen.dart';
import 'package:mi_primera_app/features/payments/checkout_screen.dart';
import 'package:mi_primera_app/features/payments/paywall_screen.dart';
import 'package:mi_primera_app/features/posts/posts_screens.dart';
import 'package:mi_primera_app/features/settings/settings_screen.dart';
import 'package:mi_primera_app/features/shell/home_shell.dart';
import 'package:mi_primera_app/features/todos/todos_screen.dart';

/// Llave del Navigator raíz: las rutas con `parentNavigatorKey: _rootKey` se
/// muestran a pantalla completa, TAPANDO la barra de pestañas (login, privado).
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  // Puente Riverpod → Listenable: cuando cambia la sesión o el estado del
  // onboarding, notificamos al router para que vuelva a evaluar `redirect`.
  final authListenable = ValueNotifier<bool>(ref.read(authProvider));
  ref.listen(
    authProvider,
    (_, isLoggedIn) => authListenable.value = isLoggedIn,
  );
  ref.onDispose(authListenable.dispose);

  final onboardingListenable = ValueNotifier<bool>(
    ref.read(onboardingDoneProvider),
  );
  ref.listen(
    onboardingDoneProvider,
    (_, done) => onboardingListenable.value = done,
  );
  ref.onDispose(onboardingListenable.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.examples,
    // Muestra en la consola cada navegación (útil para aprender y depurar).
    debugLogDiagnostics: true,
    // Listenable.merge: escucha VARIOS Listenable a la vez.
    refreshListenable: Listenable.merge([authListenable, onboardingListenable]),

    // ----------------------------------------------------------- REDIRECT
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider);
      final onboardingDone = ref.read(onboardingDoneProvider);
      final location = state.matchedLocation;

      // 0. Primera vez que se abre la app → onboarding.
      if (!onboardingDone && location != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }
      // Ya lo vio y está en /onboarding (sin ?demo) → a la app.
      if (onboardingDone &&
          location == AppRoutes.onboarding &&
          !state.uri.queryParameters.containsKey('demo')) {
        return AppRoutes.examples;
      }

      // 1. Ruta protegida sin sesión → login (recordando a dónde iba).
      if (location == AppRoutes.private && !isLoggedIn) {
        return Uri(
          path: AppRoutes.login,
          queryParameters: {'desde': state.uri.toString()},
        ).toString();
      }
      // 2. Ya tiene sesión y está en login → a donde quería ir.
      if (location == AppRoutes.login && isLoggedIn) {
        return state.uri.queryParameters['desde'] ?? AppRoutes.private;
      }
      return null; // null = no redirigir
    },

    // ----------------------------------------------------- PÁGINA 404
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(child: Text('No existe la ruta:\n${state.uri}')),
    ),

    routes: [
      // ------------------------------------------------ PESTAÑAS (shell)
      StatefulShellRoute.indexedStack(
        // El "caparazón" que envuelve las pestañas: la barra inferior.
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          // ===================== Pestaña 1: Ejemplos =====================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.examples,
                builder: (context, state) => const CatalogScreen(),
                // Rutas HIJAS: path relativo (sin "/" inicial).
                // URL final: /ejemplos/contador, /ejemplos/layout…
                routes: [
                  GoRoute(
                    path: 'contador',
                    builder: (context, state) => const CounterScreen(),
                  ),
                  GoRoute(
                    path: 'layout',
                    builder: (context, state) => const LayoutScreen(),
                  ),
                  GoRoute(
                    path: 'widgets',
                    builder: (context, state) => const WidgetsScreen(),
                  ),
                  GoRoute(
                    path: 'listas',
                    builder: (context, state) => const ListsScreen(),
                  ),
                  GoRoute(
                    path: 'formularios',
                    builder: (context, state) => const FormsScreen(),
                  ),
                  GoRoute(
                    path: 'navegacion',
                    builder: (context, state) => const NavigationDemoScreen(),
                    routes: [
                      GoRoute(
                        path: 'elegir',
                        builder: (context, state) => const ColorPickerScreen(),
                      ),
                      GoRoute(
                        // ":id" es un PARÁMETRO de ruta.
                        path: 'detalle/:id',
                        builder: (context, state) => NavigationDetailScreen(
                          // Los parámetros llegan como String → convertir.
                          id: int.parse(state.pathParameters['id']!),
                          // Parámetro de consulta opcional (?desde=...).
                          from: state.uri.queryParameters['desde'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'asincronia',
                    builder: (context, state) => const AsyncScreen(),
                  ),
                  GoRoute(
                    path: 'posts',
                    builder: (context, state) => const PostsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => PostDetailScreen(
                          id: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'idiomas',
                    builder: (context, state) => const LocalizationScreen(),
                  ),
                  GoRoute(
                    path: 'animaciones',
                    builder: (context, state) => const AnimationsScreen(),
                  ),
                  GoRoute(
                    path: 'responsive',
                    builder: (context, state) => const ResponsiveScreen(),
                  ),
                  GoRoute(
                    path: 'nativo',
                    builder: (context, state) => const NativeChannelScreen(),
                  ),
                  GoRoute(
                    path: 'isolates',
                    builder: (context, state) => const IsolatesScreen(),
                  ),
                  // ---- Apps reales: pagos e IA (docs/14, docs/15) ----
                  GoRoute(
                    path: 'pagos',
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                  GoRoute(
                    path: 'suscripcion',
                    builder: (context, state) => const PaywallScreen(),
                  ),
                  GoRoute(
                    path: 'ia',
                    builder: (context, state) => const AiStudioScreen(),
                  ),
                  GoRoute(
                    path: 'agente',
                    builder: (context, state) => const AgentScreen(),
                  ),
                  // ---- Librerías populares (docs/12) ----
                  GoRoute(
                    path: 'mapas',
                    builder: (context, state) => const MapScreen(),
                  ),
                  GoRoute(
                    path: 'dio',
                    builder: (context, state) => const DioDemoScreen(),
                  ),
                  GoRoute(
                    path: 'imagenes',
                    builder: (context, state) => const ImagesScreen(),
                  ),
                  GoRoute(
                    path: 'enlaces',
                    builder: (context, state) => const LinksShareScreen(),
                  ),
                ],
              ),
            ],
          ),
          // ====================== Pestaña 2: Tareas ======================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.todos,
                builder: (context, state) => const TodosScreen(),
              ),
            ],
          ),
          // ===================== Pestaña 3: Ajustes ======================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ------------------------------------- RUTAS A PANTALLA COMPLETA
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => OnboardingScreen(
          demoMode: state.uri.queryParameters.containsKey('demo'),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.private,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const PrivateScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
