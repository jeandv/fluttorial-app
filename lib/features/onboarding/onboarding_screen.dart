// ============================================================================
// lib/features/onboarding/onboarding_screen.dart — PANTALLAS DE BIENVENIDA
// ============================================================================
//
// QUÉ ENSEÑA
//   El "onboarding" son las pantallas que ve un usuario la PRIMERA vez que
//   abre una app: presentan el valor de la app, piden permisos o preferencias
//   y terminan con un botón "Empezar". Aquí se usa:
//   - PageView + PageController: páginas que se deslizan horizontalmente.
//   - smooth_page_indicator: los puntos que indican la página actual.
//   - Botones "Saltar" / "Siguiente" / "Empezar" con animaciones.
//   - Efecto parallax: el icono se mueve más despacio que el texto
//     (AnimatedBuilder sobre el PageController).
//   - Personalización en la última página (tema claro/oscuro).
//   - Persistencia: al terminar, se guarda que ya se vio (no vuelve a salir).
//
// FLUJO
//   1ª apertura → redirect del router manda a /onboarding
//   "Empezar" o "Saltar" → OnboardingController.complete() guarda `true`
//   → el router re-evalúa redirect → te lleva a /ejemplos.
//   Desde el catálogo se abre en "modo demo" (?demo=1): al terminar, vuelve atrás.
//
// BUENAS PRÁCTICAS (ver docs/13)
//   - 3-5 páginas como máximo. Siempre un botón "Saltar".
//   - Pide permisos EN CONTEXTO (cuando se van a usar), no todos al inicio.
//   - Que sea posible volver a verlo (Ajustes → "Ver onboarding").
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_primera_app/core/router/routes.dart';
import 'package:mi_primera_app/core/settings/settings_controller.dart';
import 'package:mi_primera_app/features/onboarding/onboarding_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Datos de una página. Separar datos y UI facilita añadir/quitar páginas.
class OnboardingPage {
  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
}

const onboardingPages = <OnboardingPage>[
  OnboardingPage(
    icon: Icons.waving_hand_rounded,
    title: '¡Bienvenido a tu guía de Flutter!',
    body:
        'Una app real para aprender a crear apps para iOS y Android, con '
        'cada ejemplo comentado paso a paso.',
    color: Color(0xFF5C6BC0),
  ),
  OnboardingPage(
    icon: Icons.school_rounded,
    title: 'Aprende con ejemplos vivos',
    body:
        'Más de 20 demos: desde un contador hasta mapas, pagos e IA. Pulsa ⓘ '
        'en cada una para ver qué enseña y dónde está su código.',
    color: Color(0xFF26A69A),
  ),
  OnboardingPage(
    icon: Icons.check_circle_rounded,
    title: 'Tu progreso se guarda',
    body:
        'Las tareas, el tema y el idioma se guardan en el teléfono: siguen ahí '
        'aunque cierres la app.',
    color: Color(0xFFEF6C00),
  ),
  OnboardingPage(
    icon: Icons.palette_rounded,
    title: 'Hazla tuya',
    body: 'Elige cómo quieres ver la app. Podrás cambiarlo luego en Ajustes.',
    color: Color(0xFFAB47BC),
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.demoMode = false});

  /// true cuando se abre desde el catálogo (no es la primera vez).
  final bool demoMode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == onboardingPages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingDoneProvider.notifier).complete();
    if (!mounted) return;
    // Modo demo: volver a donde estábamos. Primera vez: el redirect del
    // router ya nos lleva a /ejemplos; go() es solo por seguridad.
    if (widget.demoMode && context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.examples);
    }
  }

  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final page = onboardingPages[_page];

    // AnimatedContainer: el color de fondo cambia suavemente con la página.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: Color.alphaBlend(
        page.color.withValues(alpha: 0.12),
        Theme.of(context).colorScheme.surface,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // ------------------------------------------------- Saltar
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isLast ? 0 : 1, // se oculta en la última página
                  child: TextButton(
                    onPressed: _isLast ? null : _finish,
                    child: const Text('Saltar'),
                  ),
                ),
              ),
              // ------------------------------------------------- Páginas
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingPages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) => _PageContent(
                    page: onboardingPages[index],
                    index: index,
                    controller: _controller,
                    footer: index == onboardingPages.length - 1
                        ? const _ThemePicker()
                        : null,
                  ),
                ),
              ),
              // ------------------------------------ Indicador + botón
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    // smooth_page_indicator: se sincroniza solo con el
                    // PageController (también se anima mientras deslizas).
                    SmoothPageIndicator(
                      controller: _controller,
                      count: onboardingPages.length,
                      onDotClicked: (i) => _controller.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      ),
                      effect: ExpandingDotsEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: page.color,
                        dotColor: page.color.withValues(alpha: 0.3),
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: page.color,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLast ? _finish : _next,
                      // AnimatedSwitcher: anima el cambio de texto del botón.
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _isLast ? 'Empezar' : 'Siguiente',
                          key: ValueKey(_isLast),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contenido de una página con efecto parallax.
class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.page,
    required this.index,
    required this.controller,
    this.footer,
  });

  final OnboardingPage page;
  final int index;
  final PageController controller;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Distancia de esta página respecto a la visible (0 = centrada).
        final position =
            controller.hasClients && controller.position.haveDimensions
            ? (controller.page ?? 0) - index
            : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // El icono se desplaza a la MITAD de velocidad → parallax.
              Transform.translate(
                offset: Offset(position * 120, 0),
                child: Opacity(
                  opacity: (1 - position.abs()).clamp(0, 1),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: page.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(page.icon, size: 88, color: page.color),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                page.body,
                textAlign: TextAlign.center,
                style: text.bodyLarge,
              ),
              if (footer != null) ...[const SizedBox(height: 32), footer!],
            ],
          ),
        );
      },
    );
  }
}

/// Personalización en el propio onboarding: elegir el tema.
class _ThemePicker extends ConsumerWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider).themeMode;
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode),
          label: Text('Claro'),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.brightness_auto),
          label: Text('Auto'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text('Oscuro'),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) =>
          ref.read(settingsProvider.notifier).setThemeMode(s.first),
    );
  }
}
