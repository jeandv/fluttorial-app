// ============================================================================
// lib/features/settings/settings_screen.dart — PESTAÑA "AJUSTES"
// ============================================================================
//
// QUÉ ENSEÑA
//   - Cambiar tema e idioma de TODA la app (settingsProvider → MaterialApp).
//   - Los ajustes se guardan: cierra la app y se conservan.
//   - Leer constantes de compilación: kDebugMode / kProfileMode / kReleaseMode
//     y variables de entorno (--dart-define) desde Env.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/config/env.dart';
import 'package:mi_primera_app/core/settings/settings_controller.dart';
import 'package:mi_primera_app/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    // Constantes de Flutter: solo una es true según cómo se compiló la app.
    final buildMode = kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsTheme,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto),
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => controller.setThemeMode(s.first),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.settingsLanguage,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // RadioGroup (Flutter 3.35+): agrupa RadioListTile y gestiona el
          // valor seleccionado en un único lugar.
          RadioGroup<String>(
            groupValue: settings.locale?.languageCode ?? 'system',
            onChanged: (code) => controller.setLocale(
              code == null || code == 'system' ? null : Locale(code),
            ),
            child: Column(
              children: [
                RadioListTile(
                  value: 'system',
                  title: Text(l10n.languageSystem),
                ),
                const RadioListTile(value: 'es', title: Text('Español')),
                const RadioListTile(value: 'en', title: Text('English')),
              ],
            ),
          ),
          const Divider(height: 32),
          Text('Compilación', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.build_outlined),
            title: const Text('Modo'),
            subtitle: Text(buildMode),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.layers_outlined),
            title: const Text('Entorno (FLAVOR)'),
            subtitle: const Text(Env.flavor),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('API (API_URL)'),
            subtitle: const Text(Env.apiBaseUrl),
          ),
          const SizedBox(height: 8),
          Text(
            'Cámbialos con: flutter run --dart-define-from-file=config/prod.json',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
