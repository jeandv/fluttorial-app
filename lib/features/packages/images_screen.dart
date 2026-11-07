// ============================================================================
// lib/features/packages/images_screen.dart — DEMO: IMÁGENES DE RED EN CACHÉ
// ============================================================================
//
// QUÉ ENSEÑA
//   - cached_network_image: descarga una imagen UNA vez y la guarda en el
//     disco del teléfono. Las siguientes veces (incluso tras cerrar la app)
//     se carga desde la caché: más rápido, menos datos móviles, funciona
//     sin conexión.
//   - placeholder: qué mostrar mientras se descarga.
//   - errorWidget: qué mostrar si la URL falla.
//   - shimmer: el efecto de "brillo" de carga (skeleton) que usan las apps
//     grandes (Facebook, LinkedIn, YouTube…).
//
// Image.network vs CachedNetworkImage
//   Image.network (de Flutter) también funciona, pero solo cachea en MEMORIA:
//   al cerrar la app se pierde y vuelve a descargar todo.
//
// Fotos de ejemplo: https://picsum.photos (gratis, sin registro).
// ============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:shimmer/shimmer.dart';

/// URL de una foto de picsum.photos por id y tamaño.
String picsumUrl(int id, {int width = 400, int height = 300}) =>
    'https://picsum.photos/id/$id/$width/$height';

class ImagesScreen extends StatefulWidget {
  const ImagesScreen({super.key});

  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  static const _photoIds = [10, 11, 15, 16, 17, 20, 22, 24, 25, 28, 29, 37];

  /// Cambiar esta key obliga a reconstruir la cuadrícula (tras limpiar caché).
  int _generation = 0;

  Future<void> _clearCache() async {
    // Borra cada imagen de la caché (memoria + disco).
    for (final id in _photoIds) {
      await CachedNetworkImage.evictFromCache(picsumUrl(id));
    }
    if (!mounted) return;
    setState(() => _generation++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caché vaciada: se descargarán de nuevo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Imágenes en caché',
      explanation:
          'cached_network_image guarda las imágenes en el disco: la segunda '
          'vez aparecen al instante y funcionan sin internet. Mientras se '
          'descargan se ve un efecto shimmer. Pulsa 🧹 para vaciar la caché.',
      sourceFile: 'lib/features/packages/images_screen.dart',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Sal de la pantalla y vuelve: las fotos ya no se '
                      'descargan, salen de la caché.',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Vaciar caché',
                    onPressed: _clearCache,
                    icon: const Icon(Icons.cleaning_services_outlined),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid.builder(
              key: ValueKey(_generation),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 4 / 3,
              ),
              // +1: la última celda usa una URL rota para ver errorWidget.
              itemCount: _photoIds.length + 1,
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: index < _photoIds.length
                      ? picsumUrl(_photoIds[index])
                      : 'https://picsum.photos/esta-url-no-existe.jpg',
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  // Mientras descarga: rectángulo con brillo animado.
                  placeholder: (context, url) => const ShimmerBox(),
                  // Si falla (404, sin red…): icono de imagen rota.
                  errorWidget: (context, url, error) => ColoredBox(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rectángulo "esqueleto" con efecto shimmer. Reutilizable en cualquier
/// pantalla que cargue datos (listas, perfiles, tarjetas…).
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHighest,
      highlightColor: colors.surface,
      child: ColoredBox(color: colors.surfaceContainerHighest),
    );
  }
}
