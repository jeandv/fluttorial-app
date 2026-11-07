// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mi Primera App';

  @override
  String get tabExamples => 'Ejemplos';

  @override
  String get tabTodos => 'Tareas';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get levelBasic => 'Básico';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelAdvanced => 'Avanzado';

  @override
  String greeting(String name) {
    return '¡Hola, $name!';
  }

  @override
  String todosPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $count tareas pendientes',
      one: 'Tienes 1 tarea pendiente',
      zero: 'No tienes tareas pendientes',
    );
    return '$_temp0';
  }

  @override
  String todayIs(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMEEEEd(
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Hoy es $dateString';
  }

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get todosHint => '¿Qué tienes que hacer?';

  @override
  String get todosAdd => 'Añadir';

  @override
  String get todosEmpty => 'No hay tareas aquí. ¡Añade una arriba!';

  @override
  String get todosDeleted => 'Tarea eliminada';

  @override
  String get undo => 'Deshacer';
}
