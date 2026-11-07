// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My First App';

  @override
  String get tabExamples => 'Examples';

  @override
  String get tabTodos => 'Tasks';

  @override
  String get tabSettings => 'Settings';

  @override
  String get levelBasic => 'Basic';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String todosPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count pending tasks',
      one: 'You have 1 pending task',
      zero: 'You have no pending tasks',
    );
    return '$_temp0';
  }

  @override
  String todayIs(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMEEEEd(
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Today is $dateString';
  }

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get todosHint => 'What do you need to do?';

  @override
  String get todosAdd => 'Add';

  @override
  String get todosEmpty => 'No tasks here. Add one above!';

  @override
  String get todosDeleted => 'Task deleted';

  @override
  String get undo => 'Undo';
}
