// ============================================================================
// test/features/posts/posts_repository_test.dart — PROBAR CÓDIGO DE RED SIN RED
// ============================================================================
//
// QUÉ ENSEÑA
//   - MockClient (package:http/testing.dart): un cliente HTTP falso que
//     devuelve las respuestas que tú decidas. Los tests no usan internet,
//     son instantáneos y siempre dan el mismo resultado.
//   - Probar los casos de error: código 500, JSON inválido, sin conexión.
//   - Probar un FutureProvider sobrescribiendo su dependencia (apiClientProvider).
// ============================================================================

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mi_primera_app/core/network/api_client.dart';
import 'package:mi_primera_app/features/posts/post.dart';
import 'package:mi_primera_app/features/posts/posts_repository.dart';

const _postJson = {'id': 1, 'userId': 7, 'title': 'Hola', 'body': 'Cuerpo'};

/// Crea un ApiClient cuyo "servidor" es la función [handler].
ApiClient fakeApi(Future<http.Response> Function(http.Request) handler) =>
    ApiClient(client: MockClient(handler), baseUrl: 'https://fake.api');

void main() {
  group('Post.fromJson', () {
    test('convierte un JSON válido', () {
      expect(
        Post.fromJson(_postJson),
        const Post(id: 1, userId: 7, title: 'Hola', body: 'Cuerpo'),
      );
    });

    test('lanza FormatException si falta un campo', () {
      expect(
        () => Post.fromJson({'id': 1, 'title': 'Sin body'}),
        throwsFormatException,
      );
    });
  });

  group('PostsRepository', () {
    test('fetchPosts pide /posts?_limit=20 y convierte la lista', () async {
      late Uri requestedUrl;
      final repo = PostsRepository(
        fakeApi((request) async {
          requestedUrl = request.url;
          return http.Response(jsonEncode([_postJson, _postJson]), 200);
        }),
      );

      final posts = await repo.fetchPosts();

      expect(requestedUrl.toString(), 'https://fake.api/posts?_limit=20');
      expect(posts, hasLength(2));
      expect(posts.first.title, 'Hola');
    });

    test('un error 500 se convierte en ApiException', () async {
      final repo = PostsRepository(
        fakeApi((_) async => http.Response('error', 500)),
      );
      await expectLater(
        repo.fetchPost(1),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('sin conexión se convierte en ApiException', () async {
      final repo = PostsRepository(
        fakeApi((_) async => throw http.ClientException('sin red')),
      );
      await expectLater(repo.fetchPosts(), throwsA(isA<ApiException>()));
    });
  });

  test('postProvider(id) usa el ApiClient inyectado (override)', () async {
    final container = ProviderContainer(
      overrides: [
        // Sustituimos el cliente real por uno falso: el resto de la cadena
        // (repositorio → provider) es el código real de la app.
        apiClientProvider.overrideWithValue(
          fakeApi((_) async => http.Response(jsonEncode(_postJson), 200)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final post = await container.read(postProvider(1).future);
    expect(post.userId, 7);
  });
}
