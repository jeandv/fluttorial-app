// ============================================================================
// lib/features/basics/layout_screen.dart — DEMO BÁSICA: LAYOUT
// ============================================================================
//
// QUÉ ENSEÑA
//   Cómo colocar widgets en pantalla:
//   Row/Column · MainAxisAlignment/CrossAxisAlignment · Expanded/Flexible ·
//   Stack/Positioned · Wrap · Container/BoxDecoration · Padding/SizedBox.
//
// LA REGLA DE ORO DEL LAYOUT EN FLUTTER
//   "Las restricciones bajan, los tamaños suben, el padre decide la posición."
//   1. El padre le dice al hijo cuánto espacio tiene (min/max ancho y alto).
//   2. El hijo elige su tamaño dentro de esos límites y se lo dice al padre.
//   3. El padre coloca al hijo.
//   Por eso un Text largo dentro de una Row se "desborda" (franja amarilla y
//   negra): la Row le da ancho infinito. Solución: envolverlo en Expanded.
//
// 🧪 PRUEBA: con la app en marcha pulsa "p" en la terminal (debug paint) para
//    ver los bordes y márgenes de cada widget.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Pequeña función local para crear cajas de colores de ejemplo.
    Widget box(String label, Color color, {double size = 56}) => Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );

    return DemoScaffold(
      title: 'Layout',
      explanation:
          'Row coloca hijos en horizontal y Column en vertical. Expanded '
          'reparte el espacio sobrante, Stack superpone widgets, Wrap salta '
          'de línea cuando no caben y Container decora (color, borde, sombra).',
      sourceFile: 'lib/features/basics/layout_screen.dart',
      // ListView = Column con scroll. Úsalo cuando el contenido puede no caber.
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          DemoSection(
            title: 'Row + MainAxisAlignment.spaceBetween',
            description:
                'mainAxisAlignment reparte los hijos en el eje principal '
                '(horizontal en Row). Prueba: start, center, end, spaceAround, '
                'spaceEvenly.',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                box('A', Colors.red),
                box('B', Colors.green),
                box('C', Colors.blue),
              ],
            ),
          ),
          DemoSection(
            title: 'Column + CrossAxisAlignment',
            description:
                'crossAxisAlignment alinea en el eje cruzado (horizontal en '
                'Column). stretch hace que los hijos ocupen todo el ancho.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                box('1', Colors.purple, size: 40),
                const SizedBox(height: 8), // SizedBox = espacio fijo
                box('2', Colors.teal, size: 40),
              ],
            ),
          ),
          DemoSection(
            title: 'Expanded y Flexible (flex)',
            description:
                'Expanded reparte el espacio libre. flex: 2 ocupa el doble '
                'que flex: 1. Es la solución al error "RenderFlex overflowed".',
            child: Row(
              children: [
                Expanded(child: box('1', Colors.orange)),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: box('2', Colors.indigo)),
                const SizedBox(width: 8),
                box('fijo', Colors.grey),
              ],
            ),
          ),
          DemoSection(
            title: 'Stack + Positioned',
            description:
                'Stack superpone hijos (el último queda encima). Positioned '
                'los coloca respecto a los bordes. Típico: insignias, badges.',
            child: SizedBox(
              height: 120,
              child: Stack(
                children: [
                  Positioned.fill(child: box('fondo', colors.primary)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: box('badge', Colors.red, size: 48),
                  ),
                  const Positioned(
                    left: 12,
                    bottom: 12,
                    child: Icon(Icons.star, color: Colors.amber, size: 36),
                  ),
                ],
              ),
            ),
          ),
          DemoSection(
            title: 'Wrap',
            description:
                'Como Row, pero si no caben en una línea pasan a la siguiente. '
                'Ideal para etiquetas (chips).',
            child: Wrap(
              spacing: 8, // espacio horizontal
              runSpacing: 4, // espacio entre líneas
              children: [
                for (final tag in [
                  'Flutter',
                  'Dart',
                  'iOS',
                  'Android',
                  'Riverpod',
                  'go_router',
                  'Material 3',
                ])
                  Chip(label: Text(tag)),
              ],
            ),
          ),
          DemoSection(
            title: 'Container + BoxDecoration',
            description:
                'Container combina tamaño, padding, margin y decoración '
                '(color, degradado, borde, esquinas, sombra).',
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary, colors.tertiary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    color: Colors.black26,
                  ),
                ],
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                'Degradado + sombra + esquinas',
                style: TextStyle(color: colors.onPrimary, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
