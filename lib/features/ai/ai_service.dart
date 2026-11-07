// ============================================================================
// lib/features/ai/ai_service.dart — CASOS DE USO DE IA (consejos, docs, imágenes)
// ============================================================================
//
// QUÉ HACE
//   Define qué puede hacer la IA en la app (AiService) con DOS implementaciones:
//   - ClaudeAiService: llama a Claude de verdad (con API key o proxy).
//   - DemoAiService: respuestas de ejemplo SIN internet ni key, para que la
//     demo funcione siempre (y para los tests).
//   aiServiceProvider elige una u otra según Env.aiEnabled.
//
// INGENIERÍA DE PROMPTS (lo más importante al usar IA)
//   - `system`: QUIÉN es el modelo y CÓMO debe responder (tono, idioma, formato).
//   - mensaje del usuario: QUÉ tiene que hacer, con todo el contexto necesario.
//   - Pide un FORMATO concreto (Markdown, lista numerada, solo SVG…) para
//     poder mostrar la respuesta de forma fiable.
//
// 📚 Guía: docs/15-ia-y-agentes.md
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_primera_app/core/config/env.dart';
import 'package:mi_primera_app/features/ai/claude_client.dart';

/// Tipos de documento que la IA sabe redactar.
enum DocKind {
  storeDescription(
    'Descripción para la App Store / Google Play',
    'Incluye un título atractivo, una frase gancho, 5 viñetas de beneficios y '
        'una llamada a la acción. Máximo 300 palabras.',
  ),
  releaseNotes(
    'Notas de versión',
    'Secciones "Novedades", "Mejoras" y "Correcciones". Tono cercano. '
        'Máximo 120 palabras.',
  ),
  privacyPolicy(
    'Política de privacidad (borrador)',
    'Estructura con encabezados: datos que se recogen, uso, terceros, '
        'derechos del usuario y contacto. Añade al inicio una nota indicando '
        'que es un BORRADOR que debe revisar un profesional legal.',
  ),
  readme(
    'README para GitHub',
    'Incluye descripción, capturas (marcadores), instalación con '
        'comandos de Flutter, estructura del proyecto y licencia.',
  ),
  supportEmail(
    'Email de soporte a un usuario',
    'Tono amable y profesional. Saludo, solución en pasos, cierre.',
  );

  const DocKind(this.label, this.instructions);

  final String label;
  final String instructions;
}

abstract interface class AiService {
  /// true si son respuestas de ejemplo (sin IA real).
  bool get isDemo;

  /// Consejos prácticos sobre un tema (texto en streaming, Markdown).
  Stream<String> tips(String topic);

  /// Redacta un documento (texto en streaming, Markdown).
  Stream<String> document(DocKind kind, String brief);

  /// Genera una ilustración como código SVG (vectorial).
  Future<String> svgIllustration(String description);
}

// ===========================================================================
// IMPLEMENTACIÓN REAL
// ===========================================================================

class ClaudeAiService implements AiService {
  ClaudeAiService(this._client);

  final ClaudeClient _client;

  @override
  bool get isDemo => false;

  static const _mentor =
      'Eres un mentor experto en desarrollo de apps móviles con Flutter. '
      'Respondes siempre en español, de forma clara, práctica y concisa, '
      'usando Markdown.';

  @override
  Stream<String> tips(String topic) => _client.streamText(
    system: _mentor,
    // effort "low": respuestas cortas y rápidas, no requieren razonar mucho.
    effort: 'low',
    messages: [
      {
        'role': 'user',
        'content':
            'Dame 5 consejos concretos y accionables sobre: $topic.\n'
            'Formato: lista numerada en Markdown; cada consejo con un título '
            'en **negrita** y 1-2 frases de explicación. Sin introducción.',
      },
    ],
  );

  @override
  Stream<String> document(DocKind kind, String brief) => _client.streamText(
    system:
        'Eres redactor técnico y de marketing para apps móviles. '
        'Escribes en español y entregas el documento final en Markdown, '
        'sin comentarios antes ni después.',
    effort: 'medium',
    messages: [
      {
        'role': 'user',
        'content':
            'Redacta: ${kind.label}.\n'
            'Sobre esta app: $brief\n'
            'Requisitos: ${kind.instructions}',
      },
    ],
  );

  @override
  Future<String> svgIllustration(String description) async {
    final response = await _client.createMessage(
      system:
          'Eres un ilustrador que crea gráficos vectoriales SVG limpios y '
          'atractivos, de estilo plano (flat design).',
      effort: 'medium',
      messages: [
        {
          'role': 'user',
          'content':
              'Crea una ilustración SVG de: $description.\n'
              'Requisitos: viewBox="0 0 400 300", colores planos y armoniosos, '
              'sin texto, sin <script>, sin imágenes externas ni fuentes. '
              'Responde SOLO con el código <svg>…</svg>.',
        },
      ],
    );
    return extractSvg(ClaudeClient.textOf(response));
  }
}

/// Extrae el bloque `<svg>…</svg>` de la respuesta (el modelo a veces lo
/// envuelve en un bloque de código Markdown). Lanza un error si no hay SVG.
String extractSvg(String text) {
  final match = RegExp(r'<svg[\s\S]*?</svg>').firstMatch(text);
  if (match == null) {
    throw const ClaudeException('La IA no devolvió un SVG válido. Reintenta.');
  }
  return match.group(0)!;
}

// ===========================================================================
// IMPLEMENTACIÓN DEMO (sin internet ni API key)
// ===========================================================================

class DemoAiService implements AiService {
  const DemoAiService({this.wordDelay = const Duration(milliseconds: 35)});

  final Duration wordDelay;

  @override
  bool get isDemo => true;

  /// Simula el streaming emitiendo el texto palabra a palabra.
  Stream<String> _typewriter(String text) async* {
    for (final word in text.split(' ')) {
      await Future<void>.delayed(wordDelay);
      yield '$word ';
    }
  }

  @override
  Stream<String> tips(String topic) => _typewriter(
    '1. **Empieza pequeño.** Crea una versión mínima de "$topic" y mejórala '
    'poco a poco.\n\n'
    '2. **Lee la documentación oficial.** docs.flutter.dev y pub.dev resuelven '
    'el 80 % de las dudas.\n\n'
    '3. **Escribe tests desde el principio.** Te avisan cuando rompes algo.\n\n'
    '4. **Separa lógica e interfaz.** Usa providers o repositorios.\n\n'
    '5. **Prueba en un dispositivo real** antes de publicar.\n\n'
    '_(Respuesta de ejemplo: configura una API key para usar la IA real. '
    'Ver docs/15.)_',
  );

  @override
  Stream<String> document(DocKind kind, String brief) => _typewriter(
    '# ${kind.label}\n\n'
    '**App:** $brief\n\n'
    '## Lo que haría la IA\n\n'
    'Con una API key configurada, Claude redactaría aquí un documento '
    'completo siguiendo estas instrucciones:\n\n> ${kind.instructions}\n\n'
    '_(Modo demo. Ver docs/15 para activar la IA real.)_',
  );

  @override
  Future<String> svgIllustration(String description) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Paisaje fijo de ejemplo.
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300">'
        '<rect width="400" height="300" fill="#BBDEFB"/>'
        '<circle cx="320" cy="70" r="40" fill="#FFCA28"/>'
        '<polygon points="0,300 130,120 260,300" fill="#5C6BC0"/>'
        '<polygon points="140,300 270,150 400,300" fill="#3949AB"/>'
        '<rect y="250" width="400" height="50" fill="#66BB6A"/>'
        '</svg>';
  }
}

// ===========================================================================
// PROVIDERS
// ===========================================================================

/// Cliente de Claude (null si no hay key ni proxy configurados).
final claudeClientProvider = Provider<ClaudeClient?>((ref) {
  if (!Env.aiEnabled) return null;
  final client = ClaudeClient(
    apiKey: Env.anthropicApiKey,
    baseUrl: Env.aiProxyUrl,
  );
  ref.onDispose(client.close);
  return client;
});

final aiServiceProvider = Provider<AiService>((ref) {
  final client = ref.watch(claudeClientProvider);
  return client == null ? const DemoAiService() : ClaudeAiService(client);
});
