// ============================================================================
// lib/features/advanced/animations_screen.dart — DEMO AVANZADA: ANIMACIONES
// ============================================================================
//
// QUÉ ENSEÑA
//   1. Animaciones IMPLÍCITAS (las más fáciles): AnimatedContainer,
//      AnimatedOpacity, AnimatedAlign… Cambias un valor con setState y el
//      widget anima solo del valor viejo al nuevo.
//   2. TweenAnimationBuilder: anima cualquier valor sin crear controladores.
//   3. Animaciones EXPLÍCITAS: AnimationController + Tween + *Transition.
//      Control total: repetir, pausar, invertir, encadenar.
//   4. Hero: un widget "vuela" entre dos pantallas.
//
// CUÁL USAR
//   ¿El widget solo cambia de un estado a otro? → implícita.
//   ¿Necesitas repetir, controlar el progreso o sincronizar varias? → explícita.
//   Para animaciones de diseñadores (After Effects) → paquetes lottie / rive.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class AnimationsScreen extends StatefulWidget {
  const AnimationsScreen({super.key});

  @override
  State<AnimationsScreen> createState() => _AnimationsScreenState();
}

// SingleTickerProviderStateMixin: da un "ticker" (un reloj sincronizado con
// los fotogramas de la pantalla, ~60-120 por segundo) al AnimationController.
// Si necesitas varios controladores: TickerProviderStateMixin.
class _AnimationsScreenState extends State<AnimationsScreen>
    with SingleTickerProviderStateMixin {
  // ---- Implícitas
  bool _expanded = false;
  bool _visible = true;

  // ---- Explícita
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // el ticker del mixin
      duration: const Duration(seconds: 2),
    );
    // Tween: transforma el progreso del controlador (0.0 → 1.0) en el rango
    // que quieras (aquí 0.8 → 1.2) aplicando una curva de aceleración.
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose(); // ⚠️ obligatorio
    super.dispose();
  }

  void _toggleExplicit() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true); // ida y vuelta infinita
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DemoScaffold(
      title: 'Animaciones',
      explanation:
          'Implícitas: cambias un valor y el widget anima solo. Explícitas: '
          'un AnimationController produce valores de 0 a 1 en cada fotograma '
          'y tú decides qué animar. Hero anima un widget entre pantallas.',
      sourceFile: 'lib/features/advanced/animations_screen.dart',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: '1. AnimatedContainer (implícita)',
            description:
                'Cambia tamaño, color y bordes con setState: Flutter anima '
                'la transición durante `duration` con la `curve` elegida.',
            // ⚠️ LECCIÓN: las animaciones solo pueden ir entre valores FINITOS.
            // `width: _expanded ? double.infinity : 120` falla con
            // "Cannot interpolate between finite constraints and unbounded
            // constraints": no existe un punto intermedio entre 120 e infinito.
            // Solución: LayoutBuilder nos da el ancho REAL disponible
            // (constraints.maxWidth) y animamos de 120 a ese número.
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  // easeOutBack se pasa un poco del final y vuelve (efecto
                  // "rebote" suave). Curvas con rebotes grandes (elasticOut)
                  // pueden producir valores fuera de rango, como un radio de
                  // borde negativo.
                  curve: Curves.easeOutBack,
                  height: _expanded ? 160 : 80,
                  width: _expanded ? constraints.maxWidth : 120,
                  decoration: BoxDecoration(
                    color: _expanded ? colors.tertiary : colors.primary,
                    borderRadius: BorderRadius.circular(_expanded ? 32 : 8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Tócame',
                    style: TextStyle(color: colors.onPrimary),
                  ),
                ),
              ),
            ),
          ),
          DemoSection(
            title: '2. AnimatedOpacity + AnimatedSlide',
            description: 'Mostrar u ocultar con fundido y desplazamiento.',
            child: Row(
              children: [
                Switch(
                  value: _visible,
                  onChanged: (v) => setState(() => _visible = v),
                ),
                const SizedBox(width: 16),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 400),
                  offset: _visible ? Offset.zero : const Offset(0.5, 0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _visible ? 1 : 0,
                    child: const Icon(Icons.rocket_launch, size: 40),
                  ),
                ),
              ],
            ),
          ),
          DemoSection(
            title: '3. TweenAnimationBuilder',
            description:
                'Anima cualquier valor (aquí un número y una barra) al '
                'construir el widget o cuando cambia `tween.end`.',
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _expanded ? 1 : 0.35),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${(value * 100).round()} %'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: value),
                ],
              ),
            ),
          ),
          DemoSection(
            title: '4. AnimationController (explícita)',
            description:
                'repeat(reverse: true) anima en bucle. ScaleTransition y '
                'RotationTransition se redibujan solos en cada fotograma.',
            child: Row(
              children: [
                // AnimatedBuilder: reconstruye su `builder` en cada fotograma
                // del controlador. Aquí combina rotación y escala.
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: ScaleTransition(scale: _scale, child: child),
                  ),
                  // `child` se construye UNA vez y se reutiliza (rendimiento).
                  child: const FlutterLogo(size: 64),
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: _toggleExplicit,
                  child: Text(_controller.isAnimating ? 'Detener' : 'Animar'),
                ),
              ],
            ),
          ),
          DemoSection(
            title: '5. Hero (entre pantallas)',
            description:
                'Toca la imagen: el mismo `tag` en ambas pantallas hace que '
                'el widget vuele de una a otra.',
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _HeroDetail()),
              ),
              child: const Hero(
                tag: 'hero-demo',
                child: CircleAvatar(
                  radius: 32,
                  child: Icon(Icons.flutter_dash, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDetail extends StatelessWidget {
  const _HeroDetail();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero')),
      body: const Center(
        child: Hero(
          tag: 'hero-demo', // ← mismo tag que en la lista
          child: CircleAvatar(
            radius: 120,
            child: Icon(Icons.flutter_dash, size: 160),
          ),
        ),
      ),
    );
  }
}
