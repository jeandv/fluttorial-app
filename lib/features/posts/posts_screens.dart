// ============================================================================
// lib/features/posts/posts_screens.dart — DEMO: API REST (lista + detalle)
// ============================================================================
//
// QUÉ ENSEÑA
//   - ConsumerWidget: un StatelessWidget que puede leer providers (`ref`).
//   - ref.watch(provider): obtiene el valor Y redibuja cuando cambia.
//   - AsyncValue.when(loading/error/data): dibujar cada estado de la petición.
//   - RefreshIndicator + ref.refresh: tirar hacia abajo para volver a pedir.
//   - Provider con parámetro (.family): postProvider(id) en el detalle.
//   - Hero: animación compartida del avatar entre la lista y el detalle.
//
// FLUJO
//   1. La pantalla hace ref.watch(postsProvider).
//   2. Riverpod ejecuta la petición la PRIMERA vez y guarda el resultado.
//   3. Mientras tanto la UI recibe AsyncLoading → muestra un spinner.
//   4. Cuando llega la respuesta → AsyncData → muestra la lista.
//      Si falla → AsyncError → muestra el error y un botón "Reintentar".
//   (Riverpod 3 además REINTENTA automáticamente los providers que fallan.)
//
// 🧪 PRUEBA: activa el modo avión en el simulador/emulador y entra en la demo
//    para ver el estado de error.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_primera_app/core/router/routes.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:mi_primera_app/features/posts/post.dart';
import 'package:mi_primera_app/features/posts/posts_repository.dart';

class PostsScreen extends ConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch: escucha el provider. Cuando cambie su estado, build() se
    // vuelve a ejecutar.
    final postsAsync = ref.watch(postsProvider);

    return DemoScaffold(
      title: 'API REST',
      explanation:
          'Descarga posts de jsonplaceholder.typicode.com con el paquete http, '
          'convierte el JSON en objetos Post y los expone con un '
          'FutureProvider de Riverpod. La UI dibuja los 3 estados con '
          'AsyncValue.when: cargando, error y datos.',
      sourceFile: 'lib/features/posts/',
      body: RefreshIndicator(
        // ref.refresh invalida la caché y devuelve el nuevo Future: el
        // indicador gira hasta que termina la nueva petición.
        onRefresh: () => ref.refresh(postsProvider.future),
        child: postsAsync.when(
          // Mientras se recarga con "pull to refresh", sigue mostrando los
          // datos anteriores en vez del spinner (skipLoadingOnRefresh: true
          // por defecto).
          data: (posts) => ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _PostTile(post: posts[index]),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _ErrorView(
            message: error.toString(),
            // ref.invalidate: descarta el estado y vuelve a ejecutar.
            onRetry: () => ref.invalidate(postsProvider),
          ),
        ),
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Hero: mismo `tag` en la lista y en el detalle → Flutter anima el
      // avatar "volando" de una pantalla a otra.
      leading: Hero(
        tag: 'post-avatar-${post.id}',
        child: CircleAvatar(child: Text('${post.id}')),
      ),
      title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: () => context.push(AppRoutes.postDetail(post.id)),
    );
  }
}

/// Pantalla de detalle: pide UN post por su id (provider con parámetro).
class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cada id tiene su propia caché: postProvider(1), postProvider(2)…
    final postAsync = ref.watch(postProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text('Post #$id')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(postProvider(id)),
        ),
        data: (post) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Hero(
                tag: 'post-avatar-${post.id}',
                child: CircleAvatar(radius: 40, child: Text('${post.id}')),
              ),
            ),
            const SizedBox(height: 24),
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Autor (userId): ${post.userId}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Divider(height: 32),
            Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

/// Vista de error reutilizable con botón "Reintentar".
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // ListView (y no Column) para que "pull to refresh" funcione también
    // en el estado de error.
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Icon(
          Icons.cloud_off,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}
