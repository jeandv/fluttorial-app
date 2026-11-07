// ============================================================================
// lib/features/advanced/responsive_screen.dart — DEMO: DISEÑO ADAPTABLE
// ============================================================================
//
// QUÉ ENSEÑA
//   - MediaQuery: tamaño de pantalla, orientación, márgenes seguros (notch,
//     isla dinámica), escala de texto del usuario, modo oscuro del sistema.
//   - LayoutBuilder: adaptar el diseño al espacio DISPONIBLE para el widget
//     (no a la pantalla entera). Breakpoints: móvil / tablet / escritorio.
//   - Widgets .adaptive: aspecto nativo de iOS en iPhone y de Material en
//     Android con una sola línea.
//   - Theme.of(context).platform: saber en qué plataforma se ejecuta.
//
// 🧪 PRUEBA: rota el simulador (Cmd+← / Cmd+→) o ejecuta en un iPad / tablet
//    y observa cómo cambia el número de columnas.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';

class ResponsiveScreen extends StatefulWidget {
  const ResponsiveScreen({super.key});

  @override
  State<ResponsiveScreen> createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {
  bool _switch = true;
  double _slider = 0.5;

  @override
  Widget build(BuildContext context) {
    // Los métodos .sizeOf / .orientationOf / ... solo redibujan el widget
    // cuando cambia ESE dato (más eficiente que MediaQuery.of(context)).
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    final padding = MediaQuery.paddingOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final platform = Theme.of(context).platform;

    return DemoScaffold(
      title: 'Diseño adaptable',
      explanation:
          'MediaQuery informa del tamaño y ajustes de la pantalla. '
          'LayoutBuilder da el espacio disponible para elegir un diseño u '
          'otro. Los constructores .adaptive usan el estilo nativo de cada '
          'plataforma.',
      sourceFile: 'lib/features/advanced/responsive_screen.dart',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: 'MediaQuery',
            description: 'Información de la pantalla actual.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tamaño: ${size.width.round()} × ${size.height.round()} '
                  'puntos lógicos',
                ),
                Text('Orientación: ${orientation.name}'),
                Text(
                  'Margen seguro: arriba ${padding.top.round()}, '
                  'abajo ${padding.bottom.round()}',
                ),
                Text('Escala de texto: ×${textScale.toStringAsFixed(2)}'),
                Text('Tema del sistema: ${brightness.name}'),
                Text('Plataforma: ${platform.name}'),
              ],
            ),
          ),
          DemoSection(
            title: 'LayoutBuilder + breakpoints',
            description:
                '< 600: 1 columna (móvil) · 600-900: 2 (tablet) · '
                '> 900: 3 (escritorio). Basado en el ancho disponible.',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width < 600 ? 1 : (width < 900 ? 2 : 3);
                final label = switch (columns) {
                  1 => 'Móvil',
                  2 => 'Tablet',
                  _ => 'Escritorio',
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ancho disponible: ${width.round()} → $label '
                      '($columns columna${columns > 1 ? 's' : ''})',
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: columns,
                      // shrinkWrap + NeverScrollable: un GridView dentro de
                      // un ListView (el scroll lo hace el ListView padre).
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        for (var i = 1; i <= 6; i++)
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Tarjeta $i'),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          DemoSection(
            title: 'Widgets .adaptive',
            description:
                'En iPhone se ven como iOS (Cupertino); en Android como '
                'Material. Pulsa "o" en la terminal de flutter run para '
                'alternar la plataforma simulada.',
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Switch.adaptive'),
                    const Spacer(),
                    Switch.adaptive(
                      value: _switch,
                      onChanged: (v) => setState(() => _switch = v),
                    ),
                  ],
                ),
                Slider.adaptive(
                  value: _slider,
                  onChanged: (v) => setState(() => _slider = v),
                ),
                const SizedBox(height: 8),
                const CircularProgressIndicator.adaptive(),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => showAdaptiveDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog.adaptive(
                      title: const Text('Diálogo adaptable'),
                      content: const Text(
                        'Estilo iOS en iPhone, Material en Android.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('AlertDialog.adaptive'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
