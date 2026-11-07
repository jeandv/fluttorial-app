// ============================================================================
// lib/features/posts/post.dart — MODELO DE DATOS (JSON ↔ Dart)
// ============================================================================
//
// QUÉ HACE
//   Representa un "post" de la API https://jsonplaceholder.typicode.com/posts
//   como una clase Dart con tipos, en lugar de usar Map<String, dynamic>.
//
// CÓMO FUNCIONA
//   - `Post.fromJson(map)`: constructor "factory" que crea un Post a partir
//     del Map que devuelve jsonDecode.
//   - `toJson()`: lo contrario, para enviarlo a una API o guardarlo.
//   - Usa PATTERN MATCHING de Dart 3 (`switch` sobre el Map) para validar que
//     el JSON tiene los campos y tipos esperados. Si no, lanza un error claro
//     en lugar de fallar más tarde con un "null is not a subtype of String".
//
// EN PROYECTOS GRANDES
//   Se suele generar este código automáticamente con `json_serializable` o
//   `freezed` + `build_runner` (ver docs/11, sección 9).
// ============================================================================

import 'package:flutter/foundation.dart';

@immutable
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  /// Crea un Post desde JSON validando su forma con pattern matching.
  factory Post.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {
        'id': final int id,
        'userId': final int userId,
        'title': final String title,
        'body': final String body,
      } =>
        Post(id: id, userId: userId, title: title, body: body),
      _ => throw FormatException('JSON de Post inválido: $json'),
    };
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
  };

  // == y hashCode: dos Post con los mismos datos se consideran iguales.
  // Útil en tests (expect(post, equals(otroPost))) y para evitar redibujados.
  @override
  bool operator ==(Object other) =>
      other is Post &&
      other.id == id &&
      other.userId == userId &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, userId, title, body);
}
