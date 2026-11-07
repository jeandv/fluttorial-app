// ============================================================================
// lib/features/packages/links_share_screen.dart — DEMO: ENLACES Y COMPARTIR
// ============================================================================
//
// QUÉ ENSEÑA
//   url_launcher (uno de los paquetes más descargados de pub.dev):
//   - Abrir una web en el navegador interno de la app o en el externo.
//   - Llamar (tel:), enviar email (mailto:) o SMS (sms:).
//   - Abrir la app de mapas del teléfono en unas coordenadas.
//   share_plus:
//   - Abrir la hoja "Compartir" nativa (WhatsApp, Telegram, email…).
//
// CÓMO FUNCIONA url_launcher
//   Construyes una `Uri` con el "esquema" adecuado y llamas a launchUrl.
//   El sistema operativo decide qué app la abre:
//     https://…   → navegador          tel:+58…   → teléfono
//     mailto:…    → email              sms:…      → mensajes
//   launchUrl devuelve false (o lanza error) si no hay app que la abra
//   (por ejemplo, el simulador de iOS no tiene app de Teléfono).
//
// CONFIGURACIÓN NATIVA (ya hecha en este proyecto)
//   Android: bloque <queries> en android/app/src/main/AndroidManifest.xml.
// ============================================================================

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:mi_primera_app/core/widgets/demo_scaffold.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksShareScreen extends StatelessWidget {
  const LinksShareScreen({super.key});

  /// Intenta abrir [uri]; si no hay ninguna app que pueda, avisa.
  Future<void> _open(
    BuildContext context,
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    final messenger = ScaffoldMessenger.of(context); // antes del await
    bool opened;
    try {
      opened = await launchUrl(uri, mode: mode);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'No hay ninguna app para abrir "${uri.scheme}:" '
            '(normal en el simulador)',
          ),
        ),
      );
    }
  }

  Future<void> _share(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    // En iPad la hoja de compartir necesita saber desde dónde se abre.
    final box = context.findRenderObject() as RenderBox?;

    final result = await SharePlus.instance.share(
      ShareParams(
        text:
            '¡Estoy aprendiendo Flutter con mi app guía! 🚀 '
            'https://flutter.dev',
        subject: 'Aprendiendo Flutter',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );

    // El resultado indica si el usuario compartió o cerró la hoja.
    messenger.showSnackBar(
      SnackBar(content: Text('Resultado: ${result.status.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const lat = 10.5061, lng = -66.9146; // Plaza Bolívar, Caracas

    return DemoScaffold(
      title: 'Enlaces y compartir',
      explanation:
          'url_launcher abre webs, el teléfono, el email, los SMS o la app de '
          'mapas a partir de una Uri. share_plus muestra la hoja "Compartir" '
          'del sistema. En el simulador algunas apps (Teléfono) no existen.',
      sourceFile: 'lib/features/packages/links_share_screen.dart',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          DemoSection(
            title: 'Webs',
            description:
                'inAppBrowserView abre la web DENTRO de la app (Safari View '
                'Controller / Chrome Custom Tabs); externalApplication abre el '
                'navegador.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _open(
                    context,
                    Uri.parse('https://docs.flutter.dev'),
                    mode: LaunchMode.inAppBrowserView,
                  ),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Dentro de la app'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _open(
                    context,
                    Uri.parse('https://pub.dev'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Navegador externo'),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Teléfono, email y SMS',
            description:
                'Uri(scheme: …) construye la URL de forma segura (codifica '
                'espacios y acentos).',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      _open(context, Uri(scheme: 'tel', path: '+582120000000')),
                  icon: const Icon(Icons.call),
                  label: const Text('Llamar'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _open(
                    context,
                    Uri(
                      scheme: 'mailto',
                      path: 'soporte@ejemplo.com',
                      query:
                          'subject=Hola desde Flutter&body=Mensaje de prueba',
                    ),
                  ),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _open(context, Uri(scheme: 'sms', path: '+582120000000')),
                  icon: const Icon(Icons.sms_outlined),
                  label: const Text('SMS'),
                ),
              ],
            ),
          ),
          DemoSection(
            title: 'Abrir la app de mapas del teléfono',
            description:
                'iOS usa Apple Maps (maps.apple.com) y Android cualquier app '
                'que entienda "geo:" (Google Maps). Para un mapa DENTRO de tu '
                'app, mira la demo "Mapas".',
            child: FilledButton.tonalIcon(
              onPressed: () => _open(
                context,
                // queryParameters codifica espacios y acentos por nosotros.
                Platform.isIOS
                    ? Uri.https('maps.apple.com', '/', {
                        'll': '$lat,$lng',
                        'q': 'Plaza Bolívar',
                      })
                    : Uri(
                        scheme: 'geo',
                        path: '$lat,$lng',
                        queryParameters: {'q': '$lat,$lng(Plaza Bolívar)'},
                      ),
              ),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Plaza Bolívar en Mapas'),
            ),
          ),
          DemoSection(
            title: 'Compartir (share_plus)',
            description:
                'Abre la hoja nativa de compartir. ShareParams también acepta '
                'archivos (files: [XFile(...)]) para compartir fotos o PDFs.',
            // Builder: da un `context` del propio botón (para la posición en
            // iPad).
            child: Builder(
              builder: (buttonContext) => FilledButton.icon(
                onPressed: () => _share(buttonContext),
                icon: const Icon(Icons.share),
                label: const Text('Compartir texto'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
