// ============================================================================
// lib/core/router/routes.dart — RUTAS (URLs) DE LA APP
// ============================================================================
//
// QUÉ HACE
//   Centraliza todas las rutas en constantes. Así, en vez de escribir
//   context.push('/ejemplos/contador') "a mano" en varios sitios (y equivocarte
//   en una letra), escribes context.push(AppRoutes.counter).
//
// CÓMO SE ORGANIZAN
//   /ejemplos            → pestaña 1: catálogo de demos
//     /ejemplos/contador, /ejemplos/layout, …   (pantallas hijas)
//     /ejemplos/posts/:id                      (:id = parámetro de ruta)
//   /tareas              → pestaña 2: lista de tareas
//   /ajustes             → pestaña 3: ajustes
//   /login, /privado     → fuera de las pestañas (pantalla completa)
//
// Las rutas hijas se muestran DENTRO de su pestaña (con la barra inferior),
// y al cambiar de pestaña y volver, se conserva dónde estabas.
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 1)
// ============================================================================

abstract final class AppRoutes {
  // Pestañas principales
  static const examples = '/ejemplos';
  static const todos = '/tareas';
  static const settings = '/ajustes';

  // Básico
  static const counter = '$examples/contador';
  static const layout = '$examples/layout';
  static const widgets = '$examples/widgets';
  static const lists = '$examples/listas';

  // Intermedio
  static const forms = '$examples/formularios';
  static const navigation = '$examples/navegacion';
  static const navigationPicker = '$navigation/elegir';
  static String navigationDetail(int id, {String? from}) => Uri(
    path: '$navigation/detalle/$id',
    queryParameters: from == null ? null : {'desde': from},
  ).toString();
  static const async = '$examples/asincronia';
  static const posts = '$examples/posts';
  static String postDetail(int id) => '$posts/$id';
  static const localization = '$examples/idiomas';

  // Avanzado
  static const animations = '$examples/animaciones';
  static const responsive = '$examples/responsive';
  static const nativeChannel = '$examples/nativo';
  static const isolates = '$examples/isolates';

  // Rutas fuera de las pestañas
  static const login = '/login';
  static const private = '/privado';
}
