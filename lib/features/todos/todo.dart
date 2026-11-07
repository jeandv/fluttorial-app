// ============================================================================
// lib/features/todos/todo.dart — MODELO INMUTABLE DE UNA TAREA
// ============================================================================
//
// QUÉ HACE
//   Representa una tarea. Es INMUTABLE (todos los campos `final`): para
//   "modificarla" se crea una copia con `copyWith`. Así el estado de Riverpod
//   cambia de referencia y la UI sabe que debe redibujarse.
//
//   toJson / fromJson permiten guardarla como texto en shared_preferences.
// ============================================================================

import 'package:flutter/foundation.dart';

@immutable
class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.done = false,
    required this.createdAt,
  });

  final String id;
  final String title;
  final bool done;
  final DateTime createdAt;

  Todo copyWith({String? title, bool? done}) => Todo(
    id: id,
    title: title ?? this.title,
    done: done ?? this.done,
    createdAt: createdAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'done': done,
    // Las fechas se guardan como texto ISO-8601: "2026-11-07T10:30:00.000"
    'createdAt': createdAt.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, Object?> json) => Todo(
    id: json['id']! as String,
    title: json['title']! as String,
    done: json['done'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt']! as String),
  );

  @override
  bool operator ==(Object other) =>
      other is Todo &&
      other.id == id &&
      other.title == title &&
      other.done == done &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, title, done, createdAt);
}

/// Filtros de la lista.
enum TodoFilter { all, pending, done }
