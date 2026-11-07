// ============================================================================
// lib/core/theme/app_theme.dart — TEMA VISUAL (claro, oscuro y extensiones)
// ============================================================================
//
// QUÉ HACE
//   Define el aspecto de toda la app en UN solo lugar: colores, formas de
//   tarjetas, campos de texto, barra superior… para modo claro y oscuro.
//
// CÓMO FUNCIONA
//   - ColorScheme.fromSeed genera una paleta completa (Material 3) a partir de
//     un color "semilla". Cambia `seed` y toda la app cambia de color.
//   - Los "component themes" (appBarTheme, cardTheme, inputDecorationTheme…)
//     dan estilo por defecto a cada tipo de widget.
//   - ThemeExtension (LevelColors) permite añadir TUS PROPIOS valores al tema
//     (configuración avanzada), con soporte de animación entre claro/oscuro.
//
// CÓMO SE USA EN CUALQUIER WIDGET
//   final colors = Theme.of(context).colorScheme;       // colores del tema
//   final text   = Theme.of(context).textTheme;         // estilos de texto
//   final levels = Theme.of(context).extension<LevelColors>()!; // extensión propia
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 3)
// ============================================================================

import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// Color base de la app. 🧪 Prueba a cambiarlo por Colors.teal + hot reload.
  static const seed = Colors.indigo;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      colorScheme: scheme,

      // Barra superior: título centrado en ambas plataformas.
      appBarTheme: const AppBarTheme(centerTitle: true),

      // Tarjetas con bordes redondeados y sin sombra.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Campos de texto con borde redondeado por defecto.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Mensajes SnackBar flotantes (no pegados al borde inferior).
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),

      // Extensiones propias del tema (ver clase LevelColors más abajo).
      extensions: [isDark ? LevelColors.dark : LevelColors.light],
    );
  }
}

/// EXTENSIÓN DE TEMA: colores propios para los niveles del catálogo.
///
/// Para crear una extensión hay que implementar:
///   - copyWith: crear una copia cambiando algunos valores.
///   - lerp: interpolar entre dos extensiones (Flutter lo usa para ANIMAR el
///     cambio de tema claro ↔ oscuro).
@immutable
class LevelColors extends ThemeExtension<LevelColors> {
  const LevelColors({
    required this.basic,
    required this.intermediate,
    required this.advanced,
    required this.product,
    required this.packages,
  });

  final Color basic;
  final Color intermediate;
  final Color advanced;
  final Color product;
  final Color packages;

  static const light = LevelColors(
    basic: Color(0xFF2E7D32), // verde
    intermediate: Color(0xFFEF6C00), // naranja
    advanced: Color(0xFFC62828), // rojo
    product: Color(0xFF6A1B9A), // morado
    packages: Color(0xFF00838F), // turquesa
  );

  static const dark = LevelColors(
    basic: Color(0xFF81C784),
    intermediate: Color(0xFFFFB74D),
    advanced: Color(0xFFE57373),
    product: Color(0xFFCE93D8),
    packages: Color(0xFF4DD0E1),
  );

  @override
  LevelColors copyWith({
    Color? basic,
    Color? intermediate,
    Color? advanced,
    Color? product,
    Color? packages,
  }) {
    return LevelColors(
      basic: basic ?? this.basic,
      intermediate: intermediate ?? this.intermediate,
      advanced: advanced ?? this.advanced,
      product: product ?? this.product,
      packages: packages ?? this.packages,
    );
  }

  @override
  LevelColors lerp(LevelColors? other, double t) {
    if (other == null) return this;
    return LevelColors(
      basic: Color.lerp(basic, other.basic, t)!,
      intermediate: Color.lerp(intermediate, other.intermediate, t)!,
      advanced: Color.lerp(advanced, other.advanced, t)!,
      product: Color.lerp(product, other.product, t)!,
      packages: Color.lerp(packages, other.packages, t)!,
    );
  }
}
