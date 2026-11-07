// ============================================================================
// lib/features/posts/posts_repository.dart — REPOSITORIO + PROVIDERS
// ============================================================================
//
// QUÉ HACE
//   - PostsRepository: la ÚNICA clase que sabe de dónde salen los posts
//     (aquí, una API REST). La interfaz nunca llama a `http` directamente.
//   - Providers de Riverpod que exponen los datos a la interfaz.
//
// ARQUITECTURA EN CAPAS (de abajo arriba)
//   ApiClient (core/network)   → habla HTTP, devuelve JSON
//   PostsRepository (aquí)     → convierte JSON en objetos Post
//   postsProvider (aquí)       → guarda en caché el resultado y su estado
//   PostsScreen (UI)           → dibuja cargando / error / datos
//   Si mañana los posts vienen de Firebase, solo cambias el repositorio.
//
// PROVIDERS USADOS
//   - Provider: un valor/objeto (el repositorio). Inyección de dependencias.
//   - FutureProvider: el resultado de una operación asíncrona. La UI recibe
//     un AsyncValue (AsyncLoading / AsyncError / AsyncData).
//   - .autoDispose: libera la caché cuando ninguna pantalla lo usa
//     (al salir de la demo, los datos se descartan).
//   - .family: provider con PARÁMETRO (un post distinto por cada id).
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (secciones 2 y 7)
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/network/api_client.dart';
import 'package:mi_primera_app/features/posts/post.dart';

class PostsRepository {
  const PostsRepository(this._api);

  final ApiClient _api;

  Future<List<Post>> fetchPosts({int limit = 20}) async {
    // La API acepta ?_limit=20 para no descargar los 100 posts.
    final json = await _api.getJson('/posts', query: {'_limit': '$limit'});
    final list = json! as List<Object?>;
    return list.map((e) => Post.fromJson(e! as Map<String, Object?>)).toList();
  }

  Future<Post> fetchPost(int id) async {
    final json = await _api.getJson('/posts/$id');
    return Post.fromJson(json! as Map<String, Object?>);
  }
}

/// Repositorio: depende del ApiClient (lo obtiene con ref.watch).
final postsRepositoryProvider = Provider<PostsRepository>(
  (ref) => PostsRepository(ref.watch(apiClientProvider)),
);

/// Lista de posts. La UI hace `ref.watch(postsProvider)` y recibe un AsyncValue.
final postsProvider = FutureProvider.autoDispose<List<Post>>(
  (ref) => ref.watch(postsRepositoryProvider).fetchPosts(),
);

/// Un post por id: `ref.watch(postProvider(5))`.
final postProvider = FutureProvider.autoDispose.family<Post, int>(
  (ref, id) => ref.watch(postsRepositoryProvider).fetchPost(id),
);
