// ============================================================================
// lib/features/intermediate/localization_screen.dart — DEMO: IDIOMAS (i18n)
// ============================================================================
//
// QUÉ ENSEÑA
//   - Textos traducidos desde archivos .arb (lib/l10n/app_es.arb, app_en.arb).
//   - Textos con parámetros:   l10n.greeting('Jean')     → "¡Hola, Jean!"
//   - Plurales:                l10n.todosPending(3)      → "Tienes 3 tareas…"
//   - Fechas por idioma:       l10n.todayIs(DateTime.now())
//   - Paquete intl:            NumberFormat.currency, DateFormat, compactos.
//   - Cambiar el idioma en caliente (se guarda en Ajustes).
//
// CÓMO FUNCIONA
//   1. Escribes los textos en lib/l10n/app_es.arb (plantilla) y app_en.arb.
//   2. `flutter gen-l10n` (o `flutter run`) genera la clase AppLocalizations.
//   3. MaterialApp (lib/app.dart) registra los delegates y los idiomas.
//   4. En cualquier widget: `AppLocalizations.of(context).nombreDelTexto`.
//
// 📚 Guía: docs/11-configuraciones-avanzadas.md (sección 4)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mi_primera_app/core/settings/settings_controller.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:mi_primera_app/l10n/app_localizations.dart';

class LocalizationScreen extends ConsumerStatefulWidget {
  const LocalizationScreen({super.key});

  @override
  ConsumerState<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends ConsumerState<LocalizationScreen> {
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Idioma ACTIVO (puede venir de Ajustes o del sistema).
    final locale = Localizations.localeOf(context);
    final localeName = locale.toString();
    final settings = ref.watch(settingsProvider);

    return DemoScaffold(
      title: 'Idiomas (i18n)',
      explanation:
          'Los textos viven en archivos .arb por idioma. flutter gen-l10n '
          'genera la clase AppLocalizations con un método por texto. Cambia '
          'el idioma abajo y observa cómo se traducen textos, plurales, '
          'fechas y monedas.',
      sourceFile: 'lib/features/intermediate/localization_screen.dart',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: 'Idioma de la app',
            description:
                'Se guarda con shared_preferences y se aplica a toda la app '
                '(MaterialApp.locale). Idioma activo: $localeName',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'system', label: Text('Sistema')),
                ButtonSegment(value: 'es', label: Text('Español')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {settings.locale?.languageCode ?? 'system'},
              onSelectionChanged: (selection) {
                final code = selection.first;
                ref
                    .read(settingsProvider.notifier)
                    .setLocale(code == 'system' ? null : Locale(code));
              },
            ),
          ),
          DemoSection(
            title: 'Texto con parámetro',
            description: 'app_es.arb → "greeting": "¡Hola, {name}!"',
            child: Text(
              l10n.greeting('Jean'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          DemoSection(
            title: 'Plurales',
            description:
                'Sintaxis ICU: {count, plural, =0{…} =1{…} other{…}}. Cada '
                'idioma define sus propias reglas de plural.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.todosPending(_count)),
                Slider(
                  value: _count.toDouble(),
                  max: 10,
                  divisions: 10,
                  label: '$_count',
                  onChanged: (v) => setState(() => _count = v.round()),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Fechas, números y monedas (intl)',
            description:
                'DateFormat y NumberFormat formatean según el idioma: '
                'separadores de miles, decimales, nombres de meses…',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.todayIs(DateTime.now())),
                Text(
                  'Hora: ${DateFormat.jm(localeName).format(DateTime.now())}',
                ),
                Text(
                  'Número: ${NumberFormat.decimalPattern(localeName).format(1234567.891)}',
                ),
                Text(
                  'Moneda: ${NumberFormat.simpleCurrency(locale: localeName, name: 'USD').format(1499.99)}',
                ),
                Text(
                  'Compacto: ${NumberFormat.compact(locale: localeName).format(2500000)}',
                ),
                Text(
                  'Porcentaje: ${NumberFormat.percentPattern(localeName).format(0.256)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
